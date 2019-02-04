#ifndef GKA_CALENDAR_QT_WEEKGRIDMODEL_H
#define GKA_CALENDAR_QT_WEEKGRIDMODEL_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>
#include "WeekDay.h"

#define DAYS_IN_WEEK 7

class Q_DECL_EXPORT WeekGridModel : public QAbstractListModel {

Q_OBJECT

    Q_PROPERTY(QDateTime startOfWeek READ startOfWeek WRITE setStartOfWeek NOTIFY modelChanged)
    Q_PROPERTY(QQmlListProperty<WeekDay> items READ items NOTIFY modelChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY modelChanged)

public:
    explicit WeekGridModel(QObject *parent = 0, QString prefManager = "eds");

    ~WeekGridModel() override;

    void setStartOfWeek(QDateTime date);

    QDateTime startOfWeek();

    void addItemsToGrid(const QList<QtOrganizer::QOrganizerItem> &items);

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QQmlListProperty<WeekDay> items();

    int itemCount() const;

    QtOrganizer::QOrganizerManager *manager();

signals:

    void modelChanged();

public slots:

    void manageDataChanged();

    void manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

    void manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

    void manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

    void manageCollectionsAdded(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);

    void manageCollectionsChanged(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);

    void manageCollectionsRemoved(const QList<QtOrganizer::QOrganizerCollectionId> &itemIds);

private:
    static int item_count(QQmlListProperty<WeekDay> *p);

    static WeekDay *item_at(QQmlListProperty<WeekDay> *p, int idx);

    QtOrganizer::QOrganizerItemIntersectionFilter filter();

    void removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

    void addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

//int cellIndexForMonthAndColumn(int month, int c);
    WeekDay *ensureEmptyGridCell(int d);
    void addEventToDay(QPointer<WeekEvent> event, QDate date);

private:
    std::array<WeekDay *, DAYS_IN_WEEK+1> _gridCells;

    QtOrganizer::QOrganizerManager *_manager;
    QDate _startOfWeek;
    QDate _endOfWeek;

};

QML_DECLARE_TYPE(WeekGridModel)


#endif //GKA_CALENDAR_QT_WEEKGRIDMODEL_H
