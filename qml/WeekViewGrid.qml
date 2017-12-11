import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt

FocusScope {
    id: weekViewContainer

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
        clip: true
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
        }
    }
}

