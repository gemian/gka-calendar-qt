#ifndef GKA_CALENDAR_QT_WEEKEVENT_H
#define GKA_CALENDAR_QT_WEEKEVENT_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>

class WeekEvent : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool allDay READ isAllDay WRITE setAllDay NOTIFY itemChanged)
    Q_PROPERTY(QDateTime startDateTime READ startDateTime WRITE setStartDateTime NOTIFY itemChanged)
    Q_PROPERTY(QDateTime endDateTime READ endDateTime WRITE setEndDateTime NOTIFY itemChanged)
    Q_PROPERTY(QString location READ location WRITE setLocation NOTIFY itemChanged)
    Q_PROPERTY(QString itemId READ itemIdString NOTIFY itemChanged)
    Q_PROPERTY(QString parentId READ parentId NOTIFY itemChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY itemChanged)
    Q_PROPERTY(QChar symbol READ symbol WRITE setSymbol NOTIFY itemChanged)
    Q_PROPERTY(QString collectionId READ collectionId WRITE setCollectionId NOTIFY itemChanged)

public:
    explicit WeekEvent(QObject *parent = Q_NULLPTR);
    ~WeekEvent() override;

    void setAllDay(bool isAllDay);
    bool isAllDay() const;

    void setStartDateTime(const QDateTime &startDateTime);
    QDateTime startDateTime() const;

    void setEndDateTime(const QDateTime &endDateTime);
    QDateTime endDateTime() const;

    void setLocation(const QString &location);
    QString location() const;

    QString itemIdString() const;
    QtOrganizer::QOrganizerItemId itemId() const;
    void setItemId(const QtOrganizer::QOrganizerItemId &itemId);

    QString parentId() const;
    void setParentId(const QString &parentId);

    QString displayLabel() const;
    void setDisplayLabel(const QString &label);

    void setSymbol(const QChar &symbol);
    QChar symbol() const;

    QString collectionId() const;
    void setCollectionId(const QString &collectionId);

Q_SIGNALS:
    void itemChanged();

private:
    QtOrganizer::QOrganizerItemId _itemId;
    QString _parentId;
    QString _displayLabel;
    QChar _symbol;
    QString _collectionId;
    QDateTime _startDateTime;
    QDateTime _endDateTime;
    bool _allDay;
    QString _location;
};

QML_DECLARE_TYPE(WeekEvent)

#endif //GKA_CALENDAR_QT_WEEKEVENT_H
