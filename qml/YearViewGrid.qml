import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    id: yearViewContainer

    property int daySelectedIndex: 1

    YearGridModel {
        id: yearGridModel
        year: selectedDate.getFullYear()

        onModelChanged: {
            print("YearGridModel.onModelChanged")
        }
    }

    function indexFor(y,m,d) {
        var firstOfMonth = new Date(y, m, 1);
        var dayOfWeek = firstOfMonth.getDay()-1;
        if (dayOfWeek < 0) {
            dayOfWeek = 6; //Fix for start of week Mon/Sun confusion between Qt/JavaScript
        }
        var gridIndex = (m+1)+13*(dayOfWeek+(d-1));
//        console.log("indexFor y:"+y+", m:"+m+", d:"+d+", fOM"+firstOfMonth+", i:"+gridIndex)
        return gridIndex;
    }

    function moveAnchorForEventDateByMonthsNext(event, indexDate, months, next) {
        event.accepted = true;
        selectedDate = selectedDate.addMonths(months);
        gridView.currentIndex = indexFor(selectedDate.getFullYear(), next, indexDate.getDate());
        gridView.currentItem.forceActiveFocus();
    }

    function moveGridForEventIndexBy(event, index, by) {
        var indexDate = yearGridModel.items[index].date;
        if (yearGridModel.items[index+by].type === 0) {
            event.accepted = true;
            if (indexDate.getDate() > 15) {
                gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()+by, Date.daysInMonth(indexDate.getFullYear(),indexDate.getMonth()+by));
            } else {
                gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()+by, 1);
            }
            gridView.currentItem.forceActiveFocus();
        }
    }

    function moveAnchorAndGridLeftForEvent(event, indexDate) {
        event.accepted = true;
        if (indexDate.getMonth() === 0) {
            selectedDate = selectedDate.addMonths(-12);
            gridView.currentIndex = indexFor(indexDate.getFullYear()-1, 11, Date.daysInMonth(indexDate.getFullYear()-1,11));
        } else {
            gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()-1, Date.daysInMonth(indexDate.getFullYear(),indexDate.getMonth()-1));
        }
        gridView.currentItem.forceActiveFocus();
    }

    function moveAnchorAndGridRightForEvent(event,  indexDate) {
        event.accepted = true;
        if (indexDate.getMonth() === 11) {
            selectedDate = selectedDate.addMonths(12);
            gridView.currentIndex = indexFor(indexDate.getFullYear()+1, 0, 1);
        } else {
            gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()+1, 1);
        }
        gridView.currentItem.forceActiveFocus();
    }

    function updateSelectedToToday() {
        var date = new Date();
        updateSelectedToDate(date);
    }

    function updateSelectedToDate(date) {
        selectedDate = date;
        gridView.currentIndex = indexFor(date.getFullYear(), date.getMonth(), date.getDate());
        gridView.currentItem.forceActiveFocus();
    }

    function shortMonth(m) {
        var date = new Date();
        date.setDate(1);
        date.setMonth(m);
        return date.toLocaleDateString(Qt.locale(), "MMM");
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

    function editItem(itemId) {
        dialogLoader.setSource("EditEventDialog.qml", {"eventId": itemId, "model":organizerModel});
    }

    Connections {
        target: app
        onUpdateSelectedToToday: {
            updateSelectedToToday();
        }
        onUpdateSelectedToDate: {
            updateSelectedToDate(date);
        }
    }

    Component {
        id: yearGridDelegate

        Rectangle {
            width: gridView.cellWidth+1
            height: gridView.cellHeight+1
            border.color: yearGridModel.items[index]?colourForBorder(yearGridModel.items[index].type):"transparent"
            border.width: 1
            color: yearGridModel.items[index]?colourForBackground(yearGridModel.items[index]):"transparent"
            Label {
                width: gridView.cellWidth
                height: gridView.cellHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: yearGridModel.items[index]?yearGridModel.items[index].displayLabel:" "
                font.pixelSize: app.appFontSize

                MouseArea {
                    anchors.fill: parent
                    onReleased: {
                        if (yearGridModel.items[index].type > 0 && yearGridModel.items[index].type < 4) {
                            gridView.currentIndex = index
                            gridView.currentItem.forceActiveFocus()
                        }
                    }
                }
            }

            onFocusChanged: {
//                console.log("focusChange"+activeFocus+yearGridModel.items[index]?yearGridModel.items[index].date:" ");
                if (activeFocus) {
                    selectedDateLabel.text = " "
                    daySelectedIndex = index;
                    if (yearGridModel.items[index]) {
                        if (yearGridModel.items[index].type > 0 && yearGridModel.items[index].type < 4) {
                            selectedDate = yearGridModel.items[index].date;
                        }
                        selectedDateLabel.text = yearGridModel.items[index].date.toLocaleString(Qt.locale(), "ddd dd MMM")+":";
                        selectedDateList.model = yearGridModel.items[index].items;
                    }
                }
            }

            Keys.onPressed: {
                var gridY = index % 13;
                var indexDate = yearGridModel.items[index].date
                //var gridX = Math.floor(index / 13);
                //console.log("[YGVD]key:"+event.key+", index: "+index+", gridX: "+gridX+", gridY: "+gridY+", type"+yearGridModel.items[index].type)
                if (event.key === Qt.Key_Up) {
                    if (gridY < 2) {
                        moveAnchorForEventDateByMonthsNext(event, indexDate, -12, 11)
                    } else {
                        moveGridForEventIndexBy(event, index, -1)
                    }
                } else if (event.key === Qt.Key_Down) {
                    if (gridY > 11) {
                        moveAnchorForEventDateByMonthsNext(event, indexDate, 12, 0)
                    } else {
                        moveGridForEventIndexBy(event, index, 1)
                    }
                } else if (event.key === Qt.Key_Left) {
                    if (yearGridModel.items[index].date.getDate() < 2) {
                        moveAnchorAndGridLeftForEvent(event, indexDate)
                    }
                } else if (event.key === Qt.Key_Right) {
                    if (indexDate.getDate() > Date.daysInMonth(indexDate.getFullYear(),indexDate.getMonth())-1) {
                        moveAnchorAndGridRightForEvent(event, indexDate)
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
            border.color: gridView.activeFocus ? sysPalette.highlight : "black"
            border.width: app.appFontSize/5
        }
    }

    Component {
        id: gridHeader

        ColumnLayout {
            spacing: 0
            Repeater {
                model: 13
                Label {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: gridView.cellHeight
                    Layout.leftMargin: app.appFontSize/2
                    Layout.rightMargin: app.appFontSize/2
                    text: index===0?" ":shortMonth(index-1)
                    font.pixelSize: app.appFontSize
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Column {
        Label {
            id: selectedYear
            Layout.leftMargin: app.appFontSize
            text: qsTr("Year Planner ") + yearGridModel.year
            font.pixelSize: app.appFontSize
            font.bold: true
            color: "#3498db"
        }
        GridView {
            id: gridView
            width: mainView.width
            height: mainView.height-(selectedYear.height+selectedDateRow.height)
            anchors.leftMargin: app.appFontSize/2
            anchors.rightMargin: app.appFontSize/2
            anchors.topMargin: app.appFontSize/2
            anchors.bottomMargin: app.appFontSize/2
            activeFocusOnTab: true

            delegate: yearGridDelegate
            header: gridHeader
            highlight: gridHighlight
            visible: true
            model: yearGridModel
            cellWidth: Math.floor(gridView.width/(5*7+3))
            cellHeight: gridView.height/13
            flow: GridView.FlowTopToBottom

            Component.onCompleted: {
                internal.initialContentX = contentX
                internal.contentXactionOn = gridView.width/10
                gridView.forceActiveFocus();
            }
            Keys.onPressed: {
//                console.log("[YGV]key:"+event.key)
            }
            onDragEnded: {
                if (contentX > internal.initialContentX+internal.contentXactionOn) {
                    selectedDate = selectedDate.addMonths(12);
                } else if (contentX < internal.initialContentX-internal.contentXactionOn) {
                    selectedDate = selectedDate.addMonths(-12);
                }
                gridView.currentIndex = indexFor(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate())
            }
        }

        Row {
            id: selectedDateRow
            leftPadding: app.appFontSize
            topPadding: app.appFontSize
            bottomPadding: app.appFontSize
            spacing: app.appFontSize
            Label {
                id: selectedDateLabel
                text: " "
                font.pixelSize: app.appFontSize
            }

            Repeater {
                id: selectedDateList

                delegate: ZoomButton {
                    id: selectedItemsLabel
                    text: displayLabel
                    onFocusChanged: {
                        if (activeFocus) {
                            internal.selectedButton = index
                        }
                    }

                    onClicked: {
                        editItem(parentId?parentId:itemId);
                    }
                    Keys.onEnterPressed: {
                        editItem(parentId?parentId:itemId);
                    }
                    Keys.onReturnPressed: {
                        editItem(parentId?parentId:itemId);
                    }
                }
            }
        }
    }

    Label {
        id: lastYear
        text: selectedDate.getFullYear()-1
        font.pixelSize: app.appFontSize  * 2
        font.bold: true
        color: gridView.contentX < internal.initialContentX-internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: -90
        x: 0
        y: (mainView.height-lastYear.height)/2
        opacity: (internal.initialContentX - gridView.contentX) / internal.contentXactionOn
    }

    Label {
        id: nextYear
        text: selectedDate.getFullYear()+1
        font.pixelSize: app.appFontSize * 2
        font.bold: true
        color: gridView.contentX > internal.initialContentX+internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: 90
        x: mainView.width-nextYear.width
        y: (mainView.height-nextYear.height)/2
        opacity: (gridView.contentX - internal.initialContentX) / internal.contentXactionOn
    }

    Keys.onPressed: {
        console.log("key:"+event.key)
        if (event.key === Qt.Key_Space) {
            updateSelectedToToday();
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
//            console.log("dSI: "+daySelectedIndex+", l: "+yearGridModel.items[daySelectedIndex].items.length)
            if (yearGridModel.items[daySelectedIndex].type > 0 && yearGridModel.items[daySelectedIndex].type < 4) {
                if (yearGridModel.items[daySelectedIndex].items.length === 0) {
                    dialogLoader.setSource("EditEventDialog.qml", {"startDate":selectedDate, "allDay":true, "model":organizerModel});
                } else {
                    dialogLoader.setSource("EditEventDialog.qml", {"eventId": yearGridModel.items[daySelectedIndex].items[0].parentId?yearGridModel.items[daySelectedIndex].items[0].parentId:yearGridModel.items[daySelectedIndex].items[0].itemId, "model":organizerModel});
                }
            }
        }
        if (event.key === Qt.Key_Up) {
            gridView.forceActiveFocus();
        }
        if (event.key === Qt.Key_Left) {
            if (internal.selectedButton > 0) {
                selectedDateList.itemAt(internal.selectedButton-1).forceActiveFocus()
            }
        }
        if (event.key === Qt.Key_Right) {
            var nextItem = selectedDateList.itemAt(internal.selectedButton+1);
            if (nextItem) {
                nextItem.forceActiveFocus()
            }
        }
    }

    QtObject {
        id: internal

        property int initialContentX;
        property int contentXactionOn;
        property int selectedButton;
    }

    Component.onCompleted: {
        gridView.currentIndex = indexFor(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate())
        gridView.currentItem.forceActiveFocus()
    }

}
