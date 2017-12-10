#include "YearGridModel.h"

YearGridModel::YearGridModel(QObject *parent) : QAbstractListModel(parent) {

    QString manager = "memory";
    QStringList possibles = QtOrganizer::QOrganizerManager::availableManagers();
    if (possibles.contains("eds")) {
        manager = "eds";
    }
    QtOrganizer::QOrganizerManager *newManager = new QtOrganizer::QOrganizerManager(manager);
    if (!newManager || newManager->error()) {
        qCritical("error no new manager");
        delete newManager;
    } else {
        _manager = newManager;
    }

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &YearGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &YearGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &YearGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &YearGridModel::manageItemsRemoved);

    _gridCells.fill(nullptr);

    QDate date(1,1,1);
//    qWarning() << date.dayOfWeek();
    date = date.addDays(1+DAYS_IN_WEEK-date.dayOfWeek());
//    qWarning() << date.dayOfWeek();
    for (int d = 0; d < DAYS_IN_WEEK; d++) {
        for (int g = 0; g < WEEK_BLOCKS_SHOWN; g++) {
            auto cellIndex = d * GRID_HEIGHT + g * GRID_HEIGHT * DAYS_IN_WEEK;
            auto cell = _gridCells[cellIndex] = new YearDay();
            const QString &dayOfWeek = date.toString("ddd").left(1);
            qWarning() << cellIndex << dayOfWeek;
            cell->setDisplayLabel(dayOfWeek);
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

void YearGridModel::setYear(const int year)
{
    _year = year;

    for (int m = 1; m <= MONTHS_IN_YEAR; m++) {
        QDate date(year, m, 1);
        _monthOffset[m-1] = date.dayOfWeek()-1;
        qWarning() << "monthoffset: " << _monthOffset[m-1];

        for (int c = 0; c < GRID_WIDTH; c++) {
            auto cellIndex = cellIndexForMonthAndColumn(m,c);
            qWarning() << "cellIndex: " << cellIndex;
            auto cell = _gridCells[cellIndex];
            if (cell) {
                cell->clearEvents();
            } else {
                _gridCells[cellIndex] = cell = new YearDay();
            }
            QString label(" ");
            if (c >= _monthOffset[m-1]) {
                auto day = 1+c-_monthOffset[m-1];
                date.setDate(year,m,day);
                cell->setDate(date);
                qWarning() << date;
                if (day == 1 || date.dayOfWeek() == 1 && day < date.daysInMonth()) {
                    label = QString::number(day);
                }
            }
            cell->setDisplayLabel(label);
        }
    }
    emit modelChanged();
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
    return QQmlListProperty<YearDay>(this, 0, item_count, item_at);
}

int YearGridModel::item_count(QQmlListProperty<YearDay> *p)
{
    YearGridModel* model = qobject_cast<YearGridModel*>(p->object);
    if (model)
        return model->_gridCells.size();
    return 0;
}

YearDay* YearGridModel::item_at(QQmlListProperty<YearDay> *p, int idx)
{
    YearGridModel* model = qobject_cast<YearGridModel*>(p->object);
    if (model)
        return model->_gridCells[idx];
    return 0;
}

void YearGridModel::manageDataChanged() {
    //this one means big changes clear and rebuild data
    qDebug("manageDataChanged");
    setYear(_year);
}

void YearGridModel::manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsAdded");
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void YearGridModel::manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsChanged");
    removeItemsFromModel(itemIds);
    addItemsToModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void YearGridModel::manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    qDebug("manageItemsRemoved");
    removeItemsFromModel(itemIds);
    qDebug("modelChanged");
    emit modelChanged();
}

void YearGridModel::addEventToDate(YearEvent *event, QDate date) {
    int gridIndex = GRID_WIDTH*(date.month()+1)+_monthOffset[date.month()]+date.day();
    _gridCells[gridIndex]->addEvent(event);
}

void YearGridModel::addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items) {
    QDate endOfYear(_year, 11, 1);
    endOfYear.setDate(_year, 11, endOfYear.daysInMonth());
    for (const auto &item : items) {
        QtOrganizer::QOrganizerEventTime eventTime = item.detail(QtOrganizer::QOrganizerItemDetail::TypeEventTime);
        if (!eventTime.isEmpty() && eventTime.startDateTime().isValid()) {
            auto *event = new YearEvent();
            QDate eventDate = eventTime.startDateTime().date();
            event->setDate(eventDate);
            event->setDisplayLabel(item.displayLabel());
            event->setItemId(item.id().toString());
            event->setCollectionId(item.collectionId().toString());

            do {
                addEventToDate(event, eventDate);
                eventDate = eventDate.addDays(1);
            } while (eventDate < eventTime.endDateTime().date() && eventDate < endOfYear);
        }
    }
}


void YearGridModel::removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {

}

void YearGridModel::addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds) {
    QList<QtOrganizer::QOrganizerItem> items = _manager->items(itemIds);
    addItemsToGrid(items);
}
