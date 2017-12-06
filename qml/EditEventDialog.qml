import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

Window {
    id: eventDialog
    visible: true
    modality: Qt.ApplicationModal
    title: qsTr("Enter event details")
    height: 214
    width: 576

    property var startDate:null;
    property var endDate:null;
    property var event:null;
    property var model:null;

    property alias allDay: allDayEventCheckbox.checked

    function addEvent() {
        event = Qt.createQmlObject("import QtOrganizer 5.0; Event { }", Qt.application, "EditEventDialog.qml");
    }

    function editEvent(e) {
        //If there is a RecurenceRule use that , else create fresh Recurence Object.
        var isOcurrence = ((event.itemType === Type.EventOccurrence) || (event.itemType === Type.TodoOccurrence))
        if(!isOcurrence && e.recurrence.recurrenceRules[0] !== undefined && e.recurrence.recurrenceRules[0] !== null) {
            rule =  e.recurrence.recurrenceRules[0];
        }

        startDate =new Date(e.startDateTime);

        if(e.displayLabel) {
            eventNameField.text = e.displayLabel;
        }

        allDayEventCheckbox.checked = e.allDay;

        var eventEndDate = e.endDateTime
        if (!eventEndDate || isNaN(eventEndDate.getTime()))
            eventEndDate = new Date(startDate)

        if (e.allDay) {
            allDayEventCheckbox.checked = true
            endDate = new Date(eventEndDate).addDays(-1);
            internal.eventSize = DateExt.daysBetween(startDate, eventEndDate) * internal.millisecsInADay
        } else {
            endDate = eventEndDate
            internal.eventSize = (eventEndDate.getTime() - startDate.getTime())
        }

        if(e.location) {
            locationField.text = e.location;
        }

        if( e.description ) {
            descriptionField.text = e.description;
        }

        var index = 0;

        // Use details method to get attendees list instead of "attendees" property
        // since a binding issue was returning an empty attendees list for some use cases
        var attendees = e.details(Detail.EventAttendee);
        if (attendees){
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append({"contact": attendees[j]});
            }
        }

        var reminder = e.detail(Detail.VisualReminder)
        // fallback to audible
        if (!reminder)
            reminder = e.detail(Detail.AudibleReminder)

        if (reminder) {
            internal.reminderValue = reminder.secondsBeforeStart
        } else {
            internal.reminderValue = -1
        }
        internal.collectionId = e.collectionId;
    }

    Component.onCompleted: {
        if (event === undefined) {
            console.log("Attempted to edit an undefined event");
            return;
        } else if (event === null) {
            addEvent();
            event.startDateTime = event.endDateTime = endDate = startDate;
        } else {
            editEvent(event);
        }
        eventNameField.forceActiveFocus();
    }

    FocusScope {
        id: dialogFocusScope
        anchors.fill: parent

        Row {
            id: mainDetailsColumn
            leftPadding: 4
            rightPadding: 4
            topPadding: 4
            spacing: 4

            Column {
                spacing: 1

                TextField {
                    id: eventNameField
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: qsTr("Event name")
                    KeyNavigation.down: locationField
                }
                TextField {
                    id: locationField
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: qsTr("Location")
                    KeyNavigation.down: allDayEventCheckbox
                }

                CheckBox {
                    text: qsTr("All Day Event")
                    id: allDayEventCheckbox
                    checked: false
                    onCheckedChanged: {
                        if (checked)
                            internal.eventSize = Math.max(endDate.midnight().getTime() - startDate.midnight().getTime(), 0)
                        else
                            internal.eventSize = Math.max(endDate.getTime() - startDate.getTime(), internal.millisecsInAnHour)
                    }
                    KeyNavigation.down: !checked ? startTimeField : startDateField
                }

                Row {
                    spacing: 1//units.gu(1)
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Start:")
                    }
                    TextField {
                        id: startTimeField
                        enabled: !allDayEventCheckbox.checked
                        text: event?event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.down: endTimeField
                    }
                    TextField {
                        id: startDateField
                        text: event?event.startDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.up: allDayEventCheckbox
                        KeyNavigation.down: endDateField
                    }
                }

                Row {
                    spacing: 1//units.gu(1)
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("End:")
                    }
                    TextField {
                        id: endTimeField
                        enabled: !allDayEventCheckbox.checked
                        text: event?event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.down: okButton
                    }
                    TextField {
                        id: endDateField
                        text: event?event.endDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.down: okButton
                    }
                }

            }

            TabView {
                id: extrasTabView
                width: 300
                height: 206

                Tab {
                    activeFocusOnTab: true
                    id: descriptionTab
                    title: qsTr("Description:")
                    TextArea {
                        id: descriptionField
                        wrapMode: Text.Wrap
                    }

                }
                Tab {
                    activeFocusOnTab: true
                    title: qsTr("Alarm")

                    ListView {
                        clip: true
                        id: eventReminder


                        model: RemindersModel {
                            id: reminderModel
                        }

                        ExclusiveGroup {
                            id: tabReminderGroup
                        }

                        delegate: RadioButton {
                            id: topButton
                            text: label
                            exclusiveGroup: tabReminderGroup
                            activeFocusOnPress: true
                            activeFocusOnTab: true
                            checked: value === internal.reminderValue
                            onCheckedChanged: {
                                //console.log("RadioButton checked: "+checked+", vv: "+value+", icI: "+internal.reminderValue)
                                if (checked) {
                                    internal.reminderValue = value;
                                }
                            }
                        }
                    }
                }
                Tab {
                    activeFocusOnTab: true
                    title: qsTr("Repeat")

                    Column {
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        topPadding: 4
                        TabView {
                            id: repeatFrequencyTabView
                            anchors.left: parent.left
                            anchors.right: parent.right
                            width: 316
                            height: currentIndex == 2 ? 76 : 58
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Once")
                            }
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Daily")
                            }
                            Tab {
                                activeFocusOnTab: true
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 4
                                title: qsTr("Weekly")
                                Grid {
                                    columns: 5
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 4
                                    CheckBox {
                                        id: weeklyRepeatMon
                                        text: qsTr("Mon")
                                        activeFocusOnPress: true
                                        activeFocusOnTab: true
                                        KeyNavigation.right: weeklyRepeatTue
                                        KeyNavigation.up: repeatFrequencyTabView
                                        KeyNavigation.down: weeklyRepeatSat
                                    }
                                    CheckBox {
                                        id: weeklyRepeatTue
                                        text: qsTr("Tue")
                                        activeFocusOnPress: true
                                        KeyNavigation.right: weeklyRepeatWed
                                        KeyNavigation.up: repeatFrequencyTabView
                                        KeyNavigation.down: weeklyRepeatSun
                                    }
                                    CheckBox {
                                        id: weeklyRepeatWed
                                        text: qsTr("Wed")
                                        activeFocusOnPress: true
                                        KeyNavigation.right: weeklyRepeatThr
                                        KeyNavigation.up: repeatFrequencyTabView
                                        KeyNavigation.down: weeklyRepeatSun
                                    }
                                    CheckBox {
                                        id: weeklyRepeatThr
                                        text: qsTr("Thr")
                                        activeFocusOnPress: true
                                        KeyNavigation.right: weeklyRepeatFri
                                        KeyNavigation.up: repeatFrequencyTabView
                                        KeyNavigation.down: weeklyRepeatSun
                                    }
                                    CheckBox {
                                        id: weeklyRepeatFri
                                        text: qsTr("Fri")
                                        activeFocusOnPress: true
                                        KeyNavigation.up: repeatFrequencyTabView
                                        KeyNavigation.down: weeklyRepeatSun
                                    }
                                    CheckBox {
                                        id: weeklyRepeatSat
                                        text: qsTr("Sat")
                                        activeFocusOnPress: true
                                        activeFocusOnTab: true
                                        KeyNavigation.right: weeklyRepeatSun
                                        KeyNavigation.down: repeatDurationTabView
                                    }
                                    CheckBox {
                                        id: weeklyRepeatSun
                                        text: qsTr("Sun")
                                        activeFocusOnPress: true
                                        KeyNavigation.down: repeatDurationTabView
                                    }
                                }
                            }
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Monthly")
                            }
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Yearly")
                            }
                        }

                        TabView {
                            id: repeatDurationTabView
                            visible: repeatFrequencyTabView.currentIndex > 0
                            width: 300
                            height: 58
                            anchors.left: parent.left
                            anchors.right: parent.right
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Forever")
                            }
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Count Occurences")
                                TextField {
                                    id: repeatCountField
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        margins: 2//units.gu(2)
                                    }
                                    placeholderText: qsTr("Occurences")
                                }
                            }
                            Tab {
                                activeFocusOnTab: true
                                title: qsTr("Until Date")
                                TextField {
                                    id: repeatUntilDateField
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        margins: 2//units.gu(2)
                                    }
                                    placeholderText: qsTr("End Date")
                                }

                            }
                        }
                    }
                }
                Tab {
                    activeFocusOnTab: true
                    title: qsTr("Calendar")
                    ListView {
                        id: calendarsOption
                        model: eventDialog.model.getWritableAndSelectedCollections()

                        Connections {
                            target: eventDialog.model
                            onModelChanged: {
                                calendarsOption.model = eventDialog.model.getWritableAndSelectedCollections()
                            }
                            onCollectionsChanged: {
                                calendarsOption.model = eventDialog.model.getWritableAndSelectedCollections()
                            }
                        }

                        ExclusiveGroup {
                            id: tabCalendarGroup
                        }

                        delegate: RadioButton {
                            id: calendarButton
                            text: modelData.name
                            checked: modelData.collectionId === internal.collectionId
                            exclusiveGroup: tabCalendarGroup
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            onCheckedChanged: {
    //                            console.log("RadioButton checked: "+checked+", mDcI: "+modelData.collectionId+", icI: "+internal.collectionId)
                                if (checked) {
                                    internal.collectionId = modelData.collectionId;
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: okCancelButtons
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            Row {
                spacing: 10
                anchors.margins: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Button {
                    id: okButton
                    text: qsTr("Ok")
                    KeyNavigation.right: cancelButton
                    onClicked: {
                        save(event);
                        eventDialog.close()
                    }
                    Keys.onEnterPressed: {
                        save(event);
                        eventDialog.close()
                    }
                    Keys.onReturnPressed: {
                        save(event);
                        eventDialog.close()
                    }
                }
                Button {
                    id: cancelButton
                    text: qsTr("Cancel")
                    onClicked: {
                        eventDialog.close()
                    }
                    Keys.onEnterPressed: {
                        eventDialog.close()
                    }
                    Keys.onReturnPressed: {
                        eventDialog.close()
                    }
                    KeyNavigation.up: endDateField
                }
            }
        }
        Keys.onPressed: {
            console.log("key:"+event.key + ", aFIp:"+activeFocusItem.parent + ", aFI: "+activeFocusItem)
            if (event.key === Qt.Key_Escape) {
                eventDialog.close();
            }
            if (event.key === Qt.Key_Space) {
                //could be an options popup?
            }
            if (event.key === Qt.Key_Up) {
//                switch (activeFocusItem) {
//                case descriptionField:
//                    extrasTabView.forceActiveFocus();
//                }
            }
            if (event.key === Qt.Key_Right) {
                switch (activeFocusItem.parent) {
                case startTimeField:
                    startDateField.forceActiveFocus();
                    startDateField.cursorPosition = 0
                    break;
                case endTimeField:
                    endDateField.forceActiveFocus()
                    endDateField.cursorPosition = 0
                    break;
                case eventNameField:
                case locationField:
                case allDayEventCheckbox:
                case startDateField:
                case endDateField:
                case cancelButton:
                    descriptionTab.forceActiveFocus()
                }
            }
            if (event.key === Qt.Key_Left) {
                if (activeFocusItem.parent == startDateField) {
                    startTimeField.forceActiveFocus()
                    startTimeField.cursorPosition = startTimeField.length
                }
                if (activeFocusItem.parent == endDateField) {
                    endTimeField.forceActiveFocus()
                    endTimeField.cursorPosition = endTimeField.length
                }
            }

        }
    }

    QtObject {
        id: internal

        property var collectionId;
        property int eventSize: -1
        property int reminderValue: -1
        property var lastFocusItem: null

        readonly property int millisecsInADay: 86400000
        readonly property int millisecsInAnHour: 3600000

    }

    //onAccepted: {
    //    saveEvent(event)
    //    console.log("Saving the event")
    //}
    //onRejected: console.log("Cancel clicked")

}
