#include "DayGridModel.h"

DayGridModel::DayGridModel(QObject *parent) : QAbstractListModel(parent) {
    QString manager = "memory";
    QStringList possibles = QtOrganizer::QOrganizerManager::availableManagers();
    if (possibles.contains("eds")) {
        manager = "eds";
    }
    QtOrganizer::QOrganizerManager *newManager = new QtOrganizer::QOrganizerManager(manager);
    if (newManager->error()) {
        qCritical("error no new manager");
        delete newManager;
    } else {
        _manager = newManager;
    }

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &DayGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &DayGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &DayGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &DayGridModel::manageItemsRemoved);
}

DayGridModel::~DayGridModel() {
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.empty();
    delete _manager;
}

void DayGridModel::setDate(QDate date) {
    _date = date;
    for (auto cell : _gridCells) {
        delete cell;
    }
    _gridCells.clear();
    for (int s = 0; s < DAY_TIME_SLOTS; s++) {
        auto time = QTime(DAY_TIME_SLOTS_START + s, 0);
        auto item = new DayItem();
        item->setTime(time);
        _gridCells.push_back(item);
    }

    QDateTime startDateTime(date, QTime(0, 0, 0, 0));
    QDateTime endDateTime(date, QTime(23, 59, 59, 0));

    QList<QtOrganizer::QOrganizerItem> items = _manager->items(startDateTime, endDateTime, filter());
    addItemsToGrid(items);
}

struct TimeFirstNotBefore: public std::binary_function<DayItem*, QTime, bool> {
    bool operator() (const DayItem *item, const QTime &time) const {
        return item->time() >= time;
    }
};

struct TimeSameHour: public std::binary_function<DayItem*, QTime, bool> {
    bool operator() (const DayItem *item, const QTime &time) const {
        return item->time().hour() >= time.hour();
    }
};

void DayGridModel::addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items) {
    for (const auto &item : items) {
        auto itemEventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        auto itemTimeV = itemEventTime.value(QtOrganizer::QOrganizerEventTime::FieldStartDateTime);
        if (itemTimeV.isValid()) {
            auto itemTime = itemTimeV.toTime();
            auto dayItem = new DayItem();
            dayItem->setTime(itemTime);
            dayItem->setDisplayLabel(item.displayLabel());
            dayItem->setItemId(item.id().toString());
            dayItem->setCollectionId(item.collectionId().toString());

            auto itAt = std::find_if(_gridCells.begin(), _gridCells.end(), std::bind2nd(TimeFirstNotBefore(), itemTime));
            if (itAt != _gridCells.end()) {
                auto itHour = std::find_if(_gridCells.begin(), _gridCells.end(), std::bind2nd(TimeSameHour(), itemTime));
                if ((*itHour)->time().hour() == itemTime.hour() && (*itHour)->itemId().isEmpty()) {
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

QDate DayGridModel::date() {
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
    qDebug("manageDataChanged");
    setDate(_date);
}

void DayGridModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsChanged");
    removeItemsFromModel(itemIds);
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsRemoved");
    removeItemsFromModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void DayGridModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
//    foreach (QtOrganizer::QOrganizerItemId itemId, itemIds) {
//        qDebug("foreach");
//        std::map<QString, CalendarEvent*>::iterator it;
//        it = _events.find(itemId.toString());
//        if (it != _events.end()) {
//            qDebug("founditemidinevents");
//            std::pair<std::multimap<QDateTime, CalendarItem*>::iterator, std::multimap<QDateTime, CalendarItem*>::iterator> possibles;
//            possibles = _items.equal_range(it->second->startDateTime());
//            std::multimap<QDateTime, CalendarItem*>::iterator ii=possibles.first;
//            while (ii!=possibles.second) {
//                qDebug("founddateinitems");
//                if (qobject_cast<CalendarEvent*>(ii->second)->itemId() == itemId.toString()) {
//                    qDebug("eraseitem++");
//                    _items.erase(ii++);
//                } else {
//                    qDebug("++");
//                    ++ii;
//                }
//            }
//            qDebug("eraseevent");
//            _events.erase(it);
//        }
//    }
}

void DayGridModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);
    qWarning() << "addItemsToModel" << items;
    addItemsToGrid(items);
}
