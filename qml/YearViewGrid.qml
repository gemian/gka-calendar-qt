import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    property var anchorDate: new Date()

    YearGridModel {
        id: yearGridModel
        year: anchorDate.getFullYear()

        onModelChanged: {
            print("YearGridModel.onModelChanged")
        }
    }

    Component {
        id: yearGridDelegate

        Rectangle {
            width: 20
            height: 20
            border.color: yearGridModel.items[index]?(yearGridModel.items[index].date !== null?"black":"transparent"):"transparent"
            border.width: 1
            color: "transparent"
            Label {
                width: 20
                height: 20
                text: yearGridModel.items[index]?yearGridModel.items[index].displayLabel:""

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        gridView.currentIndex = index
                        gridView.currentItem.forceActiveFocus()
                    }
                }
            }
        }
    }

    Component {
        id: gridHighlight
        Rectangle {
            width: gridView.cellWidth;
            height: gridView.cellHeight
            color: "lightsteelblue";
            border.color: "black"
            border.width: 1
//            x: view.currentItem.x
//            y: view.currentItem.y
//            Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
//            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }

        }
    }

    function shortMonth(m) {
        var date = new Date();
        date.setMonth(m);
        return date.toLocaleDateString(Qt.locale(), "MMM");
    }

    Component {
        id: gridHeader
        Column {
            Repeater {
                model: 13
                Label {
                    height: gridView.cellHeight
                    text: index===0?" ":shortMonth(index-1)
                }
            }
        }
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        delegate: yearGridDelegate
        header: gridHeader
        highlight: gridHighlight
        visible: true
        model: yearGridModel
        cellWidth: gridView.width/(5*7)
        cellHeight: gridView.height/13
        flow: GridView.FlowTopToBottom

        Component.onCompleted: {
            print("onCompleted")
            gridView.forceActiveFocus();
        }

    }

    QtObject {
        id: intern
    }
}
