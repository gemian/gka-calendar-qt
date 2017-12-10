import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import "dateExt.js" as DateExt

ApplicationWindow {
    id: app

    property var weekStartDate: new Date().weekStart(1)
    property var weekEndDate: weekStartDate.addDays(6)

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

    FocusScope {
        id: mainView
        width: parent.width; height: parent.height

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

        //Could use 'states' to switch between day/week/month/year views?
        //Will need to use loader to avoid bad startup experience

//        WeekViewGrid {
        YearViewGrid {
            id: weekViewGrid
            anchors.fill: parent
        }

        states:  [
            State {
                name: "showWeekView"
                PropertyChanges { target: weekViewGrid; visible: true }
            }
        ]

    }

}
