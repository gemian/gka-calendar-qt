#include "YearItem.h"

YearEvent::YearEvent(QObject *parent) : QObject(parent), _date() {
}

YearEvent::~YearEvent() {
}

QString YearEvent::itemId() const {
    return _itemId;
}

void YearEvent::setItemId(const QString &itemId) {
    _itemId = itemId;
}

QString YearEvent::displayLabel() const {
    return _displayLabel;
}

void YearEvent::setDisplayLabel(const QString &label) {
    _displayLabel = label;
}

void YearEvent::setSymbol(const QChar &symbol) {
    _symbol = symbol;
}

QChar YearEvent::symbol() const {
    return _symbol;
}

void YearEvent::setDate(const QDate &date) {
    _date = date;
}

QDate YearEvent::date() const {
    return _date;
}

QString YearEvent::collectionId() const {
    return _collectionId;
}

void YearEvent::setCollectionId(const QString &collectionId) {
    _collectionId = collectionId;
}

YearDay::YearDay(QObject *parent) : QObject(parent), _date() {
}

YearDay::~YearDay() {
}

void YearDay::setType(const int type) {
    _type = type;
}

int YearDay::type() const {
    return _type;
}

void YearDay::setDate(const QDate &date) {
    _date = date;
}

QDate YearDay::date() const {
    return _date;
}

void YearDay::setDisplayLabel(const QString &label) {
    _displayLabel = label;
}

QString YearDay::displayLabel() const {
    return _displayLabel;
}

void YearDay::addEvent(YearEvent *event) {
    if (_events.size() < 2) {
        const QString &initialLetter = event->displayLabel().left(1);
        if (_events.size() == 0) {
            _displayLabel = initialLetter;
        } else {
            _displayLabel.append(initialLetter);
        }
    }
    _events.emplace_back(event);
}

void YearDay::clearEvents() {
    _events.clear();
}

QQmlListProperty<YearEvent> YearDay::items()
{
    return QQmlListProperty<YearEvent>(this, 0, item_count, item_at);
}

int YearDay::item_count(QQmlListProperty<YearEvent> *p)
{
    YearDay* model = qobject_cast<YearDay*>(p->object);
    if (model)
        return model->_events.size();
    return 0;
}

YearEvent* YearDay::item_at(QQmlListProperty<YearEvent> *p, int idx)
{
    YearDay* model = qobject_cast<YearDay*>(p->object);
    if (model)
        return model->_events[idx];
    return 0;
}
