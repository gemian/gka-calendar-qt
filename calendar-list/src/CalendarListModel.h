#ifndef CALENDARLISTMODEL_H
#define CALENDARLISTMODEL_H

#include <QtCore>
#include <QtOrganizer>
#include <QtQml>
#include <deque>
#include <QtWidgets>
#include "CalendarListModel.h"
#include "CalendarItem.h"

#define CALENDARLISTMODELSHARED_EXPORT Q_DECL_EXPORT

class CALENDARLISTMODELSHARED_EXPORT CalendarListModel : public QAbstractListModel
{
Q_OBJECT
Q_PROPERTY(QDateTime focusDate READ focusDate WRITE setFocusDate NOTIFY focusDateChanged)
Q_PROPERTY(int focusIndex READ focusIndex WRITE setFocusIndex NOTIFY focusIndexChanged)
//    Q_PROPERTY(QString manager READ manager WRITE setManager NOTIFY managerChanged)
//    Q_PROPERTY(QString managerName READ managerName  NOTIFY managerChanged)
//    Q_PROPERTY(QStringList availableManagers READ availableManagers)
Q_PROPERTY(QQmlListProperty<CalendarItem> items READ items NOTIFY modelChanged)
Q_PROPERTY(int itemCount READ itemCount NOTIFY modelChanged)

public:
explicit CalendarListModel(QObject *parent = 0);
~CalendarListModel();

QDateTime focusDate() const;
void setFocusDate(const QDateTime& focusDate);

int focusIndex() const;
void setFocusIndex(const int focusIndex);

int itemCount() const;

Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

QQmlListProperty<CalendarItem> items();


signals:
void modelChanged();
void focusDateChanged();
void focusIndexChanged();

public slots:
void manageDataChanged();
void manageItemsAdded(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
void manageItemsChanged(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
void manageItemsRemoved(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

private:
static int item_count(QQmlListProperty<CalendarItem> *p);
static CalendarItem * item_at(QQmlListProperty<CalendarItem> *p, int idx);
QtOrganizer::QOrganizerItemIntersectionFilter filter();
void addItemsToEventsList(QList<QtOrganizer::QOrganizerItem> items,  QDateTime startDateTime,  QDateTime endDateTime);
void removeItemsFromModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);
void addItemsToModel(const QList<QtOrganizer::QOrganizerItemId> &itemIds);

private:
std::multimap<QDateTime, CalendarItem*> _items;
//may need to compare performance with std::vector?
//std::vector<CalendarItem*> m_items;

std::map<QString, CalendarEvent*> _events;
QDateTime _focusDate;
int _focusIndex;
QTimer _modelChangedTimer;
QTimer _focusDateChangedTimer;
QTimer _focusIndexChangedTimer;
QtOrganizer::QOrganizerManager *_manager;
};

QML_DECLARE_TYPE(CalendarListModel)

#endif // CALENDARLISTMODEL_H
