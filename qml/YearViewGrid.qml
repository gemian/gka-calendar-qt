import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    id: yearViewContainer

    property var anchorDate: new Date()
    property var selectedDate: new Date()
    property int daySelectedIndex: 1

    YearGridModel {
        id: yearGridModel
        year: anchorDate.getFullYear()

        onModelChanged: {
            print("YearGridModel.onModelChanged")
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
            for (var i=0; i < collections.length ; ++i) {
                var collection = collections[i]
                if (collection.extendedMetaData("collection-selected") === true) {
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

    function indexFor(y,m,d) {
        var firstOfMonth = new Date(y, m, 1);
        var dayOfWeek = firstOfMonth.getDay()-1;
        if (dayOfWeek < 0) {
            dayOfWeek = 6; //Fix for start of week Mon/Sun confusion between Qt/JavaScript
        }
        var gridIndex = (m+1)+13*(dayOfWeek+(d-1));
        console.log("indexFor y:"+y+", m:"+m+", d:"+d+", fOM"+firstOfMonth+", i:"+gridIndex)
        return gridIndex;
    }

    function moveAnchorForEventDateByMonthsNext(event, indexDate, months, next) {
        event.accepted = true;
        anchorDate = anchorDate.addMonths(months);
        gridView.currentIndex = indexFor(anchorDate.getFullYear(), next, indexDate.getDate());
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
            anchorDate = anchorDate.addMonths(-12);
            gridView.currentIndex = indexFor(indexDate.getFullYear()-1, 11, Date.daysInMonth(indexDate.getFullYear()-1,11));
        } else {
            gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()-1, Date.daysInMonth(indexDate.getFullYear(),indexDate.getMonth()-1));
        }
        gridView.currentItem.forceActiveFocus();
    }

    function moveAnchorAndGridRightForEvent(event,  indexDate) {
        event.accepted = true;
        if (indexDate.getMonth() === 11) {
            anchorDate = anchorDate.addMonths(12);
            gridView.currentIndex = indexFor(indexDate.getFullYear()+1, 0, 1);
        } else {
            gridView.currentIndex = indexFor(indexDate.getFullYear(), indexDate.getMonth()+1, 1);
        }
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

    Component.onCompleted: {
        gridView.currentIndex = indexFor(anchorDate.getFullYear(), anchorDate.getMonth(), anchorDate.getDate())
        gridView.currentItem.forceActiveFocus()
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
                console.log("focusChange"+activeFocus+yearGridModel.items[index]?yearGridModel.items[index].date:" ");
                if (activeFocus) {
                    selectedDateLabel.text = " "
                    selectedItemsLabel.text = " "
                    selectedItemsCountLabel.text = ""
                    daySelectedIndex = index;
                    if (yearGridModel.items[index]) {
                        if (yearGridModel.items[index].type > 0 && yearGridModel.items[index].type < 4) {
                            selectedDate = yearGridModel.items[index].date;
                        }
                        selectedDateLabel.text = yearGridModel.items[index].date.toLocaleString(Qt.locale(), "ddd dd MMM")+":";
                        if (yearGridModel.items[index].items.length > 0) {
                            selectedItemsLabel.text = yearGridModel.items[index].items[0].displayLabel;
                            if (yearGridModel.items[index].items.length > 1) {
                                selectedItemsCountLabel.text = yearGridModel.items[index].items.length;
                            }
                        }
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
            border.color: "black"
            border.width: 2
        }
    }

    Component {
        id: gridHeader

        Column {
            Repeater {
                model: 13
                Label {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    text: index===0?" ":shortMonth(index-1)
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Label {
        id: lastYear
        text: anchorDate.getFullYear()-1
        font.pixelSize: selectedYear.font.pixelSize * 2
        font.bold: true
        color: gridView.contentX < internal.initialContentX-internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: -90
        x: 0
        y: (mainView.height-lastYear.height)/2
        opacity: (internal.initialContentX - gridView.contentX) / internal.contentXactionOn
    }

    Label {
        id: nextYear
        text: anchorDate.getFullYear()+1
        font.pixelSize: selectedYear.font.pixelSize * 2
        font.bold: true
        color: gridView.contentX > internal.initialContentX+internal.contentXactionOn ? "#3498db" : "#31363b"
        rotation: 90
        x: mainView.width-nextYear.width
        y: (mainView.height-nextYear.height)/2
        opacity: (gridView.contentX - internal.initialContentX) / internal.contentXactionOn
    }

    Column {

        Label {
            id: selectedYear
            text: qsTr("Year Planner ") + yearGridModel.year
            font.bold: true
            color: "#3498db"
        }
        GridView {
            id: gridView
            width: mainView.width
            height: mainView.height-(selectedYear.height+selectedDateLabel.height)
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            delegate: yearGridDelegate
            header: gridHeader
            highlight: gridHighlight
            visible: true
            model: yearGridModel
            cellWidth: gridView.width/(5*7+3)
            cellHeight: gridView.height/13
            flow: GridView.FlowTopToBottom

            Component.onCompleted: {
                internal.initialContentX = contentX
                internal.contentXactionOn = gridView.width/10
                gridView.forceActiveFocus();
            }
            Keys.onPressed: {
                console.log("[YGV]key:"+event.key)
            }
            onDragEnded: {
                if (contentX > internal.initialContentX+internal.contentXactionOn) {
                    anchorDate = anchorDate.addMonths(12);
                } else if (contentX < internal.initialContentX-internal.contentXactionOn) {
                    anchorDate = anchorDate.addMonths(-12);
                }
            }
        }
        Row {
            leftPadding: 10
            spacing: 10
            Label {
                id:selectedDateLabel
                text: " "
            }
            Label {
                id:selectedItemsLabel
                text: " "
            }
            Label {
                id:selectedItemsCountLabel
            }
//            Re-enable once implmented
//            Button {
//                id:otherItemsButton
//                visible: selectedItemsCount.text.length > 0
//                text: qsTr("More")
//            }
        }
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

    Keys.onPressed: {
        console.log("key:"+event.key)
        if (event.key === Qt.Key_Space) {
            var date = new Date();
            anchorDate = date;
            gridView.currentIndex = indexFor(date.getFullYear(), date.getMonth(), date.getDate());
            gridView.currentItem.forceActiveFocus()
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            console.log("dSI: "+daySelectedIndex+", l: "+yearGridModel.items[daySelectedIndex].items.length)
            if (yearGridModel.items[daySelectedIndex].type > 0 && yearGridModel.items[daySelectedIndex].type < 4) {
                if (yearGridModel.items[daySelectedIndex].items.length === 0) {
                    dialogLoader.setSource("EditEventDialog.qml", {"startDate":selectedDate, "allDay":true, "model":organizerModel});
                } else {
                    dialogLoader.setSource("EditEventDialog.qml", {"eventId": yearGridModel.items[daySelectedIndex].items[0].itemId, "model":organizerModel});
                }
            }
        }
    }

    QtObject {
        id: internal

        property int initialContentX;
        property int contentXactionOn;
    }
}
