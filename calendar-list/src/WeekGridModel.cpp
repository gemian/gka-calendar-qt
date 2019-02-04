#include "WeekGridModel.h"

WeekGridModel::WeekGridModel(QObject *parent, QString prefManager) : QAbstractListModel(parent) {

    QString manager = "memory";
    QStringList possibles = QtOrganizer::QOrganizerManager::availableManagers();
    if (possibles.contains(prefManager)) {
        manager = prefManager;
    }
    QtOrganizer::QOrganizerManager *newManager = new QtOrganizer::QOrganizerManager(manager);
    if (newManager->error()) {
        qCritical("error no new manager");
        delete newManager;
    } else {
        _manager = newManager;
    }

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &WeekGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &WeekGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &WeekGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &WeekGridModel::manageItemsRemoved);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsAdded, this, &WeekGridModel::manageCollectionsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsChanged, this, &WeekGridModel::manageCollectionsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsRemoved, this, &WeekGridModel::manageCollectionsRemoved);

    _gridCells.fill(nullptr);
}

WeekGridModel::~WeekGridModel() {
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.empty();
    delete _manager;
}

QtOrganizer::QOrganizerItemIntersectionFilter WeekGridModel::filter() {
    QSet<QtOrganizer::QOrganizerCollectionId> collectionIds;
            foreach (QtOrganizer::QOrganizerCollection collection, _manager->collections()) {
            if (collection.extendedMetaData("collection-selected").toBool()) {
                collectionIds.insert(collection.id());
            }
        }
    QtOrganizer::QOrganizerItemDetailFieldFilter eventFilter;
    eventFilter.setDetail(QtOrganizer::QOrganizerItemDetail::TypeItemType, QtOrganizer::QOrganizerItemType::FieldType);
    eventFilter.setValue(QtOrganizer::QOrganizerItemType::TypeEvent);
    eventFilter.setMatchFlags(QtOrganizer::QOrganizerItemDetailFieldFilter::MatchExactly);
    QtOrganizer::QOrganizerItemDetailFieldFilter eventOccurrenceFilter;
    eventOccurrenceFilter.setDetail(QtOrganizer::QOrganizerItemDetail::TypeItemType, QtOrganizer::QOrganizerItemType::FieldType);
    eventOccurrenceFilter.setValue(QtOrganizer::QOrganizerItemType::TypeEventOccurrence);
    eventOccurrenceFilter.setMatchFlags(QtOrganizer::QOrganizerItemDetailFieldFilter::MatchExactly);
    QtOrganizer::QOrganizerItemUnionFilter itemTypeFilter;
    itemTypeFilter.append(eventFilter);
    itemTypeFilter.append(eventOccurrenceFilter);
    QtOrganizer::QOrganizerItemCollectionFilter collectionFilter;
    collectionFilter.setCollectionIds(collectionIds);
    QtOrganizer::QOrganizerItemIntersectionFilter mainFilter;
    mainFilter.append(itemTypeFilter);
    mainFilter.append(collectionFilter);
    return mainFilter;
}

QDateTime WeekGridModel::startOfWeek() {
    return QDateTime(_startOfWeek, QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId()));
}

void WeekGridModel::setStartOfWeek(QDateTime dateTime) {
    QDate date = dateTime.date();
    if (_startOfWeek != date) {
        _startOfWeek = date;
        _endOfWeek = date.addDays(DAYS_IN_WEEK);

        QDateTime startDateTime(_startOfWeek, QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId()));
        QDateTime endDateTime(_endOfWeek, QTime(23, 59, 59, 0), QTimeZone(QTimeZone::systemTimeZoneId()));

        ensureEmptyGridCell(0);
        for (int d = 1; d <= DAYS_IN_WEEK; d++) {
            QDate dayDate = date.addDays(d - 1);
            WeekDay *day = ensureEmptyGridCell(d);
            day->setDate(QDateTime(dayDate, QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId())));
        }

        QList<QtOrganizer::QOrganizerItem> items = _manager->items(startDateTime, endDateTime, filter());
//        qWarning() << "week got items: " << items;
        addItemsToGrid(items);

        emit modelChanged();
    }
}

WeekDay *WeekGridModel::ensureEmptyGridCell(int d) {
    auto cell = _gridCells[d];
    if (cell) {
        cell->clearEvents();
    } else {
        cell = new WeekDay();
        _gridCells[d] = cell;
    }
    return cell;
}

int WeekGridModel::itemCount() const {
    return _gridCells.size();
}

int WeekGridModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return itemCount();
}

