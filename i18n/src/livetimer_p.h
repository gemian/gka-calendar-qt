/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef LIVETIMER_P_H
#define LIVETIMER_P_H

#include <QtCore/QDateTime>
#include <QtCore/QObject>

class Q_DECL_IMPORT LiveTimer : public QObject
{
    Q_OBJECT
    Q_ENUMS(Frequency)
    Q_PROPERTY(Frequency frequency READ frequency WRITE setFrequency NOTIFY frequencyChanged)
    Q_PROPERTY(QDateTime relativeTime READ relativeTime WRITE setRelativeTime NOTIFY relativeTimeChanged)
public:
    explicit LiveTimer(QObject *parent = 0);
    ~LiveTimer();

    enum Frequency {
        Disabled = 0,
        Second = 1,
        Minute = 2,
        Hour = 3,
        Relative = 4
    };

    Frequency frequency() const { return m_frequency; }
    void setFrequency(Frequency frequency);

    QDateTime relativeTime() const { return m_relativeTime; }
    void setRelativeTime(const QDateTime& relativeTime);

    Frequency effectiveFrequency() const { return m_effectiveFrequency; }

Q_SIGNALS:
    void frequencyChanged();
    void relativeTimeChanged();

    void trigger();

private:
    void registerTimer();
    void unregisterTimer();
    void setEffectiveFrequency(Frequency frequency);

    Frequency m_frequency;
    Frequency m_effectiveFrequency;
    QDateTime m_relativeTime;
    quint64 m_lastUpdate;

    friend class SharedLiveTimer;
};

#endif // LIVETIMER_P_H
