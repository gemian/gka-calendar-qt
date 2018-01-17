#include "YearGridModel.h"

YearGridModel::YearGridModel(QObject *parent, QString prefManager) : QAbstractListModel(parent) {

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

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &YearGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &YearGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &YearGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &YearGridModel::manageItemsRemoved);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsAdded, this, &YearGridModel::manageCollectionsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsChanged, this, &YearGridModel::manageCollectionsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsRemoved, this, &YearGridModel::manageCollectionsRemoved);

    _gridCells.fill(nullptr);

    QDate date(1,1,1);
    date = date.addDays(1+DAYS_IN_WEEK-date.dayOfWeek());
    for (int d = 0; d < DAYS_IN_WEEK; d++) {
        int extra = 0;
        if (d <= 1) extra = 1;
        for (int g = 0; g < WEEK_BLOCKS_SHOWN+extra; g++) {
            auto cellIndex = d * GRID_HEIGHT + g * GRID_HEIGHT * DAYS_IN_WEEK;
            auto cell = _gridCells[cellIndex] = new YearDay();
            const QString &dayOfWeek = date.toString("ddd").left(1);
            qWarning() << cellIndex << dayOfWeek;
            cell->setDisplayLabel(dayOfWeek);
            cell->setType(DayTypeHeading);
        }
        date = date.addDays(1);
    }
}

YearGridModel::~YearGridModel() {
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.empty();
    delete _manager;
}

void YearGridModel::setCurrentDate(QDateTime date) {
    _currentDate = date;
}

QtOrganizer::QOrganizerItemIntersectionFilter YearGridModel::filter() {
    QSet<QtOrganizer::QOrganizerCollectionId> collectionIds;
    foreach (QtOrganizer::QOrganizerCollection collection, _manager->collections()) {
        if (collection.extendedMetaData("collection-selected").toBool()) {
            collectionIds.insert(collection.id());
        }
    }
    QtOrganizer::QOrganizerItemDetailFieldFilter allDayEventsFilter;
    allDayEventsFilter.setDetail(QtOrganizer::QOrganizerItemDetail::TypeEventTime, QtOrganizer::QOrganizerEventTime::FieldAllDay);
    allDayEventsFilter.setValue(true);
    allDayEventsFilter.setMatchFlags(QtOrganizer::QOrganizerItemDetailFieldFilter::MatchExactly);
    QtOrganizer::QOrganizerItemDetailFieldFilter eventFilter;
    eventFilter.setDetail(QtOrganizer::QOrganizerItemDetail::TypeItemType, QtOrganizer::QOrganizerItemType::FieldType);
    eventFilter.setValue(QtOrganizer::QOrganizerItemType::TypeEvent);
    eventFilter.setMatchFlags(QtOrganizer::QOrganizerItemDetailFieldFilter::MatchExactly);
    QtOrganizer::QOrganizerItemDetailFieldFilter eventOccurenceFilter;
    eventOccurenceFilter.setDetail(QtOrganizer::QOrganizerItemDetail::TypeItemType, QtOrganizer::QOrganizerItemType::FieldType);
    eventOccurenceFilter.setValue(QtOrganizer::QOrganizerItemType::TypeEventOccurrence);
    eventOccurenceFilter.setMatchFlags(QtOrganizer::QOrganizerItemDetailFieldFilter::MatchExactly);
    QtOrganizer::QOrganizerItemUnionFilter itemTypeFilter;
    itemTypeFilter.append(eventFilter);
    itemTypeFilter.append(eventOccurenceFilter);
    QtOrganizer::QOrganizerItemCollectionFilter collectionFilter;
    collectionFilter.setCollectionIds(collectionIds);
    QtOrganizer::QOrganizerItemIntersectionFilter mainFilter;
    mainFilter.append(itemTypeFilter);
    mainFilter.append(collectionFilter);
    mainFilter.append(allDayEventsFilter);
    return mainFilter;
}

int YearGridModel::year() const
{
    return _year;
}

int YearGridModel::cellIndexForMonthAndColumn(int month, int c) {
    return month + (c * GRID_HEIGHT);
}

