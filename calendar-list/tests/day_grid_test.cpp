#include <DayItem.h>
#include <DayGridModel.h>
#include <QtWidgets/QApplication>
#include "catch.hpp"
#include "smersh.h"

TEST_CASE("DayEventTest") {
    auto *event = new DayItem();
    event->setDisplayLabel("Event Name");
    REQUIRE(event->displayLabel() == "Event Name");
    delete event;
}

TEST_CASE("DayGridTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *dayGridModel = new DayGridModel();
    dayGridModel->setDate(QDate(2017,6,14));

    QQmlListProperty<DayItem> dayProperty = dayGridModel->items();

    for (int i=0; i<DAY_TIME_SLOTS; i++) {
        DayItem *pDay = dayProperty.at(&dayProperty, i);
        qWarning() << i << pDay->displayLabel() << pDay->time();
        REQUIRE(pDay->time().msecsSinceStartOfDay() > 0);
    }

    delete dayGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}


TEST_CASE("PopulatedDayGridTest") {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    auto *dayGridModel = new DayGridModel();
    const QDate &date = QDate(2017, 6, 14);
    dayGridModel->setDate(date);

    QList<QtOrganizer::QOrganizerItem> items = QList<QtOrganizer::QOrganizerItem>();
    QtOrganizer::QOrganizerEvent item;
    item.setDisplayLabel("Event Name");
    QtOrganizer::QOrganizerItemId id("a","b");
    item.setId(id);
    QDateTime startDateTime = QDateTime();
    startDateTime.setDate(date);
    startDateTime.setTime(QTime(12,30));
    QDateTime endDateTime = QDateTime();
    endDateTime.setDate(date);
    startDateTime.setTime(QTime(13,30));
    item.setStartDateTime(startDateTime);
    item.setEndDateTime(endDateTime);
    QByteArray byteArray = QByteArray().append("c");
    QtOrganizer::QOrganizerCollectionId collectionId("b", byteArray);
    item.setCollectionId(collectionId);
    items.append(item);
    startDateTime = startDateTime.addSecs(2*60*60);
    item.setStartDateTime(startDateTime);
    endDateTime = endDateTime.addSecs(3*60*60);
    item.setEndDateTime(endDateTime);
    items.append(item);
    startDateTime = startDateTime.addSecs(10*60);
    item.setStartDateTime(startDateTime);
    items.append(item);
    dayGridModel->addItemsToGrid(items);

    QQmlListProperty<DayItem> dayList = dayGridModel->items();

    for (int i=0; i<dayGridModel->itemCount(); i++) {
        DayItem *pDay = dayList.at(&dayList, i);
        qWarning() << i << pDay->displayLabel() << pDay->time();
        REQUIRE(pDay->time().msecsSinceStartOfDay() > 0);
    }

    REQUIRE(dayList.at(&dayList,3)->time().hour() == 9);
    REQUIRE(dayList.at(&dayList,3)->time().minute() == 0);
    REQUIRE(dayList.at(&dayList,7)->time().hour() == 13);
    REQUIRE(dayList.at(&dayList,7)->time().minute() == 30);
    REQUIRE(dayList.at(&dayList,8)->time().hour() == 14);
    REQUIRE(dayList.at(&dayList,8)->time().minute() == 0);
    REQUIRE(dayList.at(&dayList,10)->time().hour() == 15);
    REQUIRE(dayList.at(&dayList,10)->time().minute() == 40);

    delete dayGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}