import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    id: dayItem
    width: Math.floor(gridView.cellWidth-app.appFontSize/6)
    height: Math.floor(gridView.cellHeight-app.appFontSize/6)

    MouseArea {
        anchors.fill: parent
        onPressed: {
            internal.pressedContentX = gridView.contentX
        }

        onReleased: {
            console.log("itemclickdvd i:" + index)
            var diff = parent.width/10
            if (gridView.contentX > internal.pressedContentX-diff && gridView.contentX < internal.pressedContentX+diff) {
                if (hourSelectedIndex === index) {
                    dialogLoader.setSource("EditEventDialog.qml", {"eventId": dayGridModel.items[index].itemId, "model":organizerModel});
                }
                hourSelectedIndex = index
                gridView.currentIndex = index
                gridView.currentItem.forceActiveFocus()
            }
        }
    }

    onFocusChanged: {
        console.log("detailsListitem focusChanged aF: "+activeFocus+", hSI: " + hourSelectedIndex + ", i: " + index+", time:"+dayGridModel.items[index].time)
        if (activeFocus) {
            if (!dayGridModel.items[index].time.isValid()) {
                if (index < 8) {
                    gridView.currentIndex = index+1
                } else {
                    gridView.currentIndex = index-1
                }
                gridView.currentItem.forceActiveFocus()
            } else if (hourSelectedIndex != index) {
                hourSelectedIndex = index;
            }
        }
    }

    Rectangle {
        clip: true
        id: dayRectangle
        anchors.fill: parent
        color: index===0?"#3498db":"#edeeef"
        opacity: 0.9

        Text {
            id: todayText
            anchors.fill: parent
            visible: index == 0 && selectedDate.isSameDay(new Date())
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            font.pointSize: app.appFontSize * 0.8;
            text: qsTr("Today");
        }

        Row {
            id: dayItemRow
            leftPadding: app.appFontSize/2
            spacing: app.appFontSize/2

            Label {
                id: selectedDay
                visible: index == 0
                text: selectedDate.toLocaleDateString(Qt.locale(), Locale.LongFormat);
                font.pixelSize: app.appFontSize * 1.8
                font.bold: true
            }

            Rectangle {
                id: calendarIndicator
                visible: index >= 1
                width: Math.max(timeLabelStart.width+app.appFontSize/5,app.appFontSize*2)
                height: timeLabelStart.height+app.appFontSize/5
                radius: app.appFontSize/5
                activeFocusOnTab: true
                focus: index === hourSelectedIndex

                border.color: activeFocus ? "black" : "transparent"
                color: dayGridModel.items[index] && dayGridModel.items[index].collectionId ? organizerModel.collection(dayGridModel.items[index].collectionId).color : (activeFocus ? "black" : "transparent")

                // start time event Label
                Text {
                    id: timeLabelStart
                    anchors.centerIn: calendarIndicator
                    color: calendarIndicator.activeFocus ? "white" : "black"
                    font.pixelSize: app.appFontSize
                    text: dayGridModel.items[index]?dayGridModel.items[index].time.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                }
            }

            Text {
                id: dayItemLabel
                visible: index >= 1
                width: dayRectangle.width - calendarIndicator.width - 10
                wrapMode: Text.Wrap
                font.pixelSize: app.appFontSize
                text: dayGridModel.items[index]?dayGridModel.items[index].displayLabel:""
            }
        }
    }

    Component.onCompleted: {
        console.log("itemcell.onCompleted i:"+index)
    }
}
