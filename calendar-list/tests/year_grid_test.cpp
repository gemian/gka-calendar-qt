//
// Created by adam on 10/12/17.
//

#include <YearGridModel.h>
#include <QtWidgets/QApplication>
#include "catch.hpp"
#include "smersh.h"

TEST_CASE("YearEventTest") {
    auto *event = new YearEvent();
    event->setDisplayLabel("Event Name");
    REQUIRE(event->displayLabel() == "Event Name");
    delete event;
}

TEST_CASE("YearDayAddEventTest") {
    auto *event = new YearEvent();
    event->setDisplayLabel("Event Name");
    auto *day = new YearDay();
    day->setDisplayLabel("1");
    day->addEvent(event);
    delete event;
    REQUIRE(day->displayLabel() == "E");
    delete day;
}

TEST_CASE("YearDayAdd2EventsTest") {
    auto *event1 = new YearEvent();
    event1->setDisplayLabel("Event Name");
    auto *event2 = new YearEvent();
    event2->setDisplayLabel("Other Event");
    auto *day = new YearDay();
    day->setDisplayLabel("1");
    day->addEvent(event1);
    day->addEvent(event2);
    delete event1;
    delete event2;
    REQUIRE(day->displayLabel() == "EO");
    delete day;
}

TEST_CASE("YearGridSetYearTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *yearGridModel = new YearGridModel(nullptr, "memory");
    yearGridModel->setCurrentDate(QDateTime(QDate(2017,6,14),QTime()));
    yearGridModel->setYear(2017);

    QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

    for (int i=0; i<WEEK_BLOCKS_SHOWN; i++) {
        auto cellIndex = i*GRID_HEIGHT*DAYS_IN_WEEK;
        YearDay *pDay = dayProperty.at(&dayProperty, cellIndex);
        qWarning() << cellIndex << pDay->displayLabel();
        REQUIRE(pDay->displayLabel() == "M");
    }

    for (int i=0; i<WEEK_BLOCKS_SHOWN; i++) {
        auto cellIndex = GRID_HEIGHT+i*GRID_HEIGHT*DAYS_IN_WEEK;
        YearDay *pDay = dayProperty.at(&dayProperty, cellIndex);
        qWarning() << cellIndex << pDay->displayLabel();
        REQUIRE(pDay->displayLabel() == "T");
        REQUIRE(pDay->type() == DayTypeHeading);
    }

    YearDay *pDay = dayProperty.at(&dayProperty, 2);
    REQUIRE(pDay->type() == DayTypeInvalid);

    pDay = dayProperty.at(&dayProperty, 10*GRID_HEIGHT+1);
    REQUIRE(pDay->type() == DayTypePast);

    //QDate(2017,6,14)
    pDay = dayProperty.at(&dayProperty, 6 + (16 * GRID_HEIGHT));
    REQUIRE(pDay->type() == DayTypeToday);

    pDay = dayProperty.at(&dayProperty, 10*GRID_HEIGHT+10);
    REQUIRE(pDay->type() == DayTypeFuture);

    pDay = dayProperty.at(&dayProperty, GRID_HEIGHT*GRID_WIDTH-1);
    REQUIRE(pDay->type() == DayTypeInvalid);

    delete yearGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}

TEST_CASE("YearGridEventTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *yearGridModel = new YearGridModel(nullptr, "memory");
    const QDate &date = QDate(2017, 6, 14);

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
    yearGridModel->manager()->saveCollection(&collection);
    qDebug() << "collection.id" << collection.id();
//    collection.setId(collection.id());
    item.setCollectionId(collection.id());
    items.append(item);
    startDateTime = startDateTime.addDays(1);
    item.setStartDateTime(startDateTime);
    endDateTime = endDateTime.addMonths(1);
    item.setEndDateTime(endDateTime);
    items.append(item);
    yearGridModel->manager()->saveItems(&items);

    QtOrganizer::QOrganizerItemId id1(items[0].id());
    QtOrganizer::QOrganizerItemId id2(items[1].id());
    qDebug() << "id1" << id1;

    qDebug() << "reload: " << yearGridModel->manager()->item(id1);

    yearGridModel->setCurrentDate(QDateTime(date,QTime()));
    yearGridModel->setYear(2017);

    SECTION("add") {
        QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

        YearDay *pDay = dayProperty.at(&dayProperty, 6 + ((14+3) * GRID_HEIGHT));
        QQmlListProperty<YearEvent> yearProperty = pDay->items();

        int count = yearProperty.count(&yearProperty);
        REQUIRE(count == 2);

        YearEvent *pYear = yearProperty.at(&yearProperty, 0);
        REQUIRE(pYear->displayLabel() == "Event Name");

        pDay = dayProperty.at(&dayProperty, 6 + ((31+3) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 0);

        pDay = dayProperty.at(&dayProperty, 7 + ((1+5) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 1);
    }

    SECTION("Remove") {
        QList<QtOrganizer::QOrganizerItemId> itemIds;
        itemIds.push_back(id1);
        yearGridModel->manageItemsRemoved(itemIds);

        QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

        YearDay *pDay = dayProperty.at(&dayProperty, 6 + ((14+3) * GRID_HEIGHT));
        QQmlListProperty<YearEvent> yearProperty = pDay->items();

        int count = yearProperty.count(&yearProperty);
        REQUIRE(count == 1);

        YearEvent *pYear = yearProperty.at(&yearProperty, 0);
        REQUIRE(pYear->displayLabel() == "Event Name");

        pDay = dayProperty.at(&dayProperty, 6 + ((31+3) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 0);

        pDay = dayProperty.at(&dayProperty, 7 + ((1+5) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 1);
    }

    SECTION("Changed") {
        item = yearGridModel->manager()->item(id1);
        item.setDisplayLabel("Event Changed");
        yearGridModel->manager()->saveItem(&item);

        QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

        YearDay *pDay = dayProperty.at(&dayProperty, 6 + ((14+3) * GRID_HEIGHT));
        QQmlListProperty<YearEvent> yearProperty = pDay->items();

        int count = yearProperty.count(&yearProperty);
        REQUIRE(count == 2);
        qDebug() << "YearProperty.obj" << yearProperty.object;

        YearEvent *pYear = yearProperty.at(&yearProperty, 0);
        qDebug() << "Year" << pYear;
        REQUIRE(pYear->displayLabel() == "Event Name");

        pDay = dayProperty.at(&dayProperty, 6 + ((31+3) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 0);

        pDay = dayProperty.at(&dayProperty, 7 + ((1+5) * GRID_HEIGHT));
        yearProperty = pDay->items();
        count = yearProperty.count(&yearProperty);
        REQUIRE(count == 1);
    }

    delete yearGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}

