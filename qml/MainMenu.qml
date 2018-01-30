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
            action: quitAction
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
            action: collectionsDialogAction
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
            action: zoomInAction
        }
        MenuItem {
            action: zoomOutAction
        }
        MenuSeparator {

        }
        MenuItem {
            action: dayViewAction
        }
        MenuItem {
            action: weekViewAction
        }
        MenuItem {
            action: yearViewAction
        }
        MenuItem {
            action: todoViewAction
        }
    }
    Menu {
        title: qsTr("&Go")
        id: goMenu
        MenuItem {
            action: todayAction
        }
        MenuItem {
            action: jumpToDateAction
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
