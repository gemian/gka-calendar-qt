import QtQuick 2.7
import QtQuick.Controls 1.4

MenuBar {
    id: menuBar

    property var model;
    property var settings;

    Menu {
        title: i18n.tr("&File")
        id: fileMenu
        MenuItem {
            action: quitAction
        }
    }

    Menu {
        title: i18n.tr("&Edit")
        id: editMenu
        MenuItem {
            id: editMenuAdd
            text: i18n.tr("&Add Item")
            onTriggered: {
                dialogLoader.setSource("EditEventDialog.qml", {"startDate":selectedDate, "model":organizerModel});
            }
        }
//        MenuItem {
//            id: editMenuEdit
//            text: i18n.tr("&Edit Item")
//            onTriggered: {
//                dialogLoader.setSource("EditEventDialog.qml", {"eventId": yearGridModel.items[daySelectedIndex].items[0].itemId, "model":organizerModel});
//            }
//        }
        MenuItem {
            action: collectionsDialogAction
        }

//        MenuItem {
//            id: editMenuCut
//            text: i18n.tr("C&ut")
//        }
//        MenuItem {
//            id: editMenuCopy
//            text: i18n.tr("&Copy")
//        }
//        MenuItem {
//            id: editMenuPaste
//            text: i18n.tr("&Paste")
//        }
    }

    Menu {
        title: i18n.tr("&View")
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
        title: i18n.tr("&Go")
        id: goMenu
        MenuItem {
            action: todayAction
        }
        MenuItem {
            action: jumpToDateAction
        }
    }
    Menu {
        title: i18n.tr("&Tools")
        id: toolsMenu
        MenuItem {
            id: toolsMenuSettings
            text: i18n.tr("&Settings")
            onTriggered: {
                dialogLoader.setSource("SettingsDialog.qml", {"settings": menuBar.settings});
            }
        }
    }
}
