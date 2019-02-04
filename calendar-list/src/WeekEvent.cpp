#include "WeekEvent.h"

WeekEvent::WeekEvent(QObject *parent) : QObject(parent) {
}

WeekEvent::~WeekEvent() = default;

QString WeekEvent::itemIdString() const {
    return _itemId.toString();
}

QtOrganizer::QOrganizerItemId WeekEvent::itemId() const {
    return _itemId;
}

void WeekEvent::setItemId(const QtOrganizer::QOrganizerItemId &itemId) {
    _itemId = itemId;
}

QString WeekEvent::parentId() const {
    return _parentId;
}

void WeekEvent::setParentId(const QString &parentId) {
    _parentId=parentId;
}

QString WeekEvent::displayLabel() const {
    return _displayLabel;
}

void WeekEvent::setDisplayLabel(const QString &label) {
    _displayLabel = label;
}

void WeekEvent::setSymbol(const QChar &symbol) {
    _symbol = symbol;
}

QChar WeekEvent::symbol() const {
    return _symbol;
}

QString WeekEvent::collectionId() const {
    return _collectionId;
}

void WeekEvent::setCollectionId(const QString &collectionId) {
    _collectionId = collectionId;
}

void WeekEvent::setAllDay(bool isAllDay) {
    _allDay = isAllDay;
}

bool WeekEvent::isAllDay() const {
    return _allDay;
}

void WeekEvent::setStartDateTime(const QDateTime &startDateTime) {
    _startDateTime = startDateTime;
}

QDateTime WeekEvent::startDateTime() const {
    return _startDateTime;
}

void WeekEvent::setEndDateTime(const QDateTime &endDateTime) {
    _endDateTime = endDateTime;
}

QDateTime WeekEvent::endDateTime() const {
    return _endDateTime;
}

void WeekEvent::setLocation(const QString &location) {
    _location = location;
}

QString WeekEvent::location() const {
    return _location;
}
