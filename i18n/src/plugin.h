#ifndef CALENDARLISTMODELPLUGIN_H
#define CALENDARLISTMODELPLUGIN_H

#include <QtQml/QQmlEngine>
#include <QtQml/QQmlExtensionPlugin>

class UbuntuI18nPlugin : public QQmlExtensionPlugin
{
Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
    void initializeEngine(QQmlEngine *engine, const char *uri);

    // use this API only in tests!
    static void initializeContextProperties(QQmlEngine* engine);

};

#endif // CALENDARLISTMODELPLUGIN_H
