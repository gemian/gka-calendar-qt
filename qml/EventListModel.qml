/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file was part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4
import QtOrganizer 5.0

import "dateExt.js" as DateExt

OrganizerModel {
    id: eventModel
    manager:"eds"

    readonly property bool appIsActive: (Qt.application.state === Qt.ApplicationActive)

    property bool active: false
    property bool isLoading: false

    function collectionIsReadOnly(collection) {
        if (!collection)
            return false

        return collection.extendedMetaData("collection-readonly") === true ||
               collection.extendedMetaData("collection-sync-readonly") === true
    }

    function collectionIdIsWritable(collectionId) {
        console.log("isWritable:"+collectionId)
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if (cal.collectionId === collectionId) {
                return !collectionIsReadOnly(cal);
            }
        }
        console.log("isWritable: false")
        return false
    }

    function getCollections() {
        var cals = [];
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if (cal.extendedMetaData("collection-type") === "Calendar" ) {
                //print("collectionId: "+cal.collectionId)
                cals.push(cal);
            } else {
//                print("collectionId: "+cal.collectionId+", type: "+cal.extendedMetaData("collection-type")+", name: "+cal.name)
            }
        }
        cals.sort(eventModel._sortCollections)
        return cals;
    }

    function getWritableAndSelectedCollections() {
        var cals = [];
        var collections = eventModel.collections;
        for(var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            if( cal.extendedMetaData("collection-type") === "Calendar" &&
                    cal.extendedMetaData("collection-selected") === true &&
                    !collectionIsReadOnly(cal)) {
                cals.push(cal);
            }
        }
        cals.sort(eventModel._sortCollections);
        return cals
    }

    function getDefaultCollection() {
        var defaultCol = eventModel.defaultCollection;
        if (defaultCol && defaultCol.extendedMetaData("collection-selected") === true) {
            return defaultCol
        }

        var cals = getCollections();
        for(var i = 0 ; i < cals.length ; ++i) {
            var cal = cals[i]
            var val = cal.extendedMetaData("collection-selected")
            if (val === true) {
                return cal;
            }
        }

        return cals[0]
    }

    function setDefaultCollection( collectionId ) {
        var cals = getCollections();
         for(var i = 0 ; i < cals.length ; ++i) {
             var cal = cals[i]
             if( cal.collectionId === collectionId) {
                 cal.setExtendedMetaData("collection-default", true);
                 eventModel.saveCollection(cal);
                 return
             }
        }
    }

    function updateIfNecessary() {
        if (!autoUpdate) {
            update()
        }
    }

    filter: InvalidFilter { objectName: "invalidFilter" }

    onModelChanged: {
        isLoading = false
    }

    onFilterChanged: {
        updateIfNecessary()
    }

    onStartPeriodChanged: {
        isLoading = true
    }

    onAutoUpdateChanged: {
        if (autoUpdate) {
            eventModel.update()
        }
    }

    onActiveChanged: {
        if (active) {
            updateIfNecessary()
        }
    }

    Component.onCompleted: {
        if (active) {
            updateIfNecessary()
        }
//        console.log("Available Managers: " + availableManagers)
    }
}
