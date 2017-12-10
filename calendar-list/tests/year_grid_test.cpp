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
    yearGridModel->setYear(2017);

    QQmlListProperty<YearDay> dayProperty = yearGridModel->items();
    for (int i=0; i<yearGridModel->itemCount(); i++) {
        YearDay *pDay = dayProperty.at(&dayProperty, i);
        if (pDay) {
            qWarning() << pDay->date();
        } else {
            qWarning() << "noDay for index:" << i;
        }
    }

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
    }

    delete yearGridModel;

    smersh().KillAppAfterTimeout(1);
    a.exec();


}