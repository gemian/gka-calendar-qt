import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt

ApplicationWindow {
    id: app

    property var weekStartDate: new Date().weekStart(1)
    property var weekEndDate: weekStartDate.addDays(6)
    property bool menuHidden: false

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

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            menuHidden = false
            fileMenu.open()
        }
    }

    FocusScope {
        id: mainView
        width: parent.width; height: parent.height

        Rectangle {
            width: menu.width
            height: menu.height
            color: "#7f8c8d"
        }

        Row {
            id: menu
            height: editButton.height
            width: parent.width
            enabled: !menuHidden

            Button {
                id: fileButton
                activeFocusOnTab: true
                focus: true
                text: qsTr("File")
                onClicked: fileMenu.open()
                KeyNavigation.right: editButton
                KeyNavigation.down: fileMenuQuit
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: fileButton.activeFocus || fileButton.down ? "#3daee9" : "#7f8c8d"
                }

                Menu {
                    focus: true
                    id: fileMenu
                    y: fileButton.height
                    MenuItem {
                        id: fileMenuQuit
                        focus: true
                        text: qsTr("Quit")
                        onTriggered: Qt.quit();
                    }
                }
            }

            Button {
                id: editButton
                activeFocusOnTab: true
                focus: true
                text: qsTr("Edit")
                onClicked: editMenu.open()
                KeyNavigation.down: editMenuCut
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: editButton.activeFocus || editButton.down ? "#3daee9" : "#7f8c8d"
                }
                Menu {
                    focus: true
                    id: editMenu
                    y: editButton.height
                    MenuItem {
                        id: editMenuCut
                        focus: true
                        text: qsTr("Cut")
                    }
                    MenuItem {
                        id: editMenuCopy
                        focus: true
                        text: qsTr("Copy")
                    }
                    MenuItem {
                        id: editMenuPaste
                        focus: true
                        text: qsTr("Paste")
                    }
                }
            }

            states: State {
                name: "hidden"; when: menuHidden
                PropertyChanges { target: menu; height: 0 }
            }

            transitions: Transition {
                NumberAnimation { properties: "height"; duration: 200 }
            }
        }

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

        WeekViewGrid {
            id: weekViewGrid
            anchors.top: menu.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        states:  [
            State {
                name: "showWeekView"
                PropertyChanges { target: weekViewGrid; visible: true }
            }
        ]

    }

    Timer {
        running: true
        repeat: false
        interval: 1500
        onTriggered: {
            menuHidden = true
        }
    }
}
