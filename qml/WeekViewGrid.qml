import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import org.gka.CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    id: weekViewContainer

    property var weekStartDate: app.selectedDate.weekStart(1)
    property var weekEndDate: weekStartDate.addDays(6)
    property int daySelectedIndex: app.selectedDate.weekStartOffset(1)+1
    property int dayChildSelectedIndex: 0
    property int childrenCompleted: 0
    focus: true

    WeekGridModel {
        id: weekGridModel
        startOfWeek: weekStartDate

        onModelChanged: {
            print("DayGridModel.onModelChanged")
        }

    }

    function updateGridViewWithDaySelection() {
        gridView.currentIndex = daySelectedIndex
        gridView.currentItem.forceActiveFocus()
    }

    function updateGridViewToToday() {
//        console.log("updateGridViewToToday");
        var today = new Date();
        updateGridViewToDate(today);
    }

    function updateGridViewToDate(toDate) {
        var offset = toDate.weekStartOffset(1);
        weekStartDate = toDate.addDays(-offset);
        if (daySelectedIndex !== offset+1 || !gridView.currentItem.activeFocus) {
            daySelectedIndex = offset+1;
            dayChildSelectedIndex = 0;
            updateGridViewWithDaySelection();
        }
    }

    Connections {
        target: app
        onUpdateSelectedToToday: {
            updateGridViewToToday();
        }
        onUpdateSelectedToDate: {
            updateGridViewToDate(date);
        }
    }

    Timer {
        running: true
        repeat: false
        interval: 1000
        onTriggered: {
            updateGridViewToDate(app.selectedDate);
        }
    }

    Rectangle {
        width: mainView.width
        height: mainView.height
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#193441" }
            GradientStop { position: 1.0; color: Qt.darker("#193441") }
        }

        GridView {
            id: gridView
            anchors.fill: parent
            anchors.leftMargin: app.appFontSize/2
            anchors.rightMargin: app.appFontSize/2
            anchors.topMargin: app.appFontSize/2
            anchors.bottomMargin: app.appFontSize/2

            cellWidth: gridView.width>gridView.height?gridView.width/2:gridView.width
            cellHeight: gridView.width>gridView.height?gridView.height/4:gridView.height/8
            flow: GridView.FlowTopToBottom
            focus: true

            model: weekGridModel
            delegate: WeekViewDayItem {
                itemDate: (weekGridModel.items[index] !== undefined) ? weekGridModel.items[index].date : ""
                weekDay: weekGridModel.items[index]
                showHeader: (index === 0)
                dateOnLeft: gridView.width>gridView.height?(index < 4):true
            }

            Component.onCompleted: {
                internal.initialContentX = gridView.contentX
            }
            Keys.onPressed: {
//                console.log("[YGV]key:"+event.key)
            }
            Keys.onEscapePressed: {
                event.accepted = true;
            }

            onDragEnded: {
//                console.log("[DragEnd]contentX:"+contentX)
                if (contentX > internal.initialContentX+internal.contentXactionOn) {
                    weekStartDate = weekStartDate.addDays(7);
                } else if (contentX < internal.initialContentX-internal.contentXactionOn) {
                    weekStartDate = weekStartDate.addDays(-7);
                }
            }
            onContentXChanged: {
//                console.log("[YGV]contentX:"+contentX)
            }
        }

        Label {
            id: lastWeek
            text: i18n.tr("Week %1").arg(weekStartDate.weekNumber(1)>1?weekStartDate.weekNumber(1)-1:52);
            font.pixelSize: app.appFontSize * 3
            font.bold: true
            color: gridView.contentX < internal.initialContentX-internal.contentXactionOn ? "#3498db" : "#bdc3c7"
            rotation: -90
            x: 0
            y: (parent.height-lastWeek.height)/2
            opacity: (internal.initialContentX - gridView.contentX) / internal.contentXactionOn
        }

        Label {
            id: nextWeek
            text: i18n.tr("Week %1").arg(weekStartDate.weekNumber(1)<52?weekStartDate.weekNumber(1)+1:1);
            font.pixelSize: app.appFontSize * 3
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

