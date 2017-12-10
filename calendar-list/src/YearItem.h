#ifndef YEARITEM_H
#define YEARITEM_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>

class YearEvent : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY itemChanged)
    Q_PROPERTY(QString itemId READ itemId WRITE setItemId NOTIFY itemChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY itemChanged)
    Q_PROPERTY(QChar symbol READ symbol WRITE setSymbol NOTIFY itemChanged)
    Q_PROPERTY(QString collectionId READ collectionId WRITE setCollectionId NOTIFY itemChanged)

public:
    explicit YearEvent(QObject *parent = Q_NULLPTR);
    ~YearEvent() override;

    void setDate(const QDate &date);
    QDate date() const;

    QString itemId() const;
    void setItemId(const QString &itemId);

    QString displayLabel() const;
    void setDisplayLabel(const QString &label);

    void setSymbol(const QChar &symbol);
    QChar symbol() const;

    QString collectionId() const;
    void setCollectionId(const QString &collectionId);

Q_SIGNALS:
    void itemChanged();

private:
    QString _itemId;
    QString _displayLabel;
    QChar _symbol;
    QString _collectionId;
    QDate _date;
};

class YearDay : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dayChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY dayChanged)
    Q_PROPERTY(QQmlListProperty<YearEvent> items READ items NOTIFY dayChanged)

public:
    explicit YearDay(QObject *parent = Q_NULLPTR);
    ~YearDay() override;

    void setDate(const QDate &date);
    QDate date() const;

    void setDisplayLabel(const QString &label);
    QString displayLabel() const;

    void addEvent(YearEvent *event);
    void clearEvents();

    QQmlListProperty<YearEvent> items();

Q_SIGNALS:
    void dayChanged();

private:
    static int item_count(QQmlListProperty<YearEvent> *p);
    static YearEvent * item_at(QQmlListProperty<YearEvent> *p, int idx);

private:
    QDate _date;
    QString _displayLabel;
    std::vector<YearEvent*> _events;
};

QML_DECLARE_TYPE(YearDay)
QML_DECLARE_TYPE(YearEvent)

#endif // YEARITEM_H
