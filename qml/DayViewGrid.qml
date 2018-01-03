import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    id: dayViewContainer

    property int hourSelectedIndex: 1

    DayGridModel {
        id: dayGridModel
        date: selectedDate

        onModelChanged: {
            print("DayGridModel.onModelChanged")
        }

        onItemsLoaded: {
            var gVHeight = mainView.height - 10
            internal.dayGridCellHeight = Math.floor(gVHeight/Math.round(itemCount/2))
            print("DayGridModel.onItemsLoaded gvh: "+gVHeight+", ic: "+itemCount+", ch: "+internal.dayGridCellHeight)
            gridView.currentIndex = hourSelectedIndex
            gridView.currentItem.forceActiveFocus()
        }
    }

    function colourForBorder(type) {
        switch (type) {
        case 4:
        case 0:
            return "transparent";
        case 1:
            return "black";
        case 2:
            return "green";
        case 3:
            return "black";
        }
    }

    function colourForBackground(item) {
        var colour = "transparent";
        if (item.type === 2) {
            colour = "#33aaffaa";
        } else if (item.type === 1 || item.type === 3) {
            var dayOfWeek = item.date.getDay();
            if (dayOfWeek === 0 || dayOfWeek === 6) {
                colour = "#3334495e";//7f8c8d
            } else if (item.type === 1) {
                colour = "#33aaaaaa";
            } else {
                colour = "#33ffffff";
            }
        }
        return colour;
    }

    Component.onCompleted: {
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
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            delegate: DayViewItem {
            }
            visible: true
            model: dayGridModel
            cellWidth: Math.floor(gridView.width/(2))
            cellHeight: internal.dayGridCellHeight
            flow: GridView.FlowTopToBottom

            Component.onCompleted: {
                console.log("gridViewCompelted")
                internal.initialContentX = contentX
                internal.contentXactionOn = gridView.width/10
                gridView.forceActiveFocus();

            }
            Keys.onPressed: {
                console.log("[DGV]key:"+event.key)
            }
            onDragEnded: {
                if (contentX > internal.initialContentX+internal.contentXactionOn) {
                    selectedDate = selectedDate.addDays(1);
                } else if (contentX < internal.initialContentX-internal.contentXactionOn) {
                    selectedDate = selectedDate.addDays(-1);
                }
            }
        }
    }

    Label {
        id: defaultLabel
        visible: false
    }

    Label {
        id: previousDay
        text: selectedDate.addDays(-1).toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        font.pixelSize: defaultLabel.font.pixelSize * 2
        font.bold: true
        color: gridView.contentX < internal.initialContentX-internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: -90
        x: 0
        y: (mainView.height-previousDay.height)/2
        opacity: (internal.initialContentX - gridView.contentX) / internal.contentXactionOn
    }

    Label {
        id: nextDay
        text: selectedDate.addDays(1).toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        font.pixelSize: defaultLabel.font.pixelSize * 2
        font.bold: true
        color: gridView.contentX > internal.initialContentX+internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: 90
        x: mainView.width-nextDay.width
        y: (mainView.height-nextDay.height)/2
        opacity: (gridView.contentX - internal.initialContentX) / internal.contentXactionOn
    }

    Keys.onPressed: {
        console.log("key:"+event.key)
        if (event.key === Qt.Key_Space) {
            var date = new Date();
            selectedDate = date;
        }
        if (event.key === Qt.Key_Left) {
            selectedDate = selectedDate.addDays(-1);
            event.accepted = true;
        }
        if (event.key === Qt.Key_Right) {
            selectedDate = selectedDate.addDays(1);
            event.accepted = true;
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            console.log("hSI: "+hourSelectedIndex+", l: "+dayGridModel.items[hourSelectedIndex]+", sd:"+selectedDate+", hsTime:"+dayGridModel.items[hourSelectedIndex].time+", h:"+dayGridModel.items[hourSelectedIndex].time.getUTCHours())
            if (dayGridModel.items[hourSelectedIndex].itemId.length === 0) {
                var dateTime = selectedDate
                dateTime.setHours(dayGridModel.items[hourSelectedIndex].time.getHours())
                dateTime.setMinutes(dayGridModel.items[hourSelectedIndex].time.getMinutes())
                dialogLoader.setSource("EditEventDialog.qml", {"startDate":dateTime, "model":organizerModel});
            } else {
                dialogLoader.setSource("EditEventDialog.qml", {"eventId": dayGridModel.items[hourSelectedIndex].itemId, "model":organizerModel});
            }
        }
    }

    QtObject {
        id: internal

        property int initialContentX;
        property int contentXactionOn;
        property int dayGridCellHeight;
        property int pressedContentX;
    }
}
