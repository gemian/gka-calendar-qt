import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    property alias color: dayRectangle.color
    focus: !showHeader
    id: dayContainer
    width: gridView.cellWidth-2
    height: gridView.cellHeight-2

    property bool showHeader: true
    property bool dateOnLeft: true
    property int gridViewIndex: index
    property var itemDate: new Date()
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
            text: if (weekStartDate.getMonth() === weekEndDate.getMonth()) {
                      weekStartDate.toLocaleDateString(Qt.locale(), "MMMM yyyy");
                  } else {
                      weekStartDate.toLocaleDateString(Qt.locale(), "MMM") + " - " + weekEndDate.toLocaleDateString(Qt.locale(), "MMM yyyy");
                  }
            fontSizeMode: Text.Fit;
            minimumPointSize: 10;
            font.pointSize: 30;
        }
        Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            padding: 2
            font.pointSize: 10;
            text: qsTr("Week %1").arg(weekStartDate.weekNumber(1));
        }
        Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            padding: 2
            font.pointSize: 10;
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
                padding: 2
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                text: app.displayLunarCalendar ? ("%1 %2 %3").arg(lunarDate.IDayCn).arg(lunarDate.gzDay).arg(lunarDate.isTerm ? lunarDate.Term : "")
                                                          : (visible ? itemDate.toLocaleDateString(Qt.locale(), "ddd dd") : "")
                color: (itemDate !== undefined) && (itemDate.toLocaleDateString() === new Date().toLocaleDateString()) ? "#3daee9" : "#31363b"
            }
        }

        EventListModel {
            id: organizerModel
            objectName: "dayEventListModel"
            active: true
            property bool isReady: false
            property var itemIdToLoad: null
            property bool editItem: false

            function enabledColections() {
                var collectionIds = [];
                var collections = getCollections()
                for(var i=0; i < collections.length ; ++i) {
                    var collection = collections[i]
                    if(collection.extendedMetaData("collection-selected") === true) {
                        collectionIds.push(collection.collectionId);
                    }
                }
                return collectionIds
            }

            function applyFilterFinal() {
                var collectionIds = enabledColections()
                collectionFilter.ids = collectionIds
                filter = Qt.binding(function() { return mainFilter; })
                isReady = true
            }

            startPeriod: itemDate.midnight()
            endPeriod: itemDate.endOfDay()

            sortOrders: [
                SortOrder{
                    blankPolicy: SortOrder.BlanksFirst
                    detail: Detail.EventTime
                    field: EventTime.FieldStartDateTime
                    direction: Qt.AscendingOrder
                }
            ]
            onCollectionsChanged: {
                var collectionIds = enabledColections()
                var oldCollections = collectionFilter.ids
                var needsUpdate = false
                if (collectionIds.length !== oldCollections.length) {
                    needsUpdate = true
                } else {
                    for(var i=oldCollections.length - 1; i >=0 ; i--) {
                        if (collectionIds.indexOf(oldCollections[i]) === -1) {
                            needsUpdate = true
                            break;
                        }
                    }
                }

                if (needsUpdate) {
                    collectionFilter.ids = collectionIds
                    updateIfNecessary()
                }
            }

            Component.onCompleted: {
                //print("CalendarView.OrganiserModel.onCompleted");
                applyFilterFinal()
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
                visible: count > 0 && !organizerModel.isLoading
                model: organizerModel
                interactive: dayListView.contentHeight > height

                delegate: FocusScope {
                    width: ListView.view.width
                    height: dayItemLabel.height
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
                        width: Math.max(timeLabelStart.width,20)//units.gu(1)
                        height: timeLabelStart.height
                        radius: 2
                        activeFocusOnTab: true
                        focus: !showHeader && (gridViewIndex === daySelectedIndex) && (dayChildSelectedIndex === index)

                        color: activeFocus ? "black" : "transparent"
                        //color: model.item.collectionId ? organizerModel.collection(model.item.collectionId).color : (activeFocus ? "black" : "grey")

                        // start time event Label
                        Text {
                            id: timeLabelStart
                            color: calendarIndicator.activeFocus ? "white" : "black"
                            text: model.item.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }

                    Text {
                        id: dayItemLabel
                        anchors {
                            left: calendarIndicator.right;
                            leftMargin: 5//units.gu(1)
                        }
                        width: parent.width - calendarIndicator.width
                        wrapMode: Text.Wrap
                        text: model.item.displayLabel
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
                                    dialogLoader.setSource("EditEventDialog.qml", {"eventObject": model.item, "model":organizerModel});
                                }
//                                console.log("itemclicklvd i:"+gridViewIndex + ", i:" + index)
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
        if (event.key === Qt.Key_Delete) {
            if (dayChildSelectedIndex >= 0) {
                dialogLoader.setSource("DeleteDialog.qml", {"event": organizerModel.items[dayChildSelectedIndex], "model":organizerModel});
            }
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (dayChildSelectedIndex == -1) {
                dialogLoader.setSource("EditEventDialog.qml", {"startDate":itemDate, "model":organizerModel});
            } else {
                dialogLoader.setSource("EditEventDialog.qml", {"eventObject": organizerModel.items[dayChildSelectedIndex], "model":organizerModel});
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
