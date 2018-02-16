#include <QtWidgets>
#include <QtQml>
#include <sys/stat.h>
#include "config.h"

#define ENABLE_NLS

#ifdef ENABLE_NLS
# include <libintl.h>
# define _(x) gettext(x)
#else
# define _(x) (x)
#endif


int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

#ifdef ENABLE_NLS
    setlocale(LC_ALL, "");
    bindtextdomain(PACKAGE, LOCALEDIR);
    bind_textdomain_codeset(PACKAGE, "UTF-8");
    textdomain(PACKAGE);
#endif

    //app.setFont(QFont{"Noto Sans", app.font().pointSize(), QFont::Normal});

    //app.setAttribute(Qt::AA_EnableHighDpiScaling);

    std::string mainPath = calendarAppDirectory();
    mainPath += "/main.qml";
    QQmlApplicationEngine engine(mainPath.c_str());

    return app.exec();
}
