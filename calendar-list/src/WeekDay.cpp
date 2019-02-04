#include "WeekDay.h"

WeekDay::WeekDay(QObject *parent) : QObject(parent), _date() {
}

WeekDay::~WeekDay() {
    clearEvents();
}

void WeekDay::setType(const int type) {
    _type = type;
}

int WeekDay::type() const {
    return _type;
}

void WeekDay::setDate(const QDateTime &date) {
    _date = date;
}

QDateTime WeekDay::date() const {
    return _date;
}

void WeekDay::addEvent(QPointer<WeekEvent> event) {
    _events.emplace_back(event);
}

void WeekDay::clearEvents() {
    foreach (auto event, _events) {
        event->deleteLater();
    }
    _events.clear();
}

int WeekDay::itemCount() const {
    return _events.size();
}

QQmlListProperty<WeekEvent> WeekDay::items() {
    return {this, nullptr, item_count, item_at};
}

int WeekDay::item_count(QQmlListProperty<WeekEvent> *p) {
    auto * model = dynamic_cast<WeekDay*>(p->object);
    if (model)
        return static_cast<int>(model->_events.size());
    return 0;
}

WeekEvent* WeekDay::item_at(QQmlListProperty<WeekEvent> *p, int idx) {
    auto * model = dynamic_cast<WeekDay*>(p->object);
    if (model)
        return model->_events[idx];
    return nullptr;
}

bool WeekDay::removeEventsFromModel(const QList<QtOrganizer::QOrganizerItemId> &list) {
    bool eventsRemoved = false;
//    qDebug() << "YearDay::removeEventsFromModel" << list;
    for (auto it = _events.begin(); it != _events.end(); ) {
//        qDebug() << "it:" << (*it)->displayLabel();
        if (*it && list.contains((*it)->itemId())) {
            (*it)->deleteLater();
            it = _events.erase(it);
            eventsRemoved = true;
        } else {
            it++;
        }
    }
    return eventsRemoved;
}

