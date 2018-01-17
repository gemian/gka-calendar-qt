import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import "dateExt.js" as DateExt

ApplicationWindow {
    id: app

    signal updateSelectedToToday()
    signal updateSelectedToDate(var date)

    property var selectedDate: new Date()
    property bool showLunarCalendar
    property real appFontSize

    //Fullscreen on device
    height: {
        if (Screen.height === 1080 && Screen.width === 2160) {
            Screen.height
        } else {
            432
        }
    }
    width: {
        if (Screen.height === 1080 && Screen.width === 2160) {
            Screen.width
        } else {
            864
        }
    }
    visible: true

    Settings {
        id: settings
        property bool showLunarCalendar
        property real appFontSize
    }

    Binding {
        target: app
        property: "showLunarCalendar"
        value: settings.showLunarCalendar
        when: settings
    }

    Binding {
        target: app
        property: "appFontSize"
        value: settings.appFontSize
        when: settings
    }

    EventListModel {
        id: organizerModel
        objectName: "dayEventListModel"
        active: true
        property bool isReady: false
        property var itemIdToLoad: null
        property bool editItem: false

        function enabledColections() {
            var collectionIds = [];
            var collections = getCollections()
            for (var i=0; i < collections.length ; ++i) {
                var collection = collections[i]
                if (collection.extendedMetaData("collection-selected") === true) {
                    collectionIds.push(collection.collectionId);
                }
            }
            return collectionIds
        }

        function applyFilterFinal() {
            var collectionIds = enabledColections()
            collectionFilter.ids = collectionIds
            filter = Qt.binding(function() { return mainFilter; })
            isReady = true
        }

        sortOrders: [
            SortOrder{
                blankPolicy: SortOrder.BlanksFirst
                detail: Detail.EventTime
                field: EventTime.FieldStartDateTime
                direction: Qt.AscendingOrder
            }
        ]
        onCollectionsChanged: {
            var collectionIds = enabledColections()
            var oldCollections = collectionFilter.ids
            var needsUpdate = false
            if (collectionIds.length !== oldCollections.length) {
                needsUpdate = true
            } else {
                for(var i=oldCollections.length - 1; i >=0 ; i--) {
                    if (collectionIds.indexOf(oldCollections[i]) === -1) {
                        needsUpdate = true
                        break;
                    }
                }
            }

            if (needsUpdate) {
                collectionFilter.ids = collectionIds
                updateIfNecessary()
            }
        }

        Component.onCompleted: {
            //print("CalendarView.OrganiserModel.onCompleted");
            applyFilterFinal()
        }
    }

    menuBar: CalendarMenu {
        id: menu
        model: organizerModel
        settings: settings
    }

    function jumpToDate() {
        console.log("jump to date"+selectedDate)
        dialogLoader.setSource("ZoomCalendar.qml", {"startDate": selectedDate, "selectedDate": selectedDate})
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Ctrl+Shift+c"
        onActivated: dialogLoader.setSource("CollectionsDialog.qml", {"model": organizerModel})
    }

    Shortcut {
        sequence: "Ctrl+Shift+d"
        onActivated: alternateViewLoader.source = "DayViewGrid.qml"
    }

    Shortcut {
        sequence: "Ctrl+Shift+w"
        onActivated: alternateViewLoader.source = "WeekViewGrid.qml"
    }

    Shortcut {
        sequence: "Ctrl+Shift+y"
        onActivated: alternateViewLoader.source = "YearViewGrid.qml"
    }

    Shortcut {
        sequence: "Ctrl+Shift+m"
        onActivated: {
            console.log (">appFontSize: " + app.appFontSize)
            if (settings.appFontSize > 8) {
                settings.appFontSize -= 1
            }
            console.log ("<appFontSize: " + app.appFontSize)
        }
    }

    Shortcut {
        sequence: "Ctrl+m"
        onActivated: {
            console.log (">appFontSize: " + app.appFontSize)
            settings.appFontSize += 1
            console.log ("<appFontSize: " + app.appFontSize)
        }
    }

    Shortcut {
        sequence: "Ctrl+j"
        onActivated: app.jumpToDate()
    }

    FocusScope {
        id: mainView
        anchors.fill: parent

        UnionFilter {
            id: itemTypeFilter
            DetailFieldFilter{
                id: eventFilter
                detail: Detail.ItemType;
                field: Type.FieldType
                value: Type.Event
                matchFlags: Filter.MatchExactly
            }

            DetailFieldFilter{
                id: eventOccurenceFilter
                detail: Detail.ItemType;
                field: Type.FieldType
                value: Type.EventOccurrence
                matchFlags: Filter.MatchExactly
            }
        }

        CollectionFilter{
            id: collectionFilter
        }

        IntersectionFilter {
            id: mainFilter

            filters: [collectionFilter, itemTypeFilter]
        }

        InvalidFilter {
            id: invalidFilter
            objectName: "invalidFilter"
        }

        Loader {
            id: alternateViewLoader
            source: "WeekViewGrid.qml"
            visible: status == Loader.Ready
        }

        Loader {
            id: dialogLoader
            anchors.fill: parent
            visible: status == Loader.Ready
            onStatusChanged: {
                console.log("dialogLoader onStateChanged");
                if (status == Loader.Ready) {
                    //item.Open();
                }
            }
            onLoaded: {
                console.log("dialogLoader onLoaded");
            }
            State {
                name: 'loaded';
                when: loader.status === Loader.Ready
            }
        }
        Connections {
            target: dialogLoader.item
            onSetSelectedDate: {
                console.log(date)
                app.updateSelectedToDate(date);
            }
        }
    }

    Label {
        id: defaultLabel
        visible: false
    }

    Component.onCompleted: {
        print("app.showLunarCalendar: "+app.showLunarCalendar);
        print("settings.showLunarCalendar: "+settings.showLunarCalendar);
        print("app.appFontSize: "+app.appFontSize);
        print("settings.appFontSize: "+settings.appFontSize);
        if (app.appFontSize == 0) {
            app.appFontSize = defaultLabel.font.pixelSize;
        }

        print("Screen.pixelDensity: "+Screen.pixelDensity);
        print("Screen.devicePixelRatio: "+Screen.devicePixelRatio);
        print("Screen.virtualX: "+Screen.virtualX);
        print("Screen.virtualY: "+Screen.virtualY);

    }
}
