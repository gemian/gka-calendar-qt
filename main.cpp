#include <QtWidgets>
#include <QtQml>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    //app.setFont(QFont{"Noto Sans", app.font().pointSize(), QFont::Normal});

    //app.setAttribute(Qt::AA_EnableHighDpiScaling);

    QQmlApplicationEngine engine("qml/main.qml");
    return app.exec();
}
