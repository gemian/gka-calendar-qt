#ifndef YEARITEM_H
#define YEARITEM_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>

enum DayType { DayTypeInvalid, DayTypePast, DayTypeToday, DayTypeFuture, DayTypeHeading };

class YearEvent : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDateTime date READ date WRITE setDate NOTIFY itemChanged)
    Q_PROPERTY(QString itemId READ itemIdString NOTIFY itemChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY itemChanged)
    Q_PROPERTY(QChar symbol READ symbol WRITE setSymbol NOTIFY itemChanged)
    Q_PROPERTY(QString collectionId READ collectionId WRITE setCollectionId NOTIFY itemChanged)

public:
    explicit YearEvent(QObject *parent = Q_NULLPTR);
    ~YearEvent() override;

    void setDate(const QDateTime &date);
    QDateTime date() const;

    QString itemIdString() const;
    QtOrganizer::QOrganizerItemId itemId() const;
    void setItemId(const QtOrganizer::QOrganizerItemId &itemId);

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
    QString _displayLabel;
    QChar _symbol;
    QString _collectionId;
    QDateTime _date;
};

class YearDay : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int type READ type WRITE setType NOTIFY dayChanged)
    Q_PROPERTY(QDateTime date READ date WRITE setDate NOTIFY dayChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY dayChanged)
    Q_PROPERTY(QQmlListProperty<YearEvent> items READ items NOTIFY dayChanged)

public:
    explicit YearDay(QObject *parent = Q_NULLPTR);
    ~YearDay() override;

    void setType(int type);
    int type() const;

    void setDate(const QDateTime &date);
    QDateTime date() const;

    void setDisplayLabel(const QString &label);
    QString displayLabel() const;

    void addEvent(YearEvent *event);
    void clearEvents();

    QQmlListProperty<YearEvent> items();

    void removeEventsFromModel(const QList<QtOrganizer::QOrganizerItemId> &list);

Q_SIGNALS:
    void dayChanged();

private:
    static int item_count(QQmlListProperty<YearEvent> *p);
    static YearEvent * item_at(QQmlListProperty<YearEvent> *p, int idx);

private:
    int _type;
    QDateTime _date;
    QString _displayLabel;
    std::vector<YearEvent*> _events;
};

QML_DECLARE_TYPE(YearDay)
QML_DECLARE_TYPE(YearEvent)

#endif // YEARITEM_H
