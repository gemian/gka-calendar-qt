#include "DayGridModel.h"

DayGridModel::DayGridModel(QObject *parent, QString prefManager) : QAbstractListModel(parent) {
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

    modelChangedTimer.setSingleShot(true);
    modelChangedTimer.setInterval(1);
    connect(&modelChangedTimer, &QTimer::timeout, this, &DayGridModel::modelChanged);

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &DayGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &DayGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &DayGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &DayGridModel::manageItemsRemoved);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsAdded, this, &DayGridModel::manageCollectionsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsChanged, this, &DayGridModel::manageCollectionsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::collectionsRemoved, this, &DayGridModel::manageCollectionsRemoved);

}

DayGridModel::~DayGridModel() {
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.empty();
    delete _manager;
}

QtOrganizer::QOrganizerManager *DayGridModel::manager() {
    return _manager;
}

void DayGridModel::setDate(QDateTime date) {
    _date = date;
    auto oldSize = _gridCells.size();
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.clear();

    _gridCells.push_back(new DayItem());
    for (int s = 0; s < DAY_TIME_SLOTS; s++) {
        auto time = QTime(DAY_TIME_SLOTS_START + s, 0);
        auto item = new DayItem();
        QDateTime dateTime = QDateTime(_date.date(),time,QTimeZone(QTimeZone::systemTimeZoneId()));
        item->setTime(dateTime);
        _gridCells.push_back(item);
    }

    QDateTime startDateTime(date.date(), QTime(0, 0, 0, 0), QTimeZone(QTimeZone::systemTimeZoneId()));
    QDateTime endDateTime(date.date(), QTime(23, 59, 59, 0), QTimeZone(QTimeZone::systemTimeZoneId()));

//    qDebug() << "sDT" << startDateTime << "eDT" << endDateTime;

    QList<QtOrganizer::QOrganizerItem> items = _manager->items(startDateTime, endDateTime, filter());

    addItemsToGrid(items);
    if (_gridCells.size() % 2 == 1) {
        _gridCells.push_back(new DayItem());
    }

    if (oldSize > _gridCells.size()) {
        beginRemoveRows(QModelIndex(), static_cast<int>(_gridCells.size() - 1), static_cast<int>(oldSize - 2));
        endRemoveRows();
    } else if (oldSize < _gridCells.size()) {
        beginInsertRows(QModelIndex(), static_cast<int>(oldSize - 1), static_cast<int>(_gridCells.size()) - 2);
        endInsertRows();
    }

    emit itemsLoaded();
    modelChangedTimer.start();
}

struct TimeFirstNotBefore: public std::binary_function<DayItem*, QDateTime, bool> {
    bool operator() (const DayItem *item, const QDateTime &time) const {
        return item->time().time() >= time.time();
    }
};

struct TimeSameHour: public std::binary_function<DayItem*, QDateTime, bool> {
    bool operator() (const DayItem *item, const QDateTime &time) const {
        return item->time().time().hour() >= time.time().hour();
    }
};

