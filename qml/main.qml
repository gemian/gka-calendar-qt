import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import "dateExt.js" as DateExt

ApplicationWindow {
    id: app

    property var selectedDate: new Date()

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

    menuBar: CalendarMenu {
        id: menu
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
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

    }
}
