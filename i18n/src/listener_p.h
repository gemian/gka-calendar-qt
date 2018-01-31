/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef LISTENER_P_H
#define LISTENER_P_H

#include <QtCore/QObject>

class QQmlContext;

class Q_DECL_IMPORT ContextPropertyChangeListener : public QObject
{
    Q_OBJECT
public:
    explicit ContextPropertyChangeListener(QQmlContext* context, const QString& contextProperty);
    Q_SLOT void updateContextProperty();
    QQmlContext* m_context;
    QString m_contextProperty;
};


#endif // LISTENER_P_H