QVariant WeekGridModel::data(const QModelIndex &index, int role) const {
    //This method is not used, just required by base class
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

QQmlListProperty<WeekDay> WeekGridModel::items() {
    return {this, nullptr, item_count, item_at};
}

QtOrganizer::QOrganizerManager *WeekGridModel::manager() {
    return _manager;
}

int WeekGridModel::item_count(QQmlListProperty<WeekDay> *p) {
    auto *model = dynamic_cast<WeekGridModel *>(p->object);
    if (model)
        return model->_gridCells.size();
    return 0;
}

WeekDay *WeekGridModel::item_at(QQmlListProperty<WeekDay> *p, int idx) {
    auto *model = dynamic_cast<WeekGridModel *>(p->object);
    if (model)
        return model->_gridCells[idx];
    return nullptr;
}

void WeekGridModel::manageDataChanged() {
    //this one means big changes clear and rebuild data
//    qDebug("manageDataChanged");
    auto sow = _startOfWeek;
    _startOfWeek = sow.addDays(1);
    setStartOfWeek(QDateTime(sow, QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId())));
}

void WeekGridModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void WeekGridModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("YGM::manageItemsChanged");
    removeItemsFromModel(itemIds);
//    qDebug("YGM::removed->add");
    addItemsToModel(itemIds);
//    qDebug("YGM::modelChanged");
    emit modelChanged();
}

void WeekGridModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("manageItemsRemoved");
    removeItemsFromModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void WeekGridModel::manageCollectionsAdded(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
//    setYear(year());
}

void WeekGridModel::manageCollectionsChanged(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
//    setYear(year());
}

void WeekGridModel::manageCollectionsRemoved(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
//    setYear(year());
}

void WeekGridModel::addEventToDay(QPointer<WeekEvent> event, QDate date) {
    int gridIndex = _startOfWeek.daysTo(date)+1;
//    qDebug() << "addEventToDay, index:" << gridIndex << "date:" << date << "event startdatetime" << event.data()->startDateTime();
    if (gridIndex >= 0 && gridIndex < _gridCells.size()) {
        _gridCells[gridIndex]->addEvent(std::move(event));
        beginRemoveRows(QModelIndex(), gridIndex, gridIndex);
        endRemoveRows();
        beginInsertRows(QModelIndex(), gridIndex, gridIndex);
        endInsertRows();
    }
}

void WeekGridModel::addItemsToGrid(const QList<QtOrganizer::QOrganizerItem> &items) {
    for (const auto &item : items) {
        QtOrganizer::QOrganizerItemLocation itemLocation = item.detail(QtOrganizer::QOrganizerItemDetail::TypeLocation);
        QtOrganizer::QOrganizerEventTime eventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        if (!eventTime.isEmpty() && eventTime.startDateTime().isValid()) {
            QPointer<WeekEvent> event = new WeekEvent();
            QDateTime startDateTime = eventTime.startDateTime();
            startDateTime.setTime(QTime(12, 0, 0, 0));
            QDate startDate = startDateTime.date();
            QDateTime endDateTime = eventTime.endDateTime();
            endDateTime.setTime(QTime(12, 0, 0, 0));
            QDate endDate = endDateTime.date();
            event->setStartDateTime(eventTime.startDateTime());
            event->setEndDateTime(eventTime.endDateTime());
            event->setAllDay(eventTime.isAllDay());
            event->setDisplayLabel(item.displayLabel());
            event->setLocation(itemLocation.label());
            event->setItemId(item.id());
            event->setCollectionId(item.collectionId().toString());

            auto parentIdDetail = item.detail(QtOrganizer::QOrganizerItemDetail::TypeParent);
//            qDebug() << "N" << item.displayLabel() << "parentIdDetail:" << parentIdDetail;
            auto parentId = parentIdDetail.value(QtOrganizer::QOrganizerItemParent::FieldParentId);
//            qDebug() << "ParentId:" << parentId;
            if (parentId.isValid()) {
//                qDebug() << "ParentId:" << parentId.value<QtOrganizer::QOrganizerItemId>().toString();
                event->setParentId(parentId.value<QtOrganizer::QOrganizerItemId>().toString());
            }

            do {
                addEventToDay(event, startDate);
//                qDebug() << "SDT: " << startDateTime << "SD: " << startDate << ", ED: " << endDate << ", EOW: " << _endOfWeek;
                startDate = startDate.addDays(1);
            } while (startDate < endDate && startDate < _endOfWeek);
        } else {
//            qDebug() << "ET: " << eventTime << ", I: " << item;
        }
    }
}

void WeekGridModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    for (auto i = 0; i < _gridCells.size(); i++) {
        if (_gridCells[i]->removeEventsFromModel(itemIds)) {
            beginRemoveRows(QModelIndex(), i, i);
            endRemoveRows();
            beginInsertRows(QModelIndex(), i, i);
            endInsertRows();
        }
    }
}

void WeekGridModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);
//    qWarning() << "addItemsToModel" << items;
    addItemsToGrid(items);
}

