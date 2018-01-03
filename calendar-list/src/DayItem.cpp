//
// Created by adam on 02/01/18.
//

#include "DayItem.h"

DayItem::DayItem(QObject *parent) : QObject(parent) {

}

DayItem::~DayItem() = default;

QString DayItem::itemId() const {
    return _itemId;
}

void DayItem::setItemId(const QString &itemId) {
    _itemId=itemId;
}

QTime DayItem::time() const {
    return _time;
}

void DayItem::setTime(const QTime &time) {
    _time=time;
}

QString DayItem::displayLabel() const {
    return _displayLabel;
}

void DayItem::setDisplayLabel(const QString &label) {
    _displayLabel = label;
}

QString DayItem::collectionId() const {
    return _collectionId;
}

void DayItem::setCollectionId(const QString &collectionId) {
    _collectionId = collectionId;
}

