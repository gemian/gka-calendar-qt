#include <WeekGridModel.h>
#include <QtWidgets/QApplication>
#include <WeekDay.h>
#include <WeekEvent.h>
#include "catch.hpp"
#include "smersh.h"

TEST_CASE("WeekEventTest") {
    auto *event = new WeekEvent();
    event->setDisplayLabel("Event Name");
    REQUIRE(event->displayLabel() == "Event Name");
    delete event;
}

TEST_CASE("WeekDayAddEventTest") {
    auto *event = new WeekEvent();
    event->setDisplayLabel("Event Name");
    auto *day = new WeekDay();
    day->setDate(QDateTime(QDate(2017,6,14)));
    day->addEvent(event);
    delete event;
    QQmlListProperty<WeekEvent> weekEventsList = day->items();
    REQUIRE(weekEventsList.count(&weekEventsList) == 1);
    delete day;
}

TEST_CASE("WeekDayAdd2EventsTest") {
    auto *event1 = new WeekEvent();
    event1->setDisplayLabel("Event Name");
    auto *event2 = new WeekEvent();
    event2->setDisplayLabel("Other Event");
    auto *day = new WeekDay();
    day->addEvent(event1);
    day->addEvent(event2);
    delete event1;
    delete event2;
    QQmlListProperty<WeekEvent> weekEventsList = day->items();
    REQUIRE(weekEventsList.count(&weekEventsList) == 2);
    delete day;
}

TEST_CASE("WeekGridSetStartOfWeekNoEventsTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *weekGridModel = new WeekGridModel(nullptr, "memory");
    weekGridModel->setStartOfWeek(QDateTime(QDate(2017,6,14),QTime()));

    QQmlListProperty<WeekDay> weekDaysList = weekGridModel->items();
    REQUIRE(weekDaysList.count(&weekDaysList) == 8);

    REQUIRE(!weekDaysList.at(&weekDaysList, 0)->date().isValid());
    for (int day=1; day<=DAYS_IN_WEEK; day++) {
        WeekDay *pDay = weekDaysList.at(&weekDaysList, day);
        QQmlListProperty<WeekEvent> dayEventsList = pDay->items();
        REQUIRE(dayEventsList.count(&dayEventsList) == 0);
    }

    delete weekGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}

TEST_CASE("WeekGridEventTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *weekGridModel = new WeekGridModel(nullptr, "memory");
    const QDate &date = QDate(2017, 6, 14);
    weekGridModel->setStartOfWeek(QDateTime(date,QTime()));

    QList<QtOrganizer::QOrganizerItem> items = QList<QtOrganizer::QOrganizerItem>();
    QtOrganizer::QOrganizerEvent item;
    item.setDisplayLabel("Event Name");
    item.setType(QtOrganizer::QOrganizerItemType::TypeEvent);
    item.setAllDay(true);
    QDateTime startDateTime = QDateTime();
    startDateTime.setDate(date);
    QDateTime endDateTime = QDateTime();
    endDateTime.setDate(date.addDays(2));
    item.setStartDateTime(startDateTime);
    item.setEndDateTime(endDateTime);
    QtOrganizer::QOrganizerCollection collection;
    collection.setMetaData(QtOrganizer::QOrganizerCollection::KeyName, "testcollection");
    collection.setExtendedMetaData("collection-type","Calendar");
    collection.setExtendedMetaData("collection-selected",true);
    weekGridModel->manager()->saveCollection(&collection);
    qDebug() << "collection.id" << collection.id();
    item.setCollectionId(collection.id());
    items.append(item);
    startDateTime = startDateTime.addDays(1);
    item.setStartDateTime(startDateTime);
    endDateTime = endDateTime.addDays(1);
    item.setEndDateTime(endDateTime);
    items.append(item);
    weekGridModel->manager()->saveItems(&items);

    QtOrganizer::QOrganizerItemId id1(items[0].id());
    QtOrganizer::QOrganizerItemId id2(items[1].id());
    qDebug() << "id1" << id1;

    qDebug() << "reload: " << weekGridModel->manager()->item(id1);

    int daysFromStartOfWeek = date.dayOfWeek();
    weekGridModel->setStartOfWeek(QDateTime(date.addDays(-daysFromStartOfWeek), QTime()));

    SECTION("Add") {
        QQmlListProperty<WeekDay> weekDaysList = weekGridModel->items();

        WeekDay *pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+1);
        QQmlListProperty<WeekEvent> dayEvents = pDay->items();

        int count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);

        WeekEvent *pEvent = dayEvents.at(&dayEvents, 0);
        REQUIRE(pEvent->displayLabel() == "Event Name");

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+2);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 2);

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+3);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);
    }

    SECTION("Remove") {
        QList<QtOrganizer::QOrganizerItemId> itemIds;
        itemIds.push_back(id1);
        weekGridModel->manageItemsRemoved(itemIds);

        QQmlListProperty<WeekDay> weekDaysList = weekGridModel->items();

        WeekDay *pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek);
        QQmlListProperty<WeekEvent> dayEvents = pDay->items();

        int count = dayEvents.count(&dayEvents);
        REQUIRE(count == 0);

        WeekEvent *pYear = dayEvents.at(&dayEvents, 0);
        REQUIRE(pYear->displayLabel() == "Event Name");

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+2);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+3);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);
    }

    SECTION("Changed") {
        item = weekGridModel->manager()->item(id1);
        item.setDisplayLabel("Event Changed");
        weekGridModel->manager()->saveItem(&item);

        QQmlListProperty<WeekDay> weekDaysList = weekGridModel->items();

        WeekDay *pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+1);
        QQmlListProperty<WeekEvent> dayEvents = pDay->items();

        int count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);
        qDebug() << "YearProperty.obj" << dayEvents.object;

        WeekEvent *pYear = dayEvents.at(&dayEvents, 0);
        qDebug() << "Year" << pYear;
        REQUIRE(pYear->displayLabel() == "Event Changed");

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+2);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 2);

        pDay = weekDaysList.at(&weekDaysList, daysFromStartOfWeek+3);
        dayEvents = pDay->items();
        count = dayEvents.count(&dayEvents);
        REQUIRE(count == 1);
    }

    delete weekGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}
