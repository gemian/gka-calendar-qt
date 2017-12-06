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

    property int activeExtrasIndex: 0;
    property var localeTimeInputMask: makeLocaleTimeInputMask();
    property var localeDateInputMask: makeLocaleDateInputMask();

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

    function setCheckedButton(index) {
        activeExtrasIndex = index;
        descriptionButton.checked = false
        reminderButton.checked = false
        repeatButton.checked = false
        calendarsButton.checked = false
        switch (index) {
        case 0:
            descriptionButton.checked = true
            break;
        case 1:
            reminderButton.checked = true
            break;
        case 2:
            repeatButton.checked = true
            break;
        case 3:
            calendarsButton.checked = true
            break;
        }
    }

    function setRepeatButton(index, setFocus) {
        internal.repeatIndex = index;
        repeatOnceButton.checked = false
        repeatDailyButton.checked = false
        repeatWeeklyButton.checked = false
        repeatMonthlyButton.checked = false
        repeatYearlyButton.checked = false
        switch (index) {
        case 0:
            repeatOnceButton.checked = true
            if (setFocus) repeatOnceButton.forceActiveFocus()
            break;
        case 1:
            repeatDailyButton.checked = true
            if (setFocus) repeatDailyButton.forceActiveFocus()
            break;
        case 2:
            repeatWeeklyButton.checked = true
            if (setFocus) repeatWeeklyButton.forceActiveFocus()
            break;
        case 3:
            repeatMonthlyButton.checked = true
            if (setFocus) repeatMonthlyButton.forceActiveFocus()
            break;
        case 4:
            repeatYearlyButton.checked = true
            if (setFocus) repeatYearlyButton.forceActiveFocus()
            break;
        }
    }

    function setRepeatUntilButton(index, setFocus) {
        internal.repeatUntilIndex = index;
        repeatUntilForeverButton.checked = false
        repeatUntilCountButton.checked = false
        repeatUntilDateButton.checked = false
        switch (index) {
        case 0:
            repeatUntilForeverButton.checked = true
            if (setFocus) repeatUntilForeverButton.forceActiveFocus()
            break;
        case 1:
            repeatUntilCountButton.checked = true
            if (setFocus) repeatUntilCountButton.forceActiveFocus()
            break;
        case 2:
            repeatUntilDateButton.checked = true
            if (setFocus) repeatUntilDateButton.forceActiveFocus()
            break;
        }
    }

    function makeLocaleMaskForSample(sample) {
        var mask = "";
        var lastWasDigit = false;
        for (var i=0; i<sample.length; i++) {
            var c = sample.substr(i,1);
            console.log("i: "+i+", c: "+c+", text:"+sample);
            if (c === ':' || c === ',' || c === '/') {
                mask += c;
            } else if (c < '0' || c > '9' || c === '\\') {
                mask += 'x';
            } else {
                if (lastWasDigit) {
                    mask += '0';
                } else {
                    mask += '9';
                }
                lastWasDigit = true;
            }
        }
        return mask;
    }

    function makeLocaleTimeInputMask() {
        var sample = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
        return makeLocaleMaskForSample(sample);
    }

    function makeLocaleDateInputMask() {
        var sample = new Date().toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        return makeLocaleMaskForSample(sample);
    }

    function updateDateTimeWithTimeText(dateTime, text) {
        var newDate = Date.fromLocaleTimeString(Qt.locale(), text, Locale.ShortFormat);
        if (!isNaN(newDate)) {
            var oldDate = new Date(dateTime);
            oldDate.setMinutes(newDate.getMinutes());
            oldDate.setHours(newDate.getHours());
            dateTime = oldDate;
        }
        return dateTime;
    }

    function updateDateTimeWithDateText(dateTime, text) {
        var newDate = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
        if (!isNaN(newDate)) {
            var oldDate = new Date(dateTime);
            oldDate.setDate(newDate.getDate());
            oldDate.setMonth(newDate.getMonth());
            oldDate.setFullYear(newDate.getFullYear());
            dateTime = oldDate;
        }
        return dateTime;
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
                        inputMask: localeTimeInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                event.startDateTime = updateDateTimeWithTimeText(event.startDateTime, text);
                                text = event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                    }
                    TextField {
                        id: startDateField
                        text: event?event.startDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.up: allDayEventCheckbox
                        KeyNavigation.down: endDateField
                        inputMask: localeDateInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                event.startDateTime = updateDateTimeWithDateText(event.startDateTime, text);
                                text = event.startDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
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
                        inputMask: localeTimeInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                event.endDateTime = updateDateTimeWithTimeText(event.endDateTime, text);
                                text = event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                    }
                    TextField {
                        id: endDateField
                        text: event?event.endDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        KeyNavigation.down: okButton
                        inputMask: localeDateInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                event.endDateTime = updateDateTimeWithDateText(event.endDateTime, text);
                                text = event.endDateTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                    }
                }

            }

            Rectangle {
                id: extrasRectangle
                width: 300
                height: 206

                Column {
                    spacing: 4
                    width: parent.width

                    Row {
                        spacing: 4

                        Button {
                            id: descriptionButton
                            width: 94
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            checkable: true
                            text: qsTr("Description")
                            onClicked: {
                                setCheckedButton(0);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setCheckedButton(0);
                                }
                            }
                            KeyNavigation.right: reminderButton
                            KeyNavigation.down: descriptionField
                        }
                        Button {
                            id: reminderButton
                            width: 50
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            checkable: true
                            text: qsTr("Alarm")
                            onClicked: {
                                setCheckedButton(1);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setCheckedButton(1);
                                }
                            }
                            KeyNavigation.right: repeatButton
                            KeyNavigation.down: reminderListView
                        }
                        Button {
                            id: repeatButton
                            width: 60
                            checkable: true
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            text: qsTr("Repeat")
                            onClicked: {
                                setCheckedButton(2);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setCheckedButton(2);
                                }
                            }
                            KeyNavigation.right: calendarsButton
                        }
                        Button {
                            id: calendarsButton
                            width: 76
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            checkable: true
                            text: qsTr("Calendar")
                            onClicked: {
                                setCheckedButton(3);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setCheckedButton(3);
                                }
                            }
                            KeyNavigation.down: calendarsListView
                        }
                    }

                    TextArea {
                        id: descriptionField
                        wrapMode: Text.Wrap
                        visible: activeExtrasIndex == 0
                        width: 300
                        height: 160
                    }

                    ListView {
                        id: reminderListView
                        clip: true
                        visible: activeExtrasIndex == 1
                        width: 300
                        height: 160

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

                    Column {
                        spacing: 4
                        width: 300
                        visible: activeExtrasIndex == 2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        topPadding: 4
                        Row {
                            spacing: 4
                            Button {
                                id: repeatOnceButton
                                text: qsTr("Once")
                                width: 40
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatButton(0,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatButton(0,false);
                                    }
                                }
                                KeyNavigation.right: repeatDailyButton
                            }
                            Button {
                                id: repeatDailyButton
                                text: qsTr("Daily")
                                width: 42
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatButton(1,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatButton(1,false);
                                    }
                                }
                                KeyNavigation.right: repeatWeeklyButton
                            }
                            Button {
                                id: repeatWeeklyButton
                                text: qsTr("Weekly")
                                width: 54
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatButton(2,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatButton(2,false);
                                    }
                                }
                                KeyNavigation.right: repeatMonthlyButton
                                KeyNavigation.down: weeklyRepeatMon
                            }
                            Button {
                                id: repeatMonthlyButton
                                text: qsTr("Monthly")
                                width: 54
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatButton(3,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatButton(3,false);
                                    }
                                }
                                KeyNavigation.right: repeatYearlyButton
                            }
                            Button {
                                id: repeatYearlyButton
                                text: qsTr("Yearly")
                                width: 48
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatButton(4,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatButton(4,false);
                                    }
                                }
                            }
                        }

                        Grid {
                            visible: internal.repeatIndex == 2
                            columns: 5
                            anchors.left: parent.left
                            anchors.right: parent.right
                            CheckBox {
                                id: weeklyRepeatMon
                                text: qsTr("Mon")
                                activeFocusOnPress: true
                                activeFocusOnTab: true
                                KeyNavigation.right: weeklyRepeatTue
                                KeyNavigation.up: repeatWeeklyButton
                                KeyNavigation.down: weeklyRepeatSat
                            }
                            CheckBox {
                                id: weeklyRepeatTue
                                text: qsTr("Tue")
                                activeFocusOnPress: true
                                KeyNavigation.right: weeklyRepeatWed
                                KeyNavigation.up: repeatWeeklyButton
                                KeyNavigation.down: weeklyRepeatSun
                            }
                            CheckBox {
                                id: weeklyRepeatWed
                                text: qsTr("Wed")
                                activeFocusOnPress: true
                                KeyNavigation.right: weeklyRepeatThr
                                KeyNavigation.up: repeatWeeklyButton
                                KeyNavigation.down: weeklyRepeatSun
                            }
                            CheckBox {
                                id: weeklyRepeatThr
                                text: qsTr("Thr")
                                activeFocusOnPress: true
                                KeyNavigation.right: weeklyRepeatFri
                                KeyNavigation.up: repeatWeeklyButton
                                KeyNavigation.down: weeklyRepeatSun
                            }
                            CheckBox {
                                id: weeklyRepeatFri
                                text: qsTr("Fri")
                                activeFocusOnPress: true
                                KeyNavigation.up: repeatWeeklyButton
                                KeyNavigation.down: weeklyRepeatSun
                            }
                            CheckBox {
                                id: weeklyRepeatSat
                                text: qsTr("Sat")
                                activeFocusOnPress: true
                                activeFocusOnTab: true
                                KeyNavigation.right: weeklyRepeatSun
                            }
                            CheckBox {
                                id: weeklyRepeatSun
                                text: qsTr("Sun")
                                activeFocusOnPress: true
                            }
                        }

                        Row {
                            spacing: 4
                            visible: internal.repeatIndex > 0
                            width: 300
                            Button {
                                id: repeatUntilForeverButton
                                text: qsTr("Forever")
                                width: 60
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatUntilButton(0,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatUntilButton(0,false);
                                    }
                                }
                                KeyNavigation.right: repeatUntilCountButton
                            }
                            Button {
                                id: repeatUntilCountButton
                                text: qsTr("Count Occurences")
                                width: 126
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatUntilButton(1,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatUntilButton(1,false);
                                    }
                                }
                                KeyNavigation.right: repeatUntilDateButton
                                KeyNavigation.down: repeatUntilCountField
                            }
                            Button {
                                id: repeatUntilDateButton
                                text: qsTr("Until Date")
                                width: 70
                                activeFocusOnTab: true
                                activeFocusOnPress: true
                                checkable: true
                                onClicked: {
                                    setRepeatUntilButton(2,false);
                                }
                                onFocusChanged: {
                                    if (activeFocus) {
                                        setRepeatUntilButton(2,false);
                                    }
                                }
                                KeyNavigation.down: repeatUntilDateField
                            }
                        }

                        TextField {
                            id: repeatUntilCountField
                            visible: internal.repeatIndex > 0 && internal.repeatUntilIndex == 1
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: 2//units.gu(2)
                            }
                            placeholderText: qsTr("Occurences")
                        }
                        TextField {
                            id: repeatUntilDateField
                            visible: internal.repeatIndex > 0 && internal.repeatUntilIndex == 2
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: 2//units.gu(2)
                            }
                            placeholderText: qsTr("End Date")
                        }
                    }

                    ListView {
                        id: calendarsListView
                        visible: activeExtrasIndex == 3
                        width: 300
                        height: 160
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
                    activeFocusOnTab: true
                    activeFocusOnPress: true
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
                    activeFocusOnTab: true
                    activeFocusOnPress: true
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
                    descriptionButton.forceActiveFocus()
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
                if (activeFocusItem == descriptionButton) {
                    eventNameField.forceActiveFocus();
                }
                if (activeFocusItem == descriptionField) {
                    locationField.forceActiveFocus();
                }
            }
            if (event.key === Qt.Key_Down) {
                switch (activeFocusItem) {
                case repeatButton:
                    setRepeatButton(internal.repeatIndex, true);
                    break;
                case repeatDailyButton:
                case repeatMonthlyButton:
                case repeatYearlyButton:
                    setRepeatUntilButton(internal.repeatUntilIndex, true);
                    break;
                }
                switch (activeFocusItem.parent) {
                case weeklyRepeatSat:
                case weeklyRepeatSun:
                    setRepeatUntilButton(internal.repeatUntilIndex, true);
                }
            }
            if (event.key === Qt.Key_Up) {
                switch (activeFocusItem) {
                case repeatOnceButton:
                case repeatDailyButton:
                case repeatWeeklyButton:
                case repeatMonthlyButton:
                case repeatYearlyButton:
                    repeatButton.forceActiveFocus();
                    break;
                case repeatUntilForeverButton:
                case repeatUntilCountButton:
                case repeatUntilDateButton:
                    if (internal.repeatIndex == 2) {
                        weeklyRepeatSat.forceActiveFocus();
                    } else {
                        setRepeatButton(internal.repeatIndex, true);
                    }
                    break;
                }
            }
        }
    }

    QtObject {
        id: internal

        property var collectionId;
        property int eventSize: -1
        property int reminderValue: -1
        property int repeatIndex: 0
        property int repeatUntilIndex: 0

        readonly property int millisecsInADay: 86400000
        readonly property int millisecsInAnHour: 3600000

    }

    //onAccepted: {
    //    saveEvent(event)
    //    console.log("Saving the event")
    //}
    //onRejected: console.log("Cancel clicked")

}
