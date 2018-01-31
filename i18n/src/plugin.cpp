#include <QtQml>
#include "plugin.h"
#include "i18n_p.h"
#include "listener_p.h"
#include "livetimer_p.h"

void UbuntuI18nPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.gka.GKAToolkit"));

    qmlRegisterType<LiveTimer>(uri, 1, 0, "LiveTimer");

    qmlRegisterUncreatableType<UbuntuI18n>(uri, 1, 0, "i18n", QStringLiteral("Singleton object"));

}

void UbuntuI18nPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    initializeContextProperties(engine);
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}

void UbuntuI18nPlugin::initializeContextProperties(QQmlEngine *engine) {
    UbuntuI18n::instance(engine);

    QQmlContext* context = engine->rootContext();

    context->setContextProperty(QStringLiteral("i18n"), UbuntuI18n::instance());
    ContextPropertyChangeListener *i18nChangeListener = new ContextPropertyChangeListener(context, QStringLiteral("i18n"));
    QObject::connect(UbuntuI18n::instance(), SIGNAL(domainChanged()), i18nChangeListener, SLOT(updateContextProperty()));
    QObject::connect(UbuntuI18n::instance(), SIGNAL(languageChanged()), i18nChangeListener, SLOT(updateContextProperty()));
}
