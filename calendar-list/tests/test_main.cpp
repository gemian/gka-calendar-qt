#define CATCH_CONFIG_MAIN

#include <QtCore/QTimer>
#include <QtWidgets/QApplication>
#include "smersh.h"
#include "catch.hpp"

bool smersh::KillAppAfterTimeout(int secs) const {
    QScopedPointer<QTimer> timer(new QTimer);
    timer->setSingleShot(true);
    bool ok = timer->connect(timer.data(), SIGNAL(timeout()), qApp, SLOT(quit()), Qt::QueuedConnection) != nullptr;
    timer->start(secs * 1000); // N seconds timeout
    timer.take()->setParent(qApp);
    return ok;
}