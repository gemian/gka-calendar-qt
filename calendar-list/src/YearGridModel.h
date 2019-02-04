#ifndef YEARGRIDMODEL_H
#define YEARGRIDMODEL_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>
#include "YearItem.h"

#define DAYS_IN_WEEK 7

static const int MONTHS_IN_YEAR = 12;
static const int WEEK_BLOCKS_SHOWN = 5;
static const int GRID_WIDTH = WEEK_BLOCKS_SHOWN*DAYS_IN_WEEK+2;
static const int MONTHS_PLUS_DOW = MONTHS_IN_YEAR+1;
static const int GRID_HEIGHT = MONTHS_PLUS_DOW;
static const int TOTAL_GRID_CELLS = GRID_WIDTH * GRID_HEIGHT;

class Q_DECL_EXPORT YearGridModel : public QAbstractListModel {

    Q_OBJECT

    Q_PROPERTY(int year READ year WRITE setYear NOTIFY modelChanged)
    Q_PROPERTY(QQmlListProperty<YearDay> items READ items NOTIFY modelChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY modelChanged)

public:
    explicit YearGridModel(QObject *parent = 0, QString prefManager="eds");
    ~YearGridModel() override;

    int year() const;
    void setYear(int year);
    void setCurrentDate(QDateTime date);
    void addItemsToGrid(QList<QtOrganizer::QOrganizerItem> items);

    int itemCount() const;

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QQmlListProperty<YearDay> items();

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
    static int item_count(QQmlListProperty<YearDay> *p);
    static YearDay *item_at(QQmlListProperty<YearDay> *p, int idx);

    QtOrganizer::QOrganizerItemIntersectionFilter filter();
    void removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
    void addEventToDate(QPointer<YearEvent> event, QDate date);

    int cellIndexForMonthAndColumn(int month, int c);

private:
    std::array<int, MONTHS_IN_YEAR> _monthOffset;
    std::array<YearDay*, TOTAL_GRID_CELLS> _gridCells;

    int _year;
    QtOrganizer::QOrganizerManager *_manager;
    QDateTime _currentDate;
};

QML_DECLARE_TYPE(YearGridModel)

#endif // YEARGRIDMODEL_H
