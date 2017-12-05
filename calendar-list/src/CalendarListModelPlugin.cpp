#include <QtQml>
#include "CalendarListModelPlugin.h"
#include "CalendarItem.h"
#include "CalendarListModel.h"

void CalendarListModelPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("CalendarListModel"));

    qmlRegisterType<CalendarItem>(uri, 1, 0, "CalendarItem");
    qmlRegisterType<CalendarDay>(uri, 1, 0, "CalendarDay");
    qmlRegisterType<CalendarEvent>(uri, 1, 0, "CalendarEvent");
    qmlRegisterType<CalendarListModel>(uri, 1, 0, "CalendarListModel");
}

void CalendarListModelPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
