#ifndef CALENDARITEM_H
#define CALENDARITEM_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>

typedef enum {
    CalendarItemTypeUnknown,
    CalendarItemTypeDay,
    CalendarItemTypeEvent
} CalendarItemType;

class CalendarItem : public QObject
{
    Q_OBJECT

public:
    explicit CalendarItem(QObject *parent = Q_NULLPTR, CalendarItemType type=CalendarItemTypeUnknown);
    ~CalendarItem() override;

    CalendarItemType itemType();

private:
    CalendarItemType _type;
};

class CalendarDay : public CalendarItem
{
    Q_OBJECT
    Q_PROPERTY(QDateTime date READ date WRITE setDate NOTIFY dateChanged)

public:
    explicit CalendarDay(QObject *parent = Q_NULLPTR);
    ~CalendarDay() override;

    void setDate(const QDateTime &date);
    QDateTime date() const;

    Q_SIGNALS:
    void dateChanged();

private:
    QDateTime _date;
};


class CalendarEvent : public CalendarItem
{
    Q_OBJECT

    Q_PROPERTY(bool allDay READ isAllDay WRITE setAllDay NOTIFY valueChanged)
    Q_PROPERTY(QDateTime startDateTime READ startDateTime WRITE setStartDateTime NOTIFY valueChanged)
    Q_PROPERTY(QDateTime endDateTime READ endDateTime WRITE setEndDateTime NOTIFY valueChanged)
    Q_PROPERTY(QString itemId READ itemId WRITE setItemId NOTIFY itemChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY itemChanged)
    Q_PROPERTY(QString location READ location WRITE setLocation NOTIFY valueChanged)
    Q_PROPERTY(QString collectionId READ collectionId WRITE setCollectionId NOTIFY itemChanged)

public:
    explicit CalendarEvent(QObject *parent = Q_NULLPTR);
    ~CalendarEvent() override;

    void setAllDay(bool isAllDay);
    bool isAllDay() const;

    void setStartDateTime(const QDateTime &startDateTime);
    QDateTime startDateTime() const;

    void setEndDateTime(const QDateTime &endDateTime);
    QDateTime endDateTime() const;

    QString itemId() const;
    void setItemId(const QString &itemId);

    QString displayLabel() const;
    void setDisplayLabel(const QString &label);

    void setLocation(const QString &location);
    QString location() const;

    QString collectionId() const;
    void setCollectionId(const QString& collectionId);

    Q_SIGNALS:
    void valueChanged();
    void itemChanged();

private:
    QString _itemId;
    bool _isAllDay;
    QString _label;
    QString _location;
    QString _collectionId;
    QDateTime _startDateTime;
    QDateTime _endDateTime;
};

QML_DECLARE_TYPE(CalendarItem)
QML_DECLARE_TYPE(CalendarDay)
QML_DECLARE_TYPE(CalendarEvent)

#endif // CALENDARITEM_H
