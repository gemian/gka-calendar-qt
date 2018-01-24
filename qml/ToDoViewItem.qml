import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    id: todoItem
    width: ListView.view.width
    height: todoRectangle.height

    property var oModel

    MouseArea {
        anchors.fill: parent

        onReleased: {
            console.log("dayItemRel i:" + index)
            if (todoSelectedIndex === index) {
                dialogLoader.setSource("EditToDoDialog.qml", {"itemId": oModel.items[index].itemId, "model":oModel});
            }
            todoSelectedIndex = index
            todoListView.currentIndex = index
            todoListView.currentItem.forceActiveFocus()
        }
    }

    onFocusChanged: {
//        console.log("dayItem focusChanged aF: "+activeFocus+", hSI: " + hourSelectedIndex + ", i: " + index+", time:"+dayGridModel.items[index].time)
        if (activeFocus) {
            if (todoSelectedIndex !== index) {
                todoSelectedIndex = index;
            }
        }
    }

    Rectangle {
        clip: true
        id: todoRectangle
        anchors.left: parent.left
        anchors.right: parent.right
        height: todoItemRow.height+app.appFontSize/2
        color: "#edeeef"
        opacity: 0.9

        Row {
            id: todoItemRow
            leftPadding: app.appFontSize/2
            topPadding: app.appFontSize/2
            spacing: app.appFontSize/2

            Rectangle {
                id: todoIndicator
                width: Math.max(timeLabelStart.width+app.appFontSize/5,app.appFontSize*2)
                height: timeLabelStart.height+app.appFontSize/5
                radius: app.appFontSize/5
                activeFocusOnTab: true
                focus: index === todoSelectedIndex

                border.color: activeFocus ? "black" : "transparent"
                color: oModel.items[index] && oModel.items[index].collectionId ? organizerModel.collection(oModel.items[index].collectionId).color : (activeFocus ? "black" : "transparent")

                // start time event Label
                Text {
                    id: timeLabelStart
                    anchors.centerIn: todoIndicator
                    color: todoIndicator.activeFocus ? "white" : "black"
                    font.pixelSize: app.appFontSize
                    text: oModel.items[index]&&oModel.items[index].time?oModel.items[index].time.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                }
            }

            Text {
                id: todoItemLabel
                width: todoRectangle.width - todoIndicator.width - 10
                wrapMode: Text.Wrap
                font.pixelSize: app.appFontSize
                text: oModel.items[index]?oModel.items[index].displayLabel:""
            }
        }
    }

    Component.onCompleted: {
        console.log("tditemcell.onCompleted i:"+index)
    }
}
