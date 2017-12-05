import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

Dialog {
    id: eventDialog
    visible: true
    modality: Qt.ApplicationModal
    title: startDate?qsTr("New event"):qsTr("Edit event")

    property var startDate:null;
    property var endDate:null;
    property var event:null;
    property var model:null;

    property alias allDay: allDayEventCheckbox.checked
    property int eventSize: -1

//    property alias startDate: startDateTimeInput.dateTime
//    property alias endDate: endDateTimeInput.dateTime
    property alias reminderValue: eventReminder.reminderValue

    standardButtons: StandardButton.Save | StandardButton.Cancel

    onAccepted: console.log("Saving the event")
    onRejected: console.log("Cancel clicked")

    function addEvent() {
        event = Qt.createQmlObject("import QtOrganizer 5.0; Event { }", Qt.application, "NewEvent.qml");
    }

    function editEvent(e) {
        //If there is a RecurenceRule use that , else create fresh Recurence Object.
        var isOcurrence = ((event.itemType === Type.EventOccurrence) || (event.itemType === Type.TodoOccurrence))
        if(!isOcurrence && e.recurrence.recurrenceRules[0] !== undefined
                && e.recurrence.recurrenceRules[0] !== null){
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
            eventSize = DateExt.daysBetween(startDate, eventEndDate) * root.millisecsInADay
        } else {
            endDate = eventEndDate
            eventSize = (eventEndDate.getTime() - startDate.getTime())
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
            root.reminderValue = reminder.secondsBeforeStart
        } else {
            root.reminderValue = -1
        }
        selectCalendar(e.collectionId);
    }

    Component.onCompleted: {
        if (event === undefined) {
            console.log("Attempted to edit an undefined event");
            return;
        } else if (event === null) {
            addEvent();
            event.startDateTime = startDate;
        } else {
            editEvent(event);
        }
    }

    Column {
        spacing: 1//units.gu(1)

        TextField {
            id: eventNameField
            anchors {
                left: parent.left
                right: parent.right
                margins: 2//units.gu(2)
            }
            focus: true
            placeholderText: qsTr("Event name")
        }
        TextField {
            id: locationField
            anchors {
                left: parent.left
                right: parent.right
                margins: 2//units.gu(2)
            }
            placeholderText: qsTr("Location")
        }

        Row {
            spacing: 1//units.gu(1)
            Label {
                text: qsTr("All Day Event:")
            }

            CheckBox {
                objectName: "allDayEventCheckbox"
                id: allDayEventCheckbox
                checked: false
                onCheckedChanged: {
                    if (checked)
                        root.eventSize = Math.max(endDate.midnight().getTime() - startDate.midnight().getTime(), 0)
                    else
                        root.eventSize = Math.max(endDate.getTime() - startDate.getTime(), root.millisecsInAnHour)
                }
            }
        }

        Row {
            spacing: 1//units.gu(1)

            Label {
                text: qsTr("Start:")
            }
            TextField {
                horizontalAlignment: right
                text: event?event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
            }
        }

        Row {
            spacing: 1//units.gu(1)

            Label {
                text: qsTr("End:")
            }
            TextField {
                text: event?event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
            }
        }

        Label {
            text: qsTr("Description:")
        }
        TextArea {
            id: descriptionField
            wrapMode: Text.WordWrap
        }

        RemindersModel {
            id: reminderModel
        }

        Row {
            id: eventReminder
            spacing: 1//units.gu(1)
            objectName: "eventReminder"

            property int reminderValue: -1

            Label {
                text: qsTr("Reminder")
            }
            Label {
                text: reminderModel.intervalToString(eventReminder.reminderValue)
            }
        }
    }
}
