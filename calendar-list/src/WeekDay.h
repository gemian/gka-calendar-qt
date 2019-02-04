#ifndef GKA_CALENDAR_QT_WEEKDAY_H
#define GKA_CALENDAR_QT_WEEKDAY_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>
#include "WeekEvent.h"

class WeekDay : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int type READ type WRITE setType NOTIFY dayChanged)
    Q_PROPERTY(QDateTime date READ date WRITE setDate NOTIFY dayChanged)
    Q_PROPERTY(QQmlListProperty<WeekEvent> items READ items NOTIFY dayChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY dayChanged)

public:
    explicit WeekDay(QObject *parent = Q_NULLPTR);
    ~WeekDay() override;

    void setType(int type);
    int type() const;

    void setDate(const QDateTime &date);
    QDateTime date() const;

    void addEvent(QPointer<WeekEvent> event);
    void clearEvents();

    QQmlListProperty<WeekEvent> items();
    int itemCount() const;

    bool removeEventsFromModel(const QList<QtOrganizer::QOrganizerItemId> &list);

Q_SIGNALS:
    void dayChanged();

private:
    static int item_count(QQmlListProperty<WeekEvent> *p);
    static WeekEvent *item_at(QQmlListProperty<WeekEvent> *p, int idx);

private:
    int _type;
    QDateTime _date;
    QString _displayLabel;
    std::vector<QPointer<WeekEvent>> _events;

};

QML_DECLARE_TYPE(WeekDay)

#endif //GKA_CALENDAR_QT_WEEKDAY_H
