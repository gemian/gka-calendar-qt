import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import CalendarListModel 1.0
import "dateExt.js" as DateExt

FocusScope {
    id: todoViewContainer

    property int selectedIndex: 0
    property int todoSelectedIndex: 0
    property int memoSelectedIndex: 0

    UnionFilter {
        id: typeTodoFilter
        DetailFieldFilter {
            id: todoFilter
            detail: Detail.ItemType;
            field: Type.FieldType
//            value: Type.Event
            value: Type.Todo
            matchFlags: Filter.MatchExactly
        }

        DetailFieldFilter {
            id: todoOccurenceFilter
            detail: Detail.ItemType;
            field: Type.FieldType
//            value: Type.EventOccurrence
            value: Type.TodoOccurrence
            matchFlags: Filter.MatchExactly
        }
    }

    DetailFieldFilter {
        id: memoFilter
        detail: Detail.ItemType;
        field: Type.FieldType
        value: Type.Journal
        matchFlags: Filter.MatchExactly
    }

    CollectionFilter{
        id: collectionTodoFilter
    }

    CollectionFilter{
        id: collectionMemoFilter
    }

    IntersectionFilter {
        id: mainTodoFilter

        filters: [collectionTodoFilter, typeTodoFilter]
    }

    IntersectionFilter {
        id: mainMemoFilter

        filters: [collectionMemoFilter, memoFilter]
    }

    OrganizerModel {
        id: todoModel
        manager:"eds"

        property bool isReady: false
        property bool active: true
        property bool isLoading: false
        property var itemDate: new Date()

        function getCollections() {
            var cals = [];
            todoModel.fetchCollections();
            var collections = todoModel.collections;
            print("collections: "+collections.length)
            for(var i = 0 ; i < collections.length ; ++i) {
                var cal = collections[i];
                if (cal.extendedMetaData("collection-type") === "Task List" ) {
                    print("collectionId: "+cal.collectionId+ ", enabled: "+cal.extendedMetaData("collection-selected"))
                    cals.push(cal);
                } else {
                    print("collectionId: "+cal.collectionId+", type: "+cal.extendedMetaData("collection-type")+", name: "+cal.name)
                }
            }
            cals.sort(todoModel._sortCollections)
            return cals;
        }

        function enabledCollections() {
            var collectionIds = [];
            var collections = getCollections()
            for (var i=0; i < collections.length; ++i) {
                var collection = collections[i]
                if (collection.extendedMetaData("collection-selected") === true) {
                    collectionIds.push(collection.collectionId);
                }
            }
            return collectionIds
        }

        function applyFilterFinal() {
            var collectionIds = enabledCollections()
            collectionTodoFilter.ids = collectionIds
            filter = Qt.binding(
                        function() {
                            return mainTodoFilter;

                        }
            )
            isReady = true
        }

        filter: InvalidFilter { objectName: "invalidFilter" }

        startPeriod: new Date("") //invalid date
        endPeriod: new Date("") //invalid date

        sortOrders: [
            SortOrder{
                blankPolicy: SortOrder.BlanksFirst
                detail: Detail.EventTime
                field: EventTime.FieldStartDateTime
                direction: Qt.AscendingOrder
            }
        ]

        function updateIfNecessary() {
            if (!autoUpdate) {
                update()
            }
        }

        onStartPeriodChanged: {
            print("todoModel.onStartPeriodChanged")
            isLoading = true
        }

        onModelChanged: {
            print("todoModel.onModelChanged")
            isLoading = false
        }

        onFilterChanged: {
            updateIfNecessary()
        }

        onActiveChanged: {
            if (active) {
                updateIfNecessary()
            }
        }

        Component.onCompleted: {
            if (active) {
                updateIfNecessary()
            }
            applyFilterFinal()
            console.log("Available Managers: " + availableManagers)
        }
    }

    OrganizerModel {
        id: memoModel
        manager:"eds"

        property bool isReady: false
        property bool active: true
        property bool isLoading: false
        property var itemDate: new Date()

        function getCollections() {
            var cals = [];
            memoModel.fetchCollections();
            var collections = memoModel.collections;
            print("collections: "+collections.length)
            for(var i = 0 ; i < collections.length ; ++i) {
                var cal = collections[i];
                if (cal.extendedMetaData("collection-type") === "Memo List" ) {
                    print("collectionId: "+cal.collectionId+ ", enabled: "+cal.extendedMetaData("collection-selected"))
                    cals.push(cal);
                } else {
                    print("collectionId: "+cal.collectionId+", type: "+cal.extendedMetaData("collection-type")+", name: "+cal.name)
                }
            }
            cals.sort(memoModel._sortCollections)
            return cals;
        }

        function enabledCollections() {
            var collectionIds = [];
            var collections = getCollections()
            for (var i=0; i < collections.length; ++i) {
                var collection = collections[i]
                if (collection.extendedMetaData("collection-selected") === true) {
                    collectionIds.push(collection.collectionId);
                }
            }
            return collectionIds
        }

        function applyFilterFinal() {
            var collectionIds = enabledCollections()
            collectionMemoFilter.ids = collectionIds
            filter = Qt.binding(
                        function() {
                            return mainMemoFilter;
                        }
            )
            isReady = true
        }

        filter: InvalidFilter { objectName: "invalidFilter" }

        startPeriod: new Date("") //invalid date
        endPeriod: new Date("") //invalid date

        sortOrders: [
            SortOrder{
                blankPolicy: SortOrder.BlanksFirst
                detail: Detail.EventTime
                field: EventTime.FieldStartDateTime
                direction: Qt.AscendingOrder
            }
        ]

        function updateIfNecessary() {
            if (!autoUpdate) {
                update()
            }
        }

        onStartPeriodChanged: {
            print("memoModel.onStartPeriodChanged")
            isLoading = true
        }

        onModelChanged: {
            print("memoModel.onModelChanged")
            isLoading = false
            gridView.currentIndex = selectedIndex
            if (gridView.currentItem) {
                gridView.currentItem.forceActiveFocus()
            }
        }

        onFilterChanged: {
            updateIfNecessary()
        }

        onActiveChanged: {
            if (active) {
                updateIfNecessary()
            }
        }

        Component.onCompleted: {
            if (active) {
                updateIfNecessary()
            }
            applyFilterFinal()
            console.log("Available Managers: " + availableManagers)
        }
    }

    Rectangle {
        id: background
        width: mainView.width
        height: mainView.height

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#193441" }
            GradientStop { position: 1.0; color: Qt.darker("#193441") }
        }

        FocusScope {
            id: todoFocusScope

            Rectangle {
                width: (mainView.width/2)-app.appFontSize
                height: todoHeaderLabel.height
                x:app.appFontSize/2
                y:app.appFontSize/2
                color: "#edeeef"
                opacity: 0.9
            }

            Label {
                id: todoHeaderLabel
                padding: app.appFontSize/2
                width: (mainView.width/2)-app.appFontSize
                x: app.appFontSize/2
                y: app.appFontSize/2
                text: qsTr("To-do")
                font.pixelSize: app.appFontSize * 1.5
                font.bold: true
            }

            ListView {
                id: todoListView
                width: (mainView.width/2)-app.appFontSize
                height: mainView.height - todoHeaderLabel.height - app.appFontSize*2
                x: app.appFontSize/2
                y: todoHeaderLabel.height + app.appFontSize
                model: todoModel
                interactive: todoListView.contentHeight > height

                delegate: ToDoViewItem {
                    oModel: todoModel
                }
            }
        }

        FocusScope {
            id: memoFocusScope

            Rectangle {
                width: (mainView.width/2)-app.appFontSize
                height: memoHeaderLabel.height
                x: (mainView.width/2)+app.appFontSize/2
                y: app.appFontSize/2
                color: "#edeeef"
                opacity: 0.9
            }

            Label {
                id: memoHeaderLabel
                padding: app.appFontSize/2
                width: (mainView.width/2)-app.appFontSize
                x: (mainView.width/2)+app.appFontSize/2
                y: app.appFontSize/2
                text: qsTr("Memos")
                font.pixelSize: app.appFontSize * 1.5
                font.bold: true
            }

            ListView {
                id: memoListView
                width: (mainView.width/2)-app.appFontSize
                height: mainView.height - memoHeaderLabel.height - app.appFontSize*2
                x: (mainView.width/2)+app.appFontSize/2
                y: memoHeaderLabel.height + app.appFontSize
                model: memoModel
                interactive: memoListView.contentHeight > height

                delegate: ToDoViewMemoItem {
                    oModel: memoModel
                }
            }
        }
        Keys.onPressed: {
            console.log("[TDV]key:"+event.key)
        }
    }

    Keys.onEscapePressed: {
        event.accepted = true;
    }
    Keys.onPressed: {
        console.log("key:"+event.key)

        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (selectedIndex==0) {
                dialogLoader.setSource("EditToDoDialog.qml", {"itemId": todoModel.items[selectedIndexTodo].itemId, "model":todoModel});
            } else {
                dialogLoader.setSource("EditMemoDialog.qml", {"itemId": memoModel.items[selectedIndexMemo].itemId, "model":memoModel});
            }
        }
        if (event.key === Qt.Key_Left) {
            todoListView.forceActiveFocus();
            selectedIndex = 0;
            event.accepted = true;
        }
        if (event.key === Qt.Key_Right) {
            memoListView.forceActiveFocus();
            selectedIndex = 1;
            event.accepted = true;
        }
        if (event.key === Qt.Key_Up) {
            if (selectedIndex == 0) {
                if (todoSelectedIndex === 0) {
                    todoSelectedIndex = todoListView.count - 1;
                } else {
                    todoSelectedIndex--;
                }
                todoListView.currentIndex = todoSelectedIndex;
            } else {
                if (memoSelectedIndex === 0) {
                    memoSelectedIndex = memoListView.count - 1;
                } else {
                    memoSelectedIndex--;
                }
                memoListView.currentIndex = memoSelectedIndex;
            }
            event.accepted = true;
        }
        if (event.key === Qt.Key_Down) {
            if (selectedIndex == 0) {
                if (todoSelectedIndex === todoListView.count - 1) {
                    todoSelectedIndex = 0;
                } else {
                    todoSelectedIndex++;
                }
                todoListView.currentIndex = todoSelectedIndex;
            } else {
                if (memoSelectedIndex === memoListView.count - 1) {
                    memoSelectedIndex = 0;
                } else {
                    memoSelectedIndex++;
                }
                memoListView.currentIndex = memoSelectedIndex;
            }
            event.accepted = true;
        }
    }

    QtObject {
        id: internal

        property int initialContentX;
        property int contentXactionOn;
        property int todoCellHeight;
        property int pressedContentX;
    }

    Component.onCompleted: {
        todoListView.currentIndex = todoSelectedIndex;
        memoListView.currentIndex = memoSelectedIndex;
        todoListView.forceActiveFocus();
    }
}
