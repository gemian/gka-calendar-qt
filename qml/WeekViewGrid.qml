import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt

FocusScope {
    id: weekViewContainer

    property var weekStartDate: new Date().weekStart(1)
    property var weekEndDate: weekStartDate.addDays(6)
    property int daySelectedIndex: 1
    property int dayChildSelectedIndex: 0
    property int childrenCompleted: 0
    focus: true

    function updateGridViewWithDaySelection() {
        gridView.currentIndex = daySelectedIndex
        gridView.currentItem.forceActiveFocus()
        console.log("setFocus dLVcI: "+dayListView.currentIndex+", dLVc: "+dayListView.count)
    }

    function updateGridViewToToday() {
        console.log("updateGridViewToToday");
        var today = new Date();
        var offset = new Date().weekStartOffset(1);
        weekStartDate = today.addDays(-offset);
        if (daySelectedIndex !== offset+1 || !gridView.currentItem.activeFocus) {
            daySelectedIndex = offset+1;
            dayChildSelectedIndex = 0;
            updateGridViewWithDaySelection();
        }
    }

    Timer {
        running: true
        repeat: false
        interval: 1000
        onTriggered: {
            updateGridViewToToday();
        }
    }

    Rectangle {
        width: mainView.width
        height: mainView.height
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#193441" }
            GradientStop { position: 1.0; color: Qt.darker("#193441") }
        }

        Loader {
            id: dialogLoader
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

        GridView {
            id: gridView
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            cellWidth: gridView.width/2
            cellHeight: gridView.height/4
            flow: GridView.FlowTopToBottom
            focus: true
//            interactive: false

            model: 8
            delegate: WeekViewDayItem {
                itemDate: weekStartDate.addDays(index-1)
                showHeader: (index === 0)
                dateOnLeft: (index < 4)
            }

            Component.onCompleted: {
                console.log("mainView.width"+mainView.width)
                console.log("weekViewContainer.width"+weekViewContainer.width)
                console.log("parent.width"+parent.width)
                console.log("gridView.width"+gridView.width)
                internal.initialContentX = gridView.contentX
                console.log("initialcontentX"+internal.initialContentX)
                console.log("contentXactionOn"+internal.contentXactionOn)
            }
            Keys.onPressed: {
                console.log("[YGV]key:"+event.key)
            }
            onDragEnded: {
                console.log("[DragEnd]contentX:"+contentX)
                if (contentX > internal.initialContentX+internal.contentXactionOn) {
                    weekStartDate = weekStartDate.addDays(7);
                } else if (contentX < internal.initialContentX-internal.contentXactionOn) {
                    weekStartDate = weekStartDate.addDays(-7);
                }
            }
            onContentXChanged: {
                console.log("[YGV]contentX:"+contentX)
            }
        }

        Label {
            id: defaultLabel
            visible: false
        }

        Label {
            id: lastWeek
            text: qsTr("Week %1").arg(weekStartDate.weekNumber(1)>1?weekStartDate.weekNumber(1)-1:52);
            font.pixelSize: defaultLabel.font.pixelSize * 2
            font.bold: true
            color: gridView.contentX < internal.initialContentX-internal.contentXactionOn ? "#3498db" : "#bdc3c7"
            rotation: -90
            x: 0
            y: (parent.height-lastWeek.height)/2
            opacity: (internal.initialContentX - gridView.contentX) / internal.contentXactionOn
        }

        Label {
            id: nextWeek
            text: qsTr("Week %1").arg(weekStartDate.weekNumber(1)<52?weekStartDate.weekNumber(1)+1:1);
            font.pixelSize: defaultLabel.font.pixelSize * 2
            font.bold: true
            color: gridView.contentX > internal.initialContentX+internal.contentXactionOn ? "#3498db" : "#bdc3c7"
            rotation: 90
            x: parent.width-nextWeek.width
            y: (parent.height-nextWeek.height)/2
            opacity: (gridView.contentX - internal.initialContentX) / internal.contentXactionOn
        }

    }

    QtObject {
        id: internal

        property int initialContentX;
        property int contentXactionOn: mainView.width/10;
        property int pressedContentX;
    }
}

