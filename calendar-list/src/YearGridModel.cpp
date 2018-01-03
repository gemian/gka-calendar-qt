#include "YearGridModel.h"

YearGridModel::YearGridModel(QObject *parent) : QAbstractListModel(parent) {

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

    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::dataChanged, this, &YearGridModel::manageDataChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsAdded, this, &YearGridModel::manageItemsAdded);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsChanged, this, &YearGridModel::manageItemsChanged);
    QObject::connect(_manager, &QtOrganizer::QOrganizerManager::itemsRemoved, this, &YearGridModel::manageItemsRemoved);

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

void YearGridModel::setCurrentDate(QDate date) {
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

        QDate today = QDate::currentDate();
        if (_currentDate.isValid()) {
            today = _currentDate;
        }

        for (int m = 1; m <= MONTHS_IN_YEAR; m++) {
            QDate date(year, m, 1);
            _monthOffset[m - 1] = date.dayOfWeek() - 1;

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
                    date.setDate(year, m, day);
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
                    if (day == 1 || day == date.daysInMonth() || (date.dayOfWeek() == 1 && day <= date.daysInMonth())) {
                        label = QString::number(day);
                    }
                } else {
                    cell->setType(DayTypeInvalid);
                }
                cell->setDisplayLabel(label);
            }
        }

        QDate yearBegin(year, 1, 1);
        QDate yearEnd(year, 12, 31);
        QDateTime startDateTime = QDateTime();
        startDateTime.setDate(yearBegin);
        QDateTime endDateTime = QDateTime();
        endDateTime.setDate(yearEnd);

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
            event->setDate(startDate);
            event->setDisplayLabel(item.displayLabel());
            event->setItemId(item.id());
            event->setCollectionId(item.collectionId().toString());
            do {
                addEventToDate(event, startDate);
                startDate = startDate.addDays(1);
            } while (startDate < endDate && startDate < endOfYear);
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
    qWarning() << "addItemsToModel" << items;
    addItemsToGrid(items);
}

