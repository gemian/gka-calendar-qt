#include "YearItem.h"

YearEvent::YearEvent(QObject *parent) : QObject(parent), _date() {
}

YearEvent::~YearEvent() = default;

QString YearEvent::itemIdString() const {
    return _itemId.toString();
}

QtOrganizer::QOrganizerItemId YearEvent::itemId() const {
    return _itemId;
}

void YearEvent::setItemId(const QtOrganizer::QOrganizerItemId &itemId) {
    _itemId = itemId;
}

QString YearEvent::parentId() const {
    return _parentId;
}

void YearEvent::setParentId(const QString &parentId) {
    _parentId=parentId;
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

void YearEvent::setDate(const QDateTime &date) {
    _date = date;
}

QDateTime YearEvent::date() const {
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
    clearEvents();
}

void YearDay::setType(const int type) {
    _type = type;
}

int YearDay::type() const {
    return _type;
}

void YearDay::setDate(const QDateTime &date) {
    _date = date;
}

QDateTime YearDay::date() const {
    return _date;
}

void YearDay::setDisplayLabel(const QString &label) {
    _displayLabel = label;
}

QString YearDay::displayLabel() const {
    return _displayLabel;
}

void YearDay::addEvent(QPointer<YearEvent> event) {
    _events.emplace_back(event);
    rebuildDisplayLabel();
}

void YearDay::clearEvents() {
    foreach (auto event, _events) {
        event->deleteLater();
    }
    _events.clear();
}

QQmlListProperty<YearEvent> YearDay::items() {
    return {this, nullptr, item_count, item_at};
}

int YearDay::item_count(QQmlListProperty<YearEvent> *p) {
    auto * model = dynamic_cast<YearDay*>(p->object);
    if (model)
        return static_cast<int>(model->_events.size());
    return 0;
}

YearEvent* YearDay::item_at(QQmlListProperty<YearEvent> *p, int idx) {
    auto * model = dynamic_cast<YearDay*>(p->object);
    if (model)
        return model->_events[idx];
    return nullptr;
}

bool YearDay::removeEventsFromModel(const QList<QtOrganizer::QOrganizerItemId> &list) {
    bool eventsRemoved = false;
//    qDebug() << "YearDay::removeEventsFromModel" << list;
    for (auto it = _events.begin(); it != _events.end(); ) {
//        qDebug() << "it:" << (*it)->displayLabel();
        if (*it && list.contains((*it)->itemId())) {
            (*it)->deleteLater();
            it = _events.erase(it);
            eventsRemoved = true;
            rebuildDisplayLabel();
        } else {
            it++;
        }
    }
    return eventsRemoved;
}

void YearDay::rebuildDisplayLabel() {
    _displayLabel = "";
    for (int i = 0; i < _events.size() && i < 2; i++) {
        auto event = _events[i];
        const QString &initialLetter = event->displayLabel().left(1);
        if (i == 0) {
            _displayLabel = initialLetter;
        } else {
            _displayLabel.append(initialLetter);
        }
    }
}
