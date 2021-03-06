import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    property alias color: dayRectangle.color
    focus: !showHeader
    id: dayContainer
    width: gridView.cellWidth-app.appFontSize/5
    height: gridView.cellHeight-app.appFontSize/5

    property bool showHeader: true
    property bool dateOnLeft: true
    property int gridViewIndex: index
    property var itemDate
    property var weekDay
    property var lunarDate: (itemDate !== undefined) ? Lunar.calendar.solar2lunar(itemDate.getFullYear(), itemDate.getMonth() + 1, itemDate.getDate()) : null

    MouseArea {
        anchors.fill: parent
        onPressed: {
            //console.log("itemclickday i:" + index)
            daySelectedIndex = index
            if (dayListView.count > 0) {
                if (dayListView.currentIndex === -1 && !noItemIndicator.activeFocus) {
                    dayListView.currentIndex = 0
                    dayChildSelectedIndex = 0
                }
                if (dayListView.currentIndex !== -1 && !dayListView.currentItem.activeFocus) {
                    dayListView.currentItem.forceActiveFocus()
                }
            } else {
                if (!noItemIndicator.activeFocus) {
                    dayChildSelectedIndex = -1
                    noItemIndicator.forceActiveFocus()
                }
            }

        }
    }

    Rectangle {
        id: headerRectangle
        anchors.fill: parent
        visible: showHeader
        focus: false
        enabled: false
        color: "#3498db"
        opacity: 0.8

        Text {
            anchors.fill: parent
            anchors.leftMargin: app.appFontSize/2
            text: if (weekStartDate.getMonth() === weekEndDate.getMonth()) {
                      weekStartDate.toLocaleDateString(Qt.locale(), "MMMM yyyy");
                  } else {
                      weekStartDate.toLocaleDateString(Qt.locale(), "MMM") + " - " + weekEndDate.toLocaleDateString(Qt.locale(), "MMM yyyy");
                  }
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            font.pixelSize: app.appFontSize * 3
        }
        Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            padding: app.appFontSize/5
            font.pixelSize: app.appFontSize;
            text: i18n.tr("Week %1").arg(weekStartDate.weekNumber(1));
        }
        Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            padding: app.appFontSize/5
            font.pixelSize: app.appFontSize;
            //text: "dSI: " + daySelectedIndex + ", dCSI: " + dayChildSelectedIndex + ", cC: " + childrenCompleted + ", hRw: " + headerRectangle.width + ", GVvcW: " + gridView.cellWidth
        }
    }

    Rectangle {
        clip: true
        id: dayRectangle
        objectName: "WeekViewDayItem"
        anchors.fill: parent
        visible: !showHeader
        color: index > 5 ? "#edeeef" : "#fdfeff"
        opacity: 0.9

        //side with date
        Rectangle {
            id: dateDisplay
            x: dateOnLeft ? 0 : dayRectangle.width-dateDisplay.width
            height: dayRectangle.height
            width: dateText.width
            color: (itemDate !== undefined) && (itemDate.toLocaleDateString() === new Date().toLocaleDateString()) ? "#333639" : "#4d4d4d"
            opacity: 0.8

            Text {
                id: dateText
                height: dayRectangle.height
                width: dayRectangle.width/10
                padding: Math.floor(app.appFontSize/5)
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                font.pixelSize: app.appFontSize;
                text: app.showLunarCalendar ? ("%1 %2 %3").arg(lunarDate.IDayCn).arg(lunarDate.gzDay).arg(lunarDate.isTerm ? lunarDate.Term : "")
                                                          : (visible ? itemDate.toLocaleDateString(Qt.locale(), "ddd dd") : "")
                color: (itemDate !== undefined) && (itemDate.toLocaleDateString() === new Date().toLocaleDateString()) ? "#3daee9" : "#31363b"
            }
        }

        Column {
            id: dayList
            padding: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: dateOnLeft ? dateDisplay.right : dayRectangle.left
            anchors.right: dateOnLeft ? dayRectangle.right : dateDisplay.left
            width: parent.width - dateDisplay.width
            height: Math.min(dayRectangle.height, dayListView.contentHeight + dayListNoItems.height)

            //List of items for date with start times
            ListView {
                id: dayListView
                width: parent.width
                height: Math.min(dayRectangle.height - dayListNoItems.height, dayListView.contentHeight)
                visible: count > 0
                model: weekDay.itemCount
                interactive: dayListView.contentHeight > height

                delegate: FocusScope {
                    width: ListView.view.width
                    height: Math.max(calendarIndicator.height,dayItemLabel.height)
                    x: childrenRect.x
                    y: childrenRect.y
                    id: detailsListitem
                    focus: !showHeader

                    onFocusChanged: {
                        //console.log("detailsListitem focusChanged aF: "+activeFocus+", gVI: "+gridViewIndex+", dSI: " + daySelectedIndex + ", dCSI: " + dayChildSelectedIndex + ", i: " + index)
                        if (activeFocus) {
                            if (dayChildSelectedIndex != index) {
                                dayChildSelectedIndex = index;
                            }
                        }
                    }

                    Rectangle {
                        id: calendarIndicator
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(timeLabelStart.width+app.appFontSize/5,+app.appFontSize*2)
                        height: timeLabelStart.height+app.appFontSize/5
                        radius: 2
                        activeFocusOnTab: true
                        focus: !showHeader && (gridViewIndex === daySelectedIndex) && (dayChildSelectedIndex === index)

                        border.color: activeFocus ? "black" : "transparent"
                        color: weekDay.items[index] && weekDay.items[index].collectionId ? organizerModel.collection(weekDay.items[index].collectionId).color : (activeFocus ? "black" : "transparent")

                        // start time event Label
                        Text {
                            id: timeLabelStart
                            anchors.centerIn: calendarIndicator
                            color: calendarIndicator.activeFocus ? "white" : "black"
                            font.pixelSize: app.appFontSize;
                            text: weekDay.items[index].startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }

                    Text {
                        id: dayItemLabel
                        anchors {
                            left: calendarIndicator.right
                            leftMargin: app.appFontSize/2
                        }
                        width: parent.width - calendarIndicator.width - app.appFontSize/2
                        wrapMode: Text.Wrap
                        text: weekDay.items[index].displayLabel
                        font.pixelSize: app.appFontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            internal.pressedContentX = gridView.contentX
                        }

                        onReleased: {
                            var diff = parent.width/10
                            if (gridView.contentX > internal.pressedContentX-diff && gridView.contentX < internal.pressedContentX+diff) {
                                if (daySelectedIndex === gridViewIndex && dayChildSelectedIndex === index) {
                                    dialogLoader.setSource("EditEventDialog.qml", {"eventId": weekDay.items[index].parentId?weekDay.items[index].parentId:weekDay.items[index].itemId, "model":organizerModel});
                                }
                                daySelectedIndex = gridViewIndex
                                dayChildSelectedIndex = index
                                dayListView.currentIndex = index
                                dayListView.currentItem.forceActiveFocus()
                            }
                        }
                    }

                    Component.onCompleted: {
                        //console.log("itemcell.onCompleted: "+gridViewIndex+" i:"+index)
                    }
                }
            }

            Rectangle {
                id: dayListNoItems
                width: parent.width
                height: noItemIndicator.height
                color: "transparent"

                Rectangle {
                    id: noItemIndicator
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(noItemLabel.width,8)
                    height: noItemLabel.height
                    radius: 2
                    color: activeFocus ? "black" : "transparent"
                    focus: !showHeader && (daySelectedIndex === index) && (dayChildSelectedIndex === -1)
                    activeFocusOnTab: true

                    Text {
                        id: noItemLabel
                        text: " "
                        font.pixelSize: app.appFontSize;
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        internal.pressedContentX = gridView.contentX
                    }

                    onReleased: {
                        var diff = parent.width/10
                        if (gridView.contentX > internal.pressedContentX-diff && gridView.contentX < internal.pressedContentX+diff) {
                            if (daySelectedIndex == index) {
                                dialogLoader.setSource("EditEventDialog.qml", {"startDate":itemDate, "model":organizerModel});
                            }
                            //console.log("emptyitemclick i:"+index)
                            daySelectedIndex = index
                            app.selectedDate = itemDate
                            dayChildSelectedIndex = -1
                            dayListView.currentIndex = -1
                            noItemIndicator.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    function setDateToLeftColumn(index) {
        daySelectedIndex = index - 4;
        if (daySelectedIndex < 1) {
            daySelectedIndex = 1;
        }
    }

    function setDateToRightColumn(index) {
        daySelectedIndex = index + 4;
    }

    function setDateToPreviousWeek() {
        weekStartDate = weekStartDate.addDays(-7);
    }

    function setDateToNextWeek() {
        weekStartDate = weekStartDate.addDays(7);
    }

    function moveSelectionToNextWeek(index) {
        setDateToNextWeek();
        setDateToLeftColumn(index);
    }

    function moveSelectionToPreviousWeek(index) {
        setDateToPreviousWeek();
        setDateToRightColumn(index);
    }

    Keys.onPressed: {
        console.log("[WVDI]key:"+event.key)
        if (event.key === Qt.Key_Space) {
            updateGridViewToToday();
        }
        if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
            if (dayChildSelectedIndex >= 0) {
                dialogLoader.setSource("DeleteDialog.qml", {"event": weekDay.items[dayChildSelectedIndex], "model":organizerModel});
            }
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (dayChildSelectedIndex == -1) {
                dialogLoader.setSource("EditEventDialog.qml", {"startDate":itemDate, "model":organizerModel});
            } else {
                dialogLoader.setSource("EditEventDialog.qml", {"eventId": weekDay.items[dayChildSelectedIndex].parentId?weekDay.items[dayChildSelectedIndex].parentId:weekDay.items[dayChildSelectedIndex].itemId, "model":organizerModel});
            }
        }

        if (event.key === Qt.Key_Left) {
            if (dateOnLeft) {
                moveSelectionToPreviousWeek(index);
            } else {
                setDateToLeftColumn(index);
            }
            event.accepted = true;
        }
        if (event.key === Qt.Key_Right) {
            if (!dateOnLeft) {
                moveSelectionToNextWeek(index);
            } else {
                setDateToRightColumn(index);
            }
            event.accepted = true;
        }
        if (event.key === Qt.Key_Up) {
            //console.log("move up i: " + index + "ci: " + dayListView.currentIndex + " c: " + dayListView.count);
            if (dayListView.count > 0) {
                if (dayChildSelectedIndex === 0) {
                    if (index <= 1) {
                        setDateToPreviousWeek();
                        daySelectedIndex = 7;
                        dayChildSelectedIndex = -1;
                        event.accepted = true;
                    } else {
                        daySelectedIndex = index - 1;
                        dayChildSelectedIndex = -1;
                        event.accepted = true;
                    }
                } else {
                    if (dayChildSelectedIndex === -1) {
                        dayChildSelectedIndex = dayListView.count - 1;
                    } else {
                        dayChildSelectedIndex--;
                    }
                    dayListView.currentIndex = dayChildSelectedIndex;
                    event.accepted = true;
                }
            } else {
                if (index <= 1) {
                    setDateToPreviousWeek();
                    daySelectedIndex = 7;
                    dayChildSelectedIndex = -1;
                    event.accepted = true;
                } else {
                    daySelectedIndex = index - 1;
                    dayChildSelectedIndex = -1;
                    event.accepted = true;
                }
            }
        }
        if (event.key === Qt.Key_Down) {
            //console.log("move down i: " + index + "ci: " + dayListView.currentIndex + " c: " + dayListView.count);
            if (dayListView.count > 0) {
                if (dayChildSelectedIndex === -1) {
                    if (index == 7) {
                        setDateToNextWeek();
                        daySelectedIndex = 1;
                        dayChildSelectedIndex = 0;
                        event.accepted = true;
                    } else {
                        daySelectedIndex = index + 1;
                        dayChildSelectedIndex = 0;
                        event.accepted = true;
                    }
                } else {
                    dayChildSelectedIndex++;
                    if (dayChildSelectedIndex === dayListView.count) {
                        dayChildSelectedIndex = -1;
                    }
                    dayListView.currentIndex = dayChildSelectedIndex;
                    event.accepted = true;
                }
            } else {
                if (index == 7) {
                    setDateToNextWeek();
                    daySelectedIndex = 1;
                    dayChildSelectedIndex = 0;
                    event.accepted = true;
                } else {
                    daySelectedIndex = index + 1;
                    dayChildSelectedIndex = 0;
                    event.accepted = true;
                }
            }
        }
        if (event.accepted) {
            if (daySelectedIndex === index) {
                if ((dayListView.currentIndex != -1) && !dayListView.currentItem.activeFocus) {
                    dayListView.currentItem.forceActiveFocus()
                }
                if ((dayListView.currentIndex == -1) &&!noItemIndicator.activeFocus) {
                    noItemIndicator.forceActiveFocus()
                }
            }

            updateGridViewWithDaySelection();
        }
    }

    onActiveFocusChanged: {
        console.log("focus changed aF: " + dayContainer.activeFocus + ", dSI: " + daySelectedIndex + ", i: " + index + ", dLVc: " + dayListView.count + ", dLVcI: " + dayListView.currentIndex + ", dCSI: " + dayChildSelectedIndex);
        if (dayContainer.activeFocus) {
            if (index == 0) {
                dayContainer.GridView.view.currentIndex = daySelectedIndex
                dayContainer.GridView.view.currentItem.forceActiveFocus()
            }

            if (daySelectedIndex === index) {
                app.selectedDate = itemDate

                if (dayChildSelectedIndex >= dayListView.count || dayChildSelectedIndex === -1) {
                    if (!noItemIndicator.activeFocus) {
                        noItemIndicator.forceActiveFocus()
                        dayChildSelectedIndex = -1;
                    }
                }
                dayListView.currentIndex = dayChildSelectedIndex

                if ((dayListView.currentIndex != -1) && dayListView.currentItem && !dayListView.currentItem.activeFocus) {
                    dayListView.currentItem.forceActiveFocus()
                }
            }
        }
    }
}
