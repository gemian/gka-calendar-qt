#ifndef DAYGRIDMODEL_H
#define DAYGRIDMODEL_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>
#include "DayItem.h"

static const int DAY_TIME_SLOTS_START = 6;
static const int DAY_TIME_SLOTS_END = 11;
static const int DAY_TIME_SLOTS = 12 - DAY_TIME_SLOTS_START + DAY_TIME_SLOTS_END;

class Q_DECL_EXPORT DayGridModel : public QAbstractListModel {

    Q_OBJECT

    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY modelChanged)
    Q_PROPERTY(QQmlListProperty<DayItem> items READ items NOTIFY modelChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY modelChanged)

public:
    explicit DayGridModel(QObject *parent = nullptr);
    ~DayGridModel() override;

    void setDate(QDate date);
    QDate date();

    int itemCount() const;

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QQmlListProperty<DayItem> items();

    void addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items);

signals:
    void modelChanged();
    void itemsLoaded();

public slots:
    void manageDataChanged();
    void manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void manageCollectionsAdded(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);
    void manageCollectionsChanged(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);
    void manageCollectionsRemoved(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);

private:
    static int item_count(QQmlListProperty<DayItem> *p);
    static DayItem *item_at(QQmlListProperty<DayItem> *p, int idx);

    QtOrganizer::QOrganizerItemIntersectionFilter filter();
    void removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

private:
    std::vector<DayItem*> _gridCells;

    QtOrganizer::QOrganizerManager *_manager;
    QDate _date;

    QTimer modelChangedTimer;
};

QML_DECLARE_TYPE(DayGridModel)

#endif //DAYGRIDMODEL_H
