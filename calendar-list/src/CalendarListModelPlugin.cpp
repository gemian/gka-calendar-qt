#include <QtQml>
#include "CalendarListModelPlugin.h"
#include "CalendarItem.h"
#include "CalendarListModel.h"
#include "YearItem.h"
#include "YearGridModel.h"
#include "DayItem.h"
#include "DayGridModel.h"
#include "WeekDay.h"
#include "WeekEvent.h"
#include "WeekGridModel.h"

void CalendarListModelPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.gka.CalendarListModel"));

    qmlRegisterType<CalendarItem>(uri, 1, 0, "CalendarItem");
    qmlRegisterType<CalendarDay>(uri, 1, 0, "CalendarDay");
    qmlRegisterType<CalendarEvent>(uri, 1, 0, "CalendarEvent");
    qmlRegisterType<CalendarListModel>(uri, 1, 0, "CalendarListModel");
    qmlRegisterType<YearDay>(uri, 1, 0, "YearDay");
    qmlRegisterType<YearEvent>(uri, 1, 0, "YearEvent");
    qmlRegisterType<YearGridModel>(uri, 1, 0, "YearGridModel");
    qmlRegisterType<DayItem>(uri, 1, 0, "DayItem");
    qmlRegisterType<DayGridModel>(uri, 1, 0, "DayGridModel");
    qmlRegisterType<WeekDay>(uri, 1, 0, "WeekDay");
    qmlRegisterType<WeekEvent>(uri, 1, 0, "WeekEvent");
    qmlRegisterType<WeekGridModel>(uri, 1, 0, "WeekGridModel");
}

void CalendarListModelPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
