#include "CalendarItem.h"

CalendarItem::CalendarItem(QObject *parent, CalendarItemType type) : QObject(parent), _type(type)
{

}

CalendarItem::~CalendarItem()
{

}

CalendarItemType CalendarItem::itemType()
{
    return _type;
}

CalendarDay::CalendarDay(QObject *parent) : CalendarItem(parent, CalendarItemTypeDay)
{

}

CalendarDay::~CalendarDay()
{

}

void CalendarDay::setDate(const QDateTime &date)
{
    _date = date;
}

QDateTime CalendarDay::date() const
{
    return _date;
}

CalendarEvent::CalendarEvent(QObject *parent) : CalendarItem(parent, CalendarItemTypeEvent)
{

}

CalendarEvent::~CalendarEvent() {

}

void CalendarEvent::setAllDay(bool isAllDay)
{
    _isAllDay = isAllDay;
}

bool CalendarEvent::isAllDay() const
{
    return _isAllDay;
}

void CalendarEvent::setStartDateTime(const QDateTime &startDateTime)
{
    _startDateTime = startDateTime;
}

QDateTime CalendarEvent::startDateTime() const
{
    return _startDateTime;
}

void CalendarEvent::setEndDateTime(const QDateTime &endDateTime)
{
    _endDateTime = endDateTime;
}

QDateTime CalendarEvent::endDateTime() const
{
    return _endDateTime;
}

QString CalendarEvent::itemId() const
{
    return _itemId;
}

void CalendarEvent::setItemId(const QString &itemId)
{
    _itemId = itemId;
}

QString CalendarEvent::displayLabel() const
{
    return _label;
}

void CalendarEvent::setDisplayLabel(const QString &label)
{
    _label = label;
}

void CalendarEvent::setLocation(const QString &location)
{
    _location = location;
}

QString CalendarEvent::location() const
{
    return _location;
}

QString CalendarEvent::collectionId() const
{
    return _collectionId;
}

void CalendarEvent::setCollectionId(const QString &collectionId)
{
    _collectionId = collectionId;
}