void DayGridModel::addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items) {
    for (const auto &item : items) {
        auto itemEventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        auto itemTimeStart = itemEventTime.value(QtOrganizer::QOrganizerEventTime::FieldStartDateTime);
        if (itemTimeStart.isValid()) {
            auto itemTimeEnd = itemEventTime.value(QtOrganizer::QOrganizerEventTime::FieldEndDateTime);
            if (itemTimeEnd.isValid()) {
//                qDebug() << "DayGridModel::addItemsToGrid S" << _date.daysTo(itemTimeStart.toDateTime());
//                qDebug() << "DayGridModel::addItemsToGrid E" << _date.daysTo(itemTimeEnd.toDateTime());
                if (_date.daysTo(itemTimeStart.toDateTime()) < 0 && _date.daysTo(itemTimeEnd.toDateTime()) <= 0) {
                    continue;
                }
            }

            auto itemTime = itemTimeStart.toDateTime();
            auto dayItem = new DayItem();
            dayItem->setTime(itemTime);
            dayItem->setDisplayLabel(item.displayLabel());
            dayItem->setItemId(item.id().toString());
            dayItem->setCollectionId(item.collectionId().toString());

            auto parentIdDetail = item.detail(QtOrganizer::QOrganizerItemDetail::TypeParent);
//            qDebug() << "N" << item.displayLabel() << "parentIdDetail:" << parentIdDetail;
            auto parentId = parentIdDetail.value(QtOrganizer::QOrganizerItemParent::FieldParentId);
//            qDebug() << "ParentId:" << parentId;
            if (parentId.isValid()) {
//                qDebug() << "ParentId:" << parentId.value<QtOrganizer::QOrganizerItemId>().toString();
                dayItem->setParentId(parentId.value<QtOrganizer::QOrganizerItemId>().toString());
            }

            auto itAt = std::find_if(_gridCells.begin(), _gridCells.end(), std::bind2nd(TimeFirstNotBefore(), itemTime));
            if (itAt != _gridCells.end()) {
                auto itHour = std::find_if(_gridCells.begin(), _gridCells.end(), std::bind2nd(TimeSameHour(), itemTime));
                if ((*itHour)->time().time().hour() == itemTime.time().hour() && (*itHour)->itemId().isEmpty()) {
                    (*itHour)->deleteLater();
                    (*itHour) = dayItem;
                } else {
                    _gridCells.insert(itAt, dayItem);
                }
            } else {
                _gridCells.push_back(dayItem);
            }
        }
    }
}

QDateTime DayGridModel::date() {
    return _date;
}

QtOrganizer::QOrganizerItemIntersectionFilter DayGridModel::filter() {
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

int DayGridModel::itemCount() const
{
    return static_cast<int>(_gridCells.size());
}

int DayGridModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return itemCount();
}

QVariant DayGridModel::data(const QModelIndex &index, int role) const
{
    //This method is not used, just required by base class
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

QQmlListProperty<DayItem> DayGridModel::items()
{
    return {this, nullptr, item_count, item_at};
}

int DayGridModel::item_count(QQmlListProperty<DayItem> *p)
{
    auto * model = dynamic_cast<DayGridModel*>(p->object);
    if (model)
        return static_cast<int>(model->_gridCells.size());
    return 0;
}

DayItem *DayGridModel::item_at(QQmlListProperty<DayItem> *p, int idx)
{
    auto *model = dynamic_cast<DayGridModel*>(p->object);
    if (model)
        return model->_gridCells[idx];
    return nullptr;
}

void DayGridModel::manageDataChanged() {
    //this one means big changes clear and rebuild data
//    qDebug("manageDataChanged");
    setDate(_date);
}

void DayGridModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("DGM::manageItemsChanged");
    removeItemsFromModel(itemIds);
    addItemsToModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    qDebug("DGM::manageItemsRemoved");
    removeItemsFromModel(itemIds);
//    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::manageCollectionsAdded(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setDate(date());
}

void DayGridModel::manageCollectionsChanged(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setDate(date());
}

void DayGridModel::manageCollectionsRemoved(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds) {
//    qDebug("manageCollectionsAdded");
    setDate(date());
}

struct DaySameId: public std::binary_function<DayItem*, QString, bool> {
    bool operator() (const DayItem *item, const QString &id) const {
        return item->itemId() == id;
    }
};

void DayGridModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    foreach (QtOrganizer::QOrganizerItemId itemId, itemIds) {
//        qDebug() << "foreach" << itemId.toString();
        auto it = std::find_if(_gridCells.begin(), _gridCells.end(), std::bind2nd(DaySameId(), itemId.toString()));
        if (it != _gridCells.end()) {
            (*it)->deleteLater();
            it = _gridCells.erase(it);
        }
    }
}

void DayGridModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);
//    qWarning() << "addItemsToModel" << items;
    addItemsToGrid(items);
}
