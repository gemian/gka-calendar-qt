//
// Created by adam on 10/12/17.
//

#include <YearGridModel.h>
#include <QtWidgets/QApplication>
#include "gtest/gtest.h"
#include "YearItem.h"

class YearGridTests : public testing::Test {
protected:
    void SetUp() override {

    }

    void TearDown() override {
    }
};

TEST_F(YearGridTests, YearEventTest) {
    YearEvent *event = new YearEvent();
    event->setDisplayLabel("Event Name");
    EXPECT_EQ(event->displayLabel(), "Event Name");
    delete event;
}

TEST_F(YearGridTests, YearDayAddEventTest) {
    YearEvent *event = new YearEvent();
    event->setDisplayLabel("Event Name");
    YearDay *day = new YearDay();
    day->setDisplayLabel("1");
    day->addEvent(event);
    delete event;
    EXPECT_EQ(day->displayLabel(), "E");
    delete day;
}

TEST_F(YearGridTests, YearDayAdd2EventsTest) {
    YearEvent *event1 = new YearEvent();
    event1->setDisplayLabel("Event Name");
    YearEvent *event2 = new YearEvent();
    event2->setDisplayLabel("Other Event");
    YearDay *day = new YearDay();
    day->setDisplayLabel("1");
    day->addEvent(event1);
    day->addEvent(event2);
    delete event1;
    delete event2;
    EXPECT_EQ(day->displayLabel(), "EO");
    delete day;
}

struct smersh {
    bool KillAppAfterTimeout(int secs=10) const;
};

bool smersh::KillAppAfterTimeout(int secs) const {
    QScopedPointer<QTimer> timer(new QTimer);
    timer->setSingleShot(true);
    bool ok = timer->connect(timer.data(),SIGNAL(timeout()),qApp,SLOT(quit()),Qt::QueuedConnection);
    timer->start(secs * 1000); // N seconds timeout
    timer.take()->setParent(qApp);
    return ok;
}

TEST_F(YearGridTests, YearGridSetYearTest) {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    YearGridModel *yearGridModel = new YearGridModel();
    yearGridModel->setCurrentDate(QDate(2017,6,14));
    yearGridModel->setYear(2017);

    QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

    for (int i=0; i<WEEK_BLOCKS_SHOWN; i++) {
        auto cellIndex = i*GRID_HEIGHT*DAYS_IN_WEEK;
        YearDay *pDay = dayProperty.at(&dayProperty, cellIndex);
        qWarning() << cellIndex << pDay->displayLabel();
        EXPECT_EQ(pDay->displayLabel(), "M");
    }

    for (int i=0; i<WEEK_BLOCKS_SHOWN; i++) {
        auto cellIndex = GRID_HEIGHT+i*GRID_HEIGHT*DAYS_IN_WEEK;
        YearDay *pDay = dayProperty.at(&dayProperty, cellIndex);
        qWarning() << cellIndex << pDay->displayLabel();
        EXPECT_EQ(pDay->displayLabel(), "T");
        EXPECT_EQ(pDay->type(), DayTypeHeading);
    }

    YearDay *pDay = dayProperty.at(&dayProperty, 2);
    EXPECT_EQ(pDay->type(), DayTypeInvalid);

    pDay = dayProperty.at(&dayProperty, 10*GRID_HEIGHT+1);
    EXPECT_EQ(pDay->type(), DayTypePast);

    //QDate(2017,6,14)
    pDay = dayProperty.at(&dayProperty, 6 + (16 * GRID_HEIGHT));
    EXPECT_EQ(pDay->type(), DayTypeToday);

    pDay = dayProperty.at(&dayProperty, 10*GRID_HEIGHT+10);
    EXPECT_EQ(pDay->type(), DayTypeFuture);

    pDay = dayProperty.at(&dayProperty, GRID_HEIGHT*GRID_WIDTH-1);
    EXPECT_EQ(pDay->type(), DayTypeInvalid);

    delete yearGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();
}



TEST_F(YearGridTests, YearGridAddEventTest) {
    int argc = 0;
    char **argv = nullptr;
    QApplication a(argc, argv);

    //prevent hanging if QMenu.exec() got called
    smersh().KillAppAfterTimeout(300);

    YearGridModel *yearGridModel = new YearGridModel();
    const QDate &date = QDate(2017, 6, 14);
    yearGridModel->setCurrentDate(date);
    yearGridModel->setYear(2017);

    QList<QtOrganizer::QOrganizerItem> items = QList<QtOrganizer::QOrganizerItem>();
    QtOrganizer::QOrganizerEvent item;
    item.setDisplayLabel("Event Name");
    QtOrganizer::QOrganizerItemId id("a","b");
    item.setId(id);
    QDateTime startDateTime = QDateTime();
    startDateTime.setDate(date);
    QDateTime endDateTime = QDateTime();
    endDateTime.setDate(date.addDays(2));
    item.setStartDateTime(startDateTime);
    item.setEndDateTime(endDateTime);
    QByteArray byteArray = QByteArray().append("c");
    QtOrganizer::QOrganizerCollectionId collectionId("b", byteArray);
    item.setCollectionId(collectionId);
    items.append(item);
    startDateTime = startDateTime.addDays(1);
    item.setStartDateTime(startDateTime);
    endDateTime = endDateTime.addMonths(1);
    item.setEndDateTime(endDateTime);
    items.append(item);
    yearGridModel->addItemsToGrid(items);

    QQmlListProperty<YearDay> dayProperty = yearGridModel->items();

    YearDay *pDay = dayProperty.at(&dayProperty, 6 + ((14+3) * GRID_HEIGHT));
    QQmlListProperty<YearEvent> yearProperty = pDay->items();

    int count = yearProperty.count(&yearProperty);
    EXPECT_EQ(count, 2);
    YearEvent *pYear = yearProperty.at(&yearProperty, 0);
    EXPECT_EQ(pYear->displayLabel(), "Event Name");

    pDay = dayProperty.at(&dayProperty, 6 + ((31+3) * GRID_HEIGHT));
    yearProperty = pDay->items();
    count = yearProperty.count(&yearProperty);
    EXPECT_EQ(count, 0);

    pDay = dayProperty.at(&dayProperty, 7 + ((1+5) * GRID_HEIGHT));
    yearProperty = pDay->items();
    count = yearProperty.count(&yearProperty);
    EXPECT_EQ(count, 1);

    delete yearGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();


}