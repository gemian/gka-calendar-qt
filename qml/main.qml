import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import org.gka.GKAToolkit 1.0
import org.gka.CalendarListModel 1.0
import "dateExt.js" as DateExt

ApplicationWindow {
    id: app

    signal updateSelectedToToday()
    signal updateSelectedToDate(var date)

    property var selectedDate: new Date()
    property bool showLunarCalendar
    property real appFontSize

    title: i18n.tr("Calendar")

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
        property alias x: app.x
        property alias y: app.y
        property alias width: app.width
        property alias height: app.height
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

    menuBar: MainMenu {
        id: menu
        model: organizerModel
        settings: settings
    }

    function jumpToDate() {
        dialogLoader.setSource("ZoomCalendar.qml", {"startDate": selectedDate, "selectedDate": selectedDate})
    }

    Action {
        id: quitAction
        text: i18n.tr("&Quit")
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit()
    }

    Action {
        id: addAction
        text: i18n.tr("&Add Item")
        shortcut: "Ctrl+Shift+a"
        onTriggered: {
            dialogLoader.setSource("EditEventDialog.qml", {"model":organizerModel, "startDate":selectedDate});
        }
    }

    Action {
        id: collectionsDialogAction
        text: i18n.tr("&Calender Collections")
        shortcut: "Ctrl+Shift+c"
        onTriggered: dialogLoader.setSource("CollectionsDialog.qml", {"model": organizerModel})
    }

    Action {
        id: dayViewAction
        text: i18n.tr("&Day")
        shortcut: "Ctrl+Shift+d"
        onTriggered: alternateViewLoader.source = "DayViewGrid.qml"
    }

    Action {
        id: weekViewAction
        text: i18n.tr("&Week")
        shortcut: "Ctrl+Shift+w"
        onTriggered: alternateViewLoader.source = "WeekViewGrid.qml"
    }

    Action {
        id: yearViewAction
        text: i18n.tr("&Year")
        shortcut: "Ctrl+Shift+y"
        onTriggered: alternateViewLoader.source = "YearViewGrid.qml"
    }

    Action {
        id: todoViewAction
        text: i18n.tr("&To-do")
        shortcut: "Ctrl+Shift+t"
        onTriggered: alternateViewLoader.source = "ToDoView.qml"
    }

    Action {
        id: zoomOutAction
        text: i18n.tr("Zoom &Out")
        shortcut: "Ctrl+Shift+m"
        onTriggered: {
            console.log (">appFontSize: " + app.appFontSize)
            if (settings.appFontSize > 8) {
                settings.appFontSize -= 1
            }
            console.log ("<appFontSize: " + app.appFontSize)
        }
    }

    Action {
        id: zoomInAction
        text: i18n.tr("Zoom &In")
        shortcut: "Ctrl+m"
        onTriggered: {
            console.log (">appFontSize: " + app.appFontSize)
            settings.appFontSize += 1
            console.log ("<appFontSize: " + app.appFontSize)
        }
    }

    Action {
        id: todayAction
        text: i18n.tr("&Today")
        shortcut: "Space"
        onTriggered: updateSelectedToToday()
    }

    Action {
        id: jumpToDateAction
        text: i18n.tr("&Jump to date")
        shortcut: "Ctrl+j"
        onTriggered: jumpToDate()
    }

    Action {
        id: settingsAction
        text: i18n.tr("&Settings")
        shortcut: "Ctrl+Shift+s"
        onTriggered: {
            dialogLoader.setSource("SettingsDialog.qml", {"settings": menuBar.settings});
        }
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
//                console.log("dialogLoader onStateChanged");
                if (status == Loader.Ready) {
                    //item.Open();
                }
            }
            onLoaded: {
//                console.log("dialogLoader onLoaded");
            }
            State {
                name: 'loaded';
                when: loader.status === Loader.Ready
            }
        }
        Connections {
            target: dialogLoader.item
            onSetSelectedDate: {
                app.updateSelectedToDate(date);
            }
        }
    }

    Label {
        id: defaultLabel
        visible: false
    }

    Component.onCompleted: {
        if (app.appFontSize == 0) {
            app.appFontSize = defaultLabel.font.pixelSize;
        }

        print("Screen.pixelDensity: "+Screen.pixelDensity);
        print("Screen.devicePixelRatio: "+Screen.devicePixelRatio);
        print("Screen.virtualX: "+Screen.virtualX);
        print("Screen.virtualY: "+Screen.virtualY);

    }
}