void YearGridModel::setYear(const int year) {
    if (_year != year) {
        _year = year;

        QDateTime today = QDateTime::currentDateTime();
        if (_currentDate.isValid()) {
            today = _currentDate;
        }

        for (int m = 1; m <= MONTHS_IN_YEAR; m++) {
            QDateTime date(QDate(year, m, 1), today.time());
            _monthOffset[m - 1] = date.date().dayOfWeek() - 1;

            for (int c = 0; c < GRID_WIDTH; c++) {
                auto cellIndex = cellIndexForMonthAndColumn(m, c);
                auto cell = _gridCells[cellIndex];
                if (cell) {
                    cell->clearEvents();
                } else {
                    _gridCells[cellIndex] = cell = new YearDay();
                }
                QString label(" ");
                if (c >= _monthOffset[m - 1]) {
                    auto day = 1 + c - _monthOffset[m - 1];
                    date.setDate(QDate(year, m, day));
                    qWarning() << date;
                    if (date.isValid()) {
                        cell->setDate(date);
                    }
                    if (!date.isValid()) {
                        cell->setType(DayTypeInvalid);
                    } else if (date < today) {
                        cell->setType(DayTypePast);
                    } else if (date == today) {
                        cell->setType(DayTypeToday);
                    } else {
                        cell->setType(DayTypeFuture);
                    }
                    if (day == 1 || day == date.date().daysInMonth() || (date.date().dayOfWeek() == 1 && day <= date.date().daysInMonth())) {
                        label = QString::number(day);
                    }
                } else {
                    cell->setType(DayTypeInvalid);
                }
                cell->setDisplayLabel(label);
            }
        }

        QDateTime startDateTime(QDate(year, 1, 1), QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId()));
        QDateTime endDateTime(QDate(year, 12, 31), QTime(23, 59, 59, 0), QTimeZone(QTimeZone::systemTimeZoneId()));

        QList<QtOrganizer::QOrganizerItem> items = _manager->items(startDateTime, endDateTime, filter());
        addItemsToGrid(items);

        emit modelChanged();
    }
}

int YearGridModel::itemCount() const
{
    return _gridCells.size();
}

int YearGridModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return itemCount();
}

QVariant YearGridModel::data(const QModelIndex &index, int role) const
{
    //This method is not used, just required by base class
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

QQmlListProperty<YearDay> YearGridModel::items()
{
    return {this, nullptr, item_count, item_at};
}

int YearGridModel::item_count(QQmlListProperty<YearDay> *p)
{
    auto * model = dynamic_cast<YearGridModel*>(p->object);
    if (model)
        return model->_gridCells.size();
    return 0;
}

YearDay* YearGridModel::item_at(QQmlListProperty<YearDay> *p, int idx)
{
    auto * model = dynamic_cast<YearGridModel*>(p->object);
    if (model)
        return model->_gridCells[idx];
    return nullptr;
}

void YearGridModel::manageDataChanged() {
    //this one means big changes clear and rebuild data
//    qDebug("manageDataChanged");
    setYear(year());
}

void YearGridModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void YearGridModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("YGM::manageItemsChanged");
    removeItemsFromModel(itemIds);
//    qDebug("YGM::removed->add");
    addItemsToModel(itemIds);
//    qDebug("YGM::modelChanged");
    emit modelChanged();
}

void YearGridModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("manageItemsRemoved");
    removeItemsFromModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void YearGridModel::manageCollectionsAdded(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setYear(year());
}

void YearGridModel::manageCollectionsChanged(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setYear(year());
}

void YearGridModel::manageCollectionsRemoved(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setYear(year());
}

void YearGridModel::addEventToDate(YearEvent *event, QDate date) {
    int gridIndex = date.month()+GRID_HEIGHT*(_monthOffset[date.month()-1]+(date.day()-1));
    _gridCells[gridIndex]->addEvent(event);
}

void YearGridModel::addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items) {
    QDate endOfYear(_year, 12, 1);
    endOfYear.setDate(_year, 12, endOfYear.daysInMonth());
    for (const auto &item : items) {
        QtOrganizer::QOrganizerEventTime eventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        if (!eventTime.isEmpty() && eventTime.startDateTime().isValid()) {
            auto *event = new YearEvent();
            QDateTime startDateTime = eventTime.startDateTime();
            startDateTime.setTime(QTime(12,0,0,0));
            QDate startDate = startDateTime.date();
            QDateTime endDateTime = eventTime.endDateTime();
            endDateTime.setTime(QTime(12,0,0,0));
            QDate endDate = endDateTime.date();
            event->setDate(startDateTime);
            event->setDisplayLabel(item.displayLabel());
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
                addEventToDate(event, startDate);
//                qDebug() << "SDT: " << startDateTime << "SD: " << startDate << ", ED: " << endDate << ", EOY: " << endOfYear;
                startDate = startDate.addDays(1);
            } while (startDate < endDate && startDate < endOfYear);
        } else {
//            qDebug() << "ET: " << eventTime << ", I: " << item;
        }
    }
}

void YearGridModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    for (auto cell : _gridCells) {
        cell->removeEventsFromModel(itemIds);
    }
}

void YearGridModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);
//    qWarning() << "addItemsToModel" << items;
    addItemsToGrid(items);
}

