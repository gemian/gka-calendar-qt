#ifndef DAYITEM_H
#define DAYITEM_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>

class DayItem : public QObject {

    Q_OBJECT

    Q_PROPERTY(QString itemId READ itemId WRITE setItemId NOTIFY itemChanged)
    Q_PROPERTY(QTime time READ time WRITE setTime NOTIFY itemChanged)
    Q_PROPERTY(QString displayLabel READ displayLabel WRITE setDisplayLabel NOTIFY itemChanged)
    Q_PROPERTY(QString collectionId READ collectionId WRITE setCollectionId NOTIFY itemChanged)

public:
    explicit DayItem(QObject *parent = Q_NULLPTR);
    ~DayItem() override;

    QString itemId() const;
    void setItemId(const QString &itemId);

    QTime time() const;
    void setTime(const QTime &time);

    QString displayLabel() const;
    void setDisplayLabel(const QString &label);

    QString collectionId() const;
    void setCollectionId(const QString &collectionId);

    Q_SIGNALS:
    void itemChanged();

private:
    QString _itemId;
    QString _displayLabel;
    QTime _time;
    QString _collectionId;
};

#endif //DAYITEM_H
