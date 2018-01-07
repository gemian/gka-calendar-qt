import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    id: dayItem
    width: gridView.cellWidth-2
    height: gridView.cellHeight-2

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

        Row {
            id: dayItemRow
            leftPadding: 5
            spacing: 5

            Label {
                id: selectedDay
                visible: index == 0
                text: selectedDate.toLocaleDateString(Qt.locale(), Locale.LongFormat);
                font.pixelSize: dayItemLabel.font.pixelSize * 2
                font.bold: true
            }

            Rectangle {
                id: calendarIndicator
                visible: index >= 1
                width: Math.max(timeLabelStart.width,20)//units.gu(1)
                height: timeLabelStart.height
                radius: 2
                activeFocusOnTab: true
                focus: index === hourSelectedIndex

                color: activeFocus ? "black" : "transparent"
                //color: model.item.collectionId ? organizerModel.collection(model.item.collectionId).color : (activeFocus ? "black" : "grey")

                // start time event Label
                Text {
                    id: timeLabelStart
                    color: calendarIndicator.activeFocus ? "white" : "black"
                    text: dayGridModel.items[index]?dayGridModel.items[index].time.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                }
            }

            Text {
                id: dayItemLabel
                visible: index >= 1
                width: dayRectangle.width - calendarIndicator.width - 10
                wrapMode: Text.Wrap
                text: dayGridModel.items[index]?dayGridModel.items[index].displayLabel:""
            }
        }
    }

    Component.onCompleted: {
        console.log("itemcell.onCompleted i:"+index)
    }
}
