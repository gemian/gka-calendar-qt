import QtQuick 2.7
import QtQuick.Controls 1.4

MenuBar {
    id: menuBar

    Menu {
        title: qsTr("&File")
        id: fileMenu
        MenuItem {
            id: fileMenuQuit
            text: qsTr("&Quit")
            onTriggered: Qt.quit();
        }
    }

//    Menu {
//        title: qsTr("&Edit")
//        id: editMenu
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
//    }

    Menu {
        title: qsTr("&View")
        id: viewMenu
        MenuItem {
            id: viewMenuWeek
            text: qsTr("&Week")
            onTriggered: {
                alternateViewLoader.source = "WeekViewGrid.qml"
            }
        }
        MenuItem {
            id: viewMenuYear
            text: qsTr("&Year")
            onTriggered: {
                alternateViewLoader.source = "YearViewGrid.qml"
            }
        }
    }
}
