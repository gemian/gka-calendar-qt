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



    function shortMonth(m) {
        var date = new Date();
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

    function colourForBackground(type) {
        switch (type) {
        case 4:
        case 0:
        case 3:
            return "transparent";
        case 1:
            return "#33aaaaaa";
        case 2:
            return "#33aaffaa";
        }
    }

    Component {
        id: yearGridDelegate

        Rectangle {
            width: 20
            height: 20
            border.color: yearGridModel.items[index]?colourForBorder(yearGridModel.items[index].type):"transparent"
            border.width: 1
            color: yearGridModel.items[index]?colourForBackground(yearGridModel.items[index].type):"transparent"
            Label {
                width: 20
                height: 20
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
                    height: gridView.cellHeight
                    text: index===0?" ":shortMonth(index-1)
                }
            }
        }
    }

    Column {

        Label {
            id: selectedYear
            text: qsTr("Year Planner ") + yearGridModel.year
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
//            interactive: false
            model: yearGridModel
            cellWidth: gridView.width/(5*7+2)
            cellHeight: gridView.height/13
            flow: GridView.FlowTopToBottom

            Component.onCompleted: {
                print("onCompleted")
                gridView.forceActiveFocus();
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
            updateGridViewToToday();
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
}
