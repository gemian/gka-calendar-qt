
#include <QtCore>
#include "CalendarListModel.h"

#define FOCUS_WINDOW_START -10
#define FOCUS_WINDOW_SIZE 40

CalendarListModel::CalendarListModel(QObject *parent) : QAbstractListModel(parent)
{
    _focusIndexChangedTimer.setSingleShot(true);
    _focusIndexChangedTimer.setInterval(1);
    connect(&_focusIndexChangedTimer, &QTimer::timeout, this, &CalendarListModel::focusIndexChanged);

    QString manager = "memory";
    QStringList possibles = QtOrganizer::QOrganizerManager::availableManagers();
    if (possibles.contains("eds")) {
        manager = "eds";
    }
    QtOrganizer::QOrganizerManager* newManager = new QtOrganizer::QOrganizerManager(manager);
    if (!newManager || newManager->error()) {
        qCritical("error no new manager");
        delete newManager;
    } else {
        _manager = newManager;
    }

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &CalendarListModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &CalendarListModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &CalendarListModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &CalendarListModel::manageItemsRemoved);
}

CalendarListModel::~CalendarListModel() {
    delete _manager;
}

QDateTime CalendarListModel::focusDate() const
{
    return _focusDate;
}

QtOrganizer::QOrganizerItemIntersectionFilter CalendarListModel::filter() {
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
    return mainFilter;
}

void CalendarListModel::setFocusDate(const QDateTime &focusDate)
{
    _focusDate = focusDate;
    _items.clear();

    for (int i=FOCUS_WINDOW_START; i <= FOCUS_WINDOW_START+FOCUS_WINDOW_SIZE; i++) {
        CalendarDay *day = new CalendarDay();
        QDateTime date = focusDate.addDays(i);
        day->setDate(date);
        _items.insert(std::make_pair(date, day));
    }

    QDate start(focusDate.addDays(FOCUS_WINDOW_START).date());
    QDate end = start.addDays(FOCUS_WINDOW_SIZE);
    QDateTime startDateTime(start, QTime(0, 0, 0, 0));
    QDateTime endDateTime(end, QTime(23, 59, 59, 0));

    QList<QtOrganizer::QOrganizerItem> items = _manager->items(startDateTime, endDateTime, filter());

    addItemsToEventsList(items, startDateTime, endDateTime);

    std::multimap<QDateTime, CalendarItem*>::iterator fi = _items.find(focusDate);
    int pos = std::distance(_items.begin(), fi);
    _focusIndex = pos;

    emit modelChanged();
    _focusIndexChangedTimer.start();
}

void CalendarListModel::addItemsToEventsList(QList<QtOrganizer::QOrganizerItem> items,  QDateTime startDateTime,  QDateTime endDateTime)
{
    foreach (const QtOrganizer::QOrganizerItem &item, items)
    {
        QtOrganizer::QOrganizerEventTime eventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        if (!eventTime.isEmpty() && eventTime.startDateTime().isValid()) {
            CalendarEvent *event = new CalendarEvent();
            event->setAllDay(eventTime.isAllDay());
            event->setStartDateTime(eventTime.startDateTime());
            event->setEndDateTime(eventTime.endDateTime());
            auto recur = item.detail(QtOrganizer::QOrganizerItemDetail::TypeRecurrence);
            if (recur.isEmpty()) {
                event->setDisplayLabel(item.displayLabel() + " - rec empty");
            } else {
                event->setDisplayLabel(item.displayLabel() + " - has rec");
            }
            qWarning() << recur;
            for (auto ruleSet : recur.values()) {
                qWarning() << ruleSet;
                for (auto rule : ruleSet.value<QSet<QtOrganizer::QOrganizerRecurrenceRule>>()) {
                    qWarning() << "interval" << rule.interval() << ", frequency: "<< rule.frequency();
                }
            }
            event->setItemId(item.id().toString());
            event->setCollectionId(item.collectionId().toString());
            QtOrganizer::QOrganizerItemLocation location = item.detail(QtOrganizer::QOrganizerItemDetail::TypeLocation);
            if (!location.isEmpty()) {
                event->setLocation(location.label());
            }
            _events.insert(std::make_pair(event->itemId(), event));

            if (eventTime.endDateTime().isValid() && event->startDateTime() > startDateTime && event->endDateTime() < endDateTime) {
                QDateTime date = event->startDateTime();
                do {
                    _items.insert(std::make_pair(date, event));
                    date = date.addDays(1);
                    date.setTime(QTime(1,0,1,0));
                } while (date < event->endDateTime() && date < endDateTime);
            }
        }
    }
}

int CalendarListModel::focusIndex() const
{
    return _focusIndex;
}

void CalendarListModel::setFocusIndex(const int focusIndex)
{
    _focusIndex = focusIndex;
}

int CalendarListModel::itemCount() const
{
    return _items.size();
}

int CalendarListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return itemCount();
}

QVariant CalendarListModel::data(const QModelIndex &index, int role) const
{
    //This method is not used, just required by base class
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

QQmlListProperty<CalendarItem> CalendarListModel::items()
{
    return QQmlListProperty<CalendarItem>(this, 0, item_count, item_at);
}

int  CalendarListModel::item_count(QQmlListProperty<CalendarItem> *p)
{
    CalendarListModel* model = qobject_cast<CalendarListModel*>(p->object);
    if (model)
        return model->_items.size();
    return 0;
}

CalendarItem * CalendarListModel::item_at(QQmlListProperty<CalendarItem> *p, int idx)
{
    CalendarListModel* model = qobject_cast<CalendarListModel*>(p->object);
    if (model && idx >= 0 && idx < (int)model->_items.size())
    {
        std::multimap<QDateTime, CalendarItem*>::iterator ii = model->_items.begin();
        std::advance(ii, idx);
        return (*ii).second;
    }
    return 0;
}

void CalendarListModel::manageDataChanged() {
    //this one means big changes clear and rebuild data
    qDebug("manageDataChanged");
    setFocusDate(_focusDate);
}

void CalendarListModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void CalendarListModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsChanged");
    removeItemsFromModel(itemIds);
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void CalendarListModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsRemoved");
    removeItemsFromModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void CalendarListModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    foreach (QtOrganizer::QOrganizerItemId itemId, itemIds) {
        qDebug("foreach");
        std::map<QString, CalendarEvent*>::iterator it;
        it = _events.find(itemId.toString());
        if (it != _events.end()) {
            qDebug("founditemidinevents");
            std::pair<std::multimap<QDateTime, CalendarItem*>::iterator, std::multimap<QDateTime, CalendarItem*>::iterator> possibles;
            possibles = _items.equal_range(it->second->startDateTime());
            std::multimap<QDateTime, CalendarItem*>::iterator ii=possibles.first;
            while (ii!=possibles.second) {
                qDebug("founddateinitems");
                if (qobject_cast<CalendarEvent*>(ii->second)->itemId() == itemId.toString()) {
                    qDebug("eraseitem++");
                    _items.erase(ii++);
                } else {
                    qDebug("++");
                    ++ii;
                }
            }
            qDebug("eraseevent");
            _events.erase(it);
        }
    }
}

void CalendarListModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);

    QDate start(_focusDate.addDays(FOCUS_WINDOW_START).date());
    QDate end = start.addDays(FOCUS_WINDOW_SIZE);
    QDateTime startDateTime(start, QTime(0, 0, 0, 0));
    QDateTime endDateTime(end, QTime(23, 59, 59, 0));
    addItemsToEventsList(items, startDateTime, endDateTime);

}
