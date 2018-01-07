import QtQuick 2.7
import QtQuick.Controls 1.4

MenuBar {
    id: menuBar

    property var model;
    property var settings;

    Menu {
        title: qsTr("&File")
        id: fileMenu
        MenuItem {
            id: fileMenuQuit
            text: qsTr("&Quit (ctrl-q)")
            onTriggered: Qt.quit();
        }
    }

    Menu {
        title: qsTr("&Edit")
        id: editMenu
        MenuItem {
            id: editMenuAdd
            text: qsTr("&Add Item")
            onTriggered: {
                dialogLoader.setSource("EditEventDialog.qml", {"startDate":selectedDate, "model":organizerModel});
            }
        }
//        MenuItem {
//            id: editMenuEdit
//            text: qsTr("&Edit Item")
//            onTriggered: {
//                dialogLoader.setSource("EditEventDialog.qml", {"eventId": yearGridModel.items[daySelectedIndex].items[0].itemId, "model":organizerModel});
//            }
//        }
        MenuItem {
            id: editMenuCollections
            text: qsTr("&Calender Collections")
            onTriggered: {
                dialogLoader.setSource("CollectionsDialog.qml", {"model": menuBar.model});
            }
        }

//        MenuItem {
//            id: editMenuCut
//            text: qsTr("C&ut")
//        }
//        MenuItem {
//            id: editMenuCopy
//            text: qsTr("&Copy")
//        }
//        MenuItem {
//            id: editMenuPaste
//            text: qsTr("&Paste")
//        }
    }

    Menu {
        title: qsTr("&View")
        id: viewMenu
        MenuItem {
            id: viewMenuDay
            text: qsTr("&Day (ctrl-shift-D)")
            onTriggered: {
                alternateViewLoader.source = "DayViewGrid.qml"
            }
        }
        MenuItem {
            id: viewMenuWeek
            text: qsTr("&Week (ctrl-shift-W)")
            onTriggered: {
                alternateViewLoader.source = "WeekViewGrid.qml"
            }
        }
        MenuItem {
            id: viewMenuYear
            text: qsTr("&Year (ctrl-shift-Y)")
            onTriggered: {
                alternateViewLoader.source = "YearViewGrid.qml"
            }
        }
    }
    Menu {
        title: qsTr("&Go")
        id: goMenu
        MenuItem {
            id: goMenuToday
            text: qsTr("&Today (space)")
            onTriggered: {
                selectedDate = new Date()
                app.updateSelectedToToday()
            }
        }
    }
    Menu {
        title: qsTr("&Tools")
        id: toolsMenu
        MenuItem {
            id: toolsMenuSettings
            text: qsTr("&Settings")
            onTriggered: {
                dialogLoader.setSource("SettingsDialog.qml", {"settings": menuBar.settings});
            }
        }
    }
}
