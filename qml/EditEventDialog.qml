import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

Window {
    id: eventDialog
    visible: true
    modality: Qt.ApplicationModal
    title: i18n.tr("Enter event details")
    height: dialogFocusScope.height
    width: dialogFocusScope.width
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property int padding: 4
    property int spacing: 1

    property var startDate:null
    property var endDate:null
    property var eventObject:null
    property var eventId:null
    property var allDay:null
    property var model:null

    property int activeExtrasIndex: 0
    property var localeTimeInputMask: makeLocaleTimeInputMask()
    property var localeDateInputMask: makeLocaleDateInputMask()
    property var recurrenceValue: [RecurrenceRule.Invalid, RecurrenceRule.Daily, RecurrenceRule.Weekly, RecurrenceRule.Monthly, RecurrenceRule.Yearly]

    function addEvent() {
        internal.collectionId = model.getDefaultCollection().collectionId;
        internal.originalCollectionId = "";
//        console.log("default collection writable:"+model.collectionIdIsWritable(internal.collectionId));
//        console.log("Add Event Setting default collection:"+internal.collectionId);
    }

    function editEvent(e) {
        console.log("e.itemType:"+e.itemType);
        //If there is a RecurenceRule use that , else create fresh Recurence Object.
        var isOcurrence = ((e.itemType === Type.EventOccurrence) || (e.itemType === Type.TodoOccurrence));
        if (!isOcurrence && e.recurrence.recurrenceRules[0] !== undefined && e.recurrence.recurrenceRules[0] !== null) {
            var rule = e.recurrence.recurrenceRules[0];
            internal.repeatIndex = recurrenceValue[rule.frequency];
            setRepeatButton(internal.repeatIndex, true);
            if (rule.daysOfWeek.indexOf(Qt.Monday) !== -1) {
                weeklyRepeatMon.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Tuesday) !== -1) {
                weeklyRepeatTue.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Wednesday) !== -1) {
                weeklyRepeatWed.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Thursday) !== -1) {
                weeklyRepeatThu.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Friday) !== -1) {
                weeklyRepeatFri.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Saturday) !== -1) {
                weeklyRepeatSat.checked = true;
            }
            if (rule.daysOfWeek.indexOf(Qt.Sunday) !== -1) {
                weeklyRepeatSun.checked = true;
            }
            if (internal.repeatIndex == 3) {
                if (rule.daysOfMonth > 0) {
                    setRepeatMonthlyButton(0, false);
                }
                for (var i=0; i < rule.positions.length; i++) {
                    if (rule.positions[i] === -1) {
                        setRepeatMonthlyButton(2, false);
                    } else if (rule.positions[i] > 0) {
                        setRepeatMonthlyButton(1, false);
                    }
                }
            }

            if (rule.limit === undefined) {
                internal.repeatUntilIndex = 0;
            } else if (rule.limit instanceof Date) {
                internal.repeatUntilIndex = 2;
                repeatUntilDateField.text = rule.limit.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
            } else {
                internal.repeatUntilIndex = 1;
                repeatUntilCountField.text = rule.limit;
            }
            setRepeatUntilButton(internal.repeatUntilIndex, false);
        }

        eventDialog.startDate = new Date(e.startDateTime);

        if (e.displayLabel) {
            eventNameField.text = e.displayLabel;
        }

        allDayEventCheckbox.checked = e.allDay;

        var eventEndDate = e.endDateTime
        if (!eventEndDate || isNaN(eventEndDate.getTime()))
            eventEndDate = new Date(startDate)

        if (e.allDay) {
            allDayEventCheckbox.checked = true
            eventDialog.endDate = new Date(eventEndDate).addDays(-1);
            internal.eventSize = DateExt.daysBetween(eventDialog.startDate, eventEndDate) * internal.millisecsInADay
        } else {
            eventDialog.endDate = eventEndDate
            internal.eventSize = (eventEndDate.getTime() - eventDialog.startDate.getTime())
        }

        if(e.location) {
            locationField.text = e.location;
        }

        if( e.description ) {
            descriptionField.text = e.description;
        }

        var index = 0;

        var reminder = e.detail(Detail.VisualReminder)
        // fallback to audible
        if (!reminder)
            reminder = e.detail(Detail.AudibleReminder)

        if (reminder) {
            internal.reminderValue = reminder.secondsBeforeStart
        } else {
            internal.reminderValue = -1
        }
        internal.collectionId = internal.originalCollectionId = e.collectionId;
    }

    function saveEvent(event) {
        console.log("eD:startDateTime: "+eventDialog.startDate);

        if (eventDialog.startDate > eventDialog.endDate && !allDayEventCheckbox.checked) {
            console.log("End time can't be before start time");
        } else {
            if (internal.collectionId !== internal.originalCollectionId) {
                //collection change to event is not supported
                //to change collection we create new event with same data with different collection
                //and remove old event
                if (event && event.itemId) {
                    model.removeItem(event.itemId);
                }
                event = Qt.createQmlObject("import QtOrganizer 5.0; Event {}", Qt.application, "EditEventDialog.qml");
            } else {
//                console.log("saving event: "+event);
            }

            event.allDay = allDayEventCheckbox.checked;
            if (event.allDay) {
                event.startDateTime = eventDialog.startDate.midnightUTC();
                event.endDateTime = eventDialog.endDate.addDays(1).midnightUTC();
//                console.log("e:startDateTime: "+event.startDateTime);
            } else {
                event.startDateTime = eventDialog.startDate;
                event.endDateTime = eventDialog.endDate;
            }

            event.displayLabel = eventNameField.text;
            event.description = descriptionField.text;
            event.location = locationField.text;

            //Set the Rule object to an event
            var recurrenceRule = recurrenceValue[internal.repeatIndex];
            if (recurrenceRule !== RecurrenceRule.Invalid) {
                var rule = event.recurrence.recurrenceRules[0];
                if (rule === null || rule === undefined ){
                    rule = Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", event, "EditEventDialog.qml");
                }
                rule.frequency = recurrenceRule;
                if (internal.repeatIndex == 2) { //weekly
                    var weekDays = [];
                    if (weeklyRepeatMon.checked) weekDays.push(Qt.Moday);
                    if (weeklyRepeatTue.checked) weekDays.push(Qt.Tuesday);
                    if (weeklyRepeatWed.checked) weekDays.push(Qt.Wednesday);
                    if (weeklyRepeatThu.checked) weekDays.push(Qt.Thursday);
                    if (weeklyRepeatFri.checked) weekDays.push(Qt.Friday);
                    if (weeklyRepeatSat.checked) weekDays.push(Qt.Saturday);
                    if (weeklyRepeatSun.checked) weekDays.push(Qt.Sunday);
                    rule.daysOfWeek = weekDays;
                }

                if (internal.repeatUntilIndex == 1 && internal.repeatIndex > 0 && repeatUntilCountField.text != "") {
                    rule.limit = parseInt(repeatUntilCountField.text);
                } else if (internal.repeatUntilIndex == 2 && internal.repeatIndex > 0) {
                    rule.limit = updateDateTimeWithDateText(rule.limit, repeatUntilDateField.text);
                } else {
                    rule.limit = undefined;
                }
                event.recurrence.recurrenceRules = [rule]
            }

            var isOcurrence = ((event.itemType === Type.EventOccurrence) || (event.itemType === Type.TodoOccurrence))
            if (!isOcurrence) {
                if (rule !== null && rule !== undefined) {
                    // update monthly rule with final event day
                    // we need to do it here to make sure that the day is the same day as the event startDate
                    if (rule.frequency === RecurrenceRule.Monthly) {
                        if (internal.repeatMonthlyIndex == 0) {
                            rule.daysOfMonth = [event.startDateTime.getDate()]
                            rule.positions = [];
                            rule.daysOfWeek = [];
                            console.log("monthly repeat days"+event.startDateTime.getDate());
                        } else {
                            var pos = 0;
                            if (internal.repeatMonthlyIndex == 1) {
                                pos = Math.ceil( event.startDateTime.getDate() / 7);
                                console.log("monthly repeat position"+Math.ceil( startDate.getDate() / 7));
                            } else if (internal.repeatMonthlyIndex == 2) {
                                pos = -1;
                                console.log("monthly repeat position -1");
                            }
                            rule.daysOfMonth = [];
                            var dow=0;
                            switch (event.startDateTime.getDay()) {
                            case 0:
                                dow = Qt.Sunday;
                                break;
                            case 1:
                                dow = Qt.Monday;
                                break;
                            case 2:
                                dow = Qt.Tuesday;
                                break;
                            case 3:
                                dow = Qt.Wednesday;
                                break;
                            case 4:
                                dow = Qt.Thursday;
                                break;
                            case 5:
                                dow = Qt.Friday;
                                break;
                            case 6:
                                dow = Qt.Saturday;
                                break;

                            }
                            rule.daysOfWeek = [dow];
                            rule.positions = [pos];
                        }
                    }
                    event.recurrence.recurrenceRules = [rule]
                } else {
                    event.recurrence.recurrenceRules = [];
                }
            }

            // update the first reminder time if necessary
            var reminder = event.detail(Detail.VisualReminder)
            if (!reminder)
                reminder = event.detail(Detail.AudibleReminder)

            if (internal.reminderValue >= 0) {
                if (!reminder) {
                    reminder = Qt.createQmlObject("import QtOrganizer 5.0; VisualReminder {}", event, "")
                    reminder.repetitionCount = 0
                    reminder.repetitionDelay = 0
                }
                reminder.message = eventNameField.text
                reminder.secondsBeforeStart = internal.reminderValue
                event.setDetail(reminder)
            } else if (reminder) {
                event.removeDetail(reminder)
            }

            event.collectionId = internal.collectionId;

            var comment = event.detail(Detail.Comment);
            if (comment && comment.comment === "X-CAL-DEFAULT-EVENT") {
                event.removeDetail(comment);
            }

            model.saveItem(event) //need to specify single/all etc
            model.updateIfNecessary()
        }
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
            if (eventDialog.startDate &&
                    !weeklyRepeatMon.checked &&
                    !weeklyRepeatTue.checked &&
                    !weeklyRepeatWed.checked &&
                    !weeklyRepeatThu.checked &&
                    !weeklyRepeatFri.checked &&
                    !weeklyRepeatSat.checked &&
                    !weeklyRepeatSun.checked) {
                switch (eventDialog.startDate.getDay()) { //actually day of week 0-6
                case 0:
                    weeklyRepeatSun.checked = true;
                    break;
                case 1:
                    weeklyRepeatMon.checked = true;
                    break;
                case 2:
                    weeklyRepeatTue.checked = true;
                    break;
                case 3:
                    weeklyRepeatWed.checked = true;
                    break;
                case 4:
                    weeklyRepeatThu.checked = true;
                    break;
                case 5:
                    weeklyRepeatFri.checked = true;
                    break;
                case 6:
                    weeklyRepeatSun.checked = true;
                    break;
                }
            }
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

    function setRepeatMonthlyButton(index, setFocus) {
//        console.log("setRepeatMonthlyButton:"+index);
        internal.repeatMonthlyIndex = index;
        monthlyRepeatByDate.checked = false;
        monthlyRepeatByWeek.checked = false;
        monthlyRepeatByWeekLast.checked = false;
        switch (index) {
        case 0:
            monthlyRepeatByDate.checked = true
            if (setFocus) monthlyRepeatByDate.forceActiveFocus()
            break;
        case 1:
            monthlyRepeatByWeek.checked = true
            if (setFocus) monthlyRepeatByWeek.forceActiveFocus()
            break;
        case 2:
            monthlyRepeatByWeekLast.checked = true
            if (setFocus) monthlyRepeatByWeekLast.forceActiveFocus()
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
            //console.log("i: "+i+", c: "+c+", text:"+sample);
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

    function monthlyRepeatByWeekText(startDate) {
        var out = startDate.toLocaleDateString(Qt.locale(), 'dddd');
        switch(Math.ceil(startDate.getDate() / 7)) {
        case 1:
            out = i18n.tr("First %1").arg(out);
            break;
        case 2:
            out = i18n.tr("Second %1").arg(out);
            break;
        case 3:
            out = i18n.tr("Third %1").arg(out);
            break;
        case 4:
            out = i18n.tr("Fourth %1").arg(out);
            break;
        case 5:
            out = i18n.tr("Fifth %1").arg(out);
            break;
        }
        return out;
    }

    Connections {
        target: model
        onItemsFetched: {
            if (internal.fetchParentRequestId === requestId) {
                if (fetchedItems.length > 0) {
                    eventObject = fetchedItems[0];
                    editEvent(eventObject);
                    eventNameField.forceActiveFocus();
                } else {
                    console.warn("Fail to fetch parent event")
                }
                internal.fetchParentRequestId = -1
            } else {
                console.warn("fetched un-requested id:"+requestId+", items:"+fetchedItems)
            }
        }
    }

    FocusScope {
        id: dialogFocusScope
        visible: false
        width: detailsRow.width
        height: 8 * eventDialog.padding + mainDetailsColumn.height

        Row {
            id: detailsRow
            leftPadding: eventDialog.padding
            rightPadding: eventDialog.padding
            topPadding: eventDialog.padding
            spacing: eventDialog.padding

            Column {
                id: mainDetailsColumn
                spacing: eventDialog.spacing

                TextField {
                    id: eventNameField
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: i18n.tr("Event name")
                    font.pixelSize: app.appFontSize
                    KeyNavigation.down: locationField
                }
                TextField {
                    id: locationField
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: i18n.tr("Location")
                    font.pixelSize: app.appFontSize
                    KeyNavigation.down: allDayEventCheckbox
                }

                ZoomCheckBox {
                    text: i18n.tr("All Day Event")
                    id: allDayEventCheckbox
                    checked: false
                    onCheckedChanged: {
                        if (startDate && endDate) {
                            if (checked) {
                                internal.eventSize = Math.max(endDate.midnight().getTime() - startDate.midnight().getTime(), 0)
                            } else {
                                internal.eventSize = Math.max(endDate.getTime() - startDate.getTime(), internal.millisecsInAnHour)
                            }
                        }
                    }
                    KeyNavigation.down: !checked ? startTimeField : startDateField
                }

                Row {
                    spacing: eventDialog.spacing
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("Start Time:")
                        font.pixelSize: app.appFontSize
                    }
                    TextField {
                        id: startTimeField
                        enabled: !allDayEventCheckbox.checked
                        text: eventDialog.startDate?eventDialog.startDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                        font.pixelSize: app.appFontSize
                        KeyNavigation.down: startDateField
                        inputMask: localeTimeInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                eventDialog.startDate = updateDateTimeWithTimeText(eventDialog.startDate, text);
                                text = eventDialog.startDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                    }
                }

                Row {
                    spacing: eventDialog.spacing
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("Start Date:")
                        font.pixelSize: app.appFontSize
                    }
                    TextField {
                        id: startDateField
                        text: eventDialog.startDate?eventDialog.startDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        font.pixelSize: app.appFontSize
                        KeyNavigation.down: endTimeField
                        inputMask: localeDateInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                eventDialog.startDate = updateDateTimeWithDateText(eventDialog.startDate, text);
                                text = eventDialog.startDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                                if (eventDialog.startDate > eventDialog.endDate) {
                                    eventDialog.endDate = updateDateTimeWithDateText(eventDialog.endDate, text);
                                    endDateField.text = eventDialog.endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                datePicker.startDate = true;
                                datePicker.selectedDate = eventDialog.startDate;
                                datePicker.visible = true;
                            }
                        }
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Space) {
                                console.log("key Tab");
                                datePicker.startDate = true;
                                datePicker.selectedDate = eventDialog.startDate;
                                datePicker.visible = true;
                                event.accepted = true;
                            }
                        }
                    }
                }

                Row {
                    spacing: eventDialog.spacing
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("End Time:")
                        font.pixelSize: app.appFontSize
                    }
                    TextField {
                        id: endTimeField
                        enabled: !allDayEventCheckbox.checked
                        text: eventDialog.endDate?eventDialog.endDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):""
                        font.pixelSize: app.appFontSize
                        KeyNavigation.down: endDateField
                        inputMask: localeTimeInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                eventDialog.endDate = updateDateTimeWithTimeText(eventDialog.endDate, text);
                                text = eventDialog.endDate.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                    }
                }

                Row {
                    spacing: eventDialog.spacing
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("End Date:")
                        font.pixelSize: app.appFontSize
                    }
                    TextField {
                        id: endDateField
                        text: eventDialog.endDate?eventDialog.endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat):""
                        font.pixelSize: app.appFontSize
                        KeyNavigation.down: okButton
                        inputMask: localeDateInputMask
                        onFocusChanged: {
                            if (!activeFocus) {
                                eventDialog.endDate = updateDateTimeWithDateText(eventDialog.endDate, text);
                                text = eventDialog.endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                                if (eventDialog.startDate > eventDialog.endDate) {
                                    eventDialog.startDate = updateDateTimeWithDateText(eventDialog.startDate, text);
                                    startDateField.text = eventDialog.startDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                datePicker.startDate = false;
                                datePicker.selectedDate = eventDialog.endDate;
                                datePicker.visible = true;
                            }
                        }
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Space) {
                                console.log("key Tab");
                                datePicker.startDate = false;
                                datePicker.selectedDate = eventDialog.endDate;
                                datePicker.visible = true;
                                event.accepted = true;
                            }
                        }
                    }
                }

                Row {
                    id: okCancelButtonsRow
                    spacing: eventDialog.padding*2
                    topPadding: eventDialog.padding*2

                    ZoomButton {
                        id: okButton
                        text: i18n.tr("OK (ctrl-s)")
                        enabled: internal.collectionId !== null && model && model.collectionIdIsWritable(internal.collectionId)
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        KeyNavigation.right: cancelButton
                        onClicked: {
                            saveEvent(eventObject);
                            eventDialog.close()
                        }
                        Keys.onEnterPressed: {
                            saveEvent(eventObject);
                            eventDialog.close()
                        }
                        Keys.onReturnPressed: {
                            saveEvent(eventObject);
                            eventDialog.close()
                        }
                    }
                    ZoomButton {
                        id: cancelButton
                        text: i18n.tr("Cancel (esc)")
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

            Column {
                id: extrasColumn
                spacing: eventDialog.padding
                width: Math.max(extrasButtonRow.width, repeatButtonRow.width) + eventDialog.padding * 2

                Row {
                    id: extrasButtonRow
                    spacing: eventDialog.padding

                    ZoomButton {
                        id: descriptionButton
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        checkable: true
                        text: i18n.tr("Description (ctrl-d)")
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
                    ZoomButton {
                        id: reminderButton
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        checkable: true
                        text: i18n.tr("Alarm (ctrl-shift-A)")
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
                    ZoomButton {
                        id: repeatButton
                        checkable: true
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        text: i18n.tr("Repeat (ctrl-r)")
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
                    ZoomButton {
                        id: calendarsButton
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        checkable: true
                        text: i18n.tr("Calendar (ctrl-g)")
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
                    font.pixelSize: app.appFontSize
                    wrapMode: Text.Wrap
                    visible: activeExtrasIndex == 0
                    height: dialogFocusScope.height - (extrasButtonRow.height + eventDialog.padding * 3)
                    width: parent.width
                    onFocusChanged: {
                        if (!activeFocus) {
                            cursorPosition = 0
                        }
                    }
                }

                ListView {
                    id: reminderListView
                    clip: true
                    visible: activeExtrasIndex == 1
                    height: dialogFocusScope.height - (extrasButtonRow.height + eventDialog.padding * 3)
                    width: parent.width

                    model: RemindersModel {
                        id: reminderModel
                    }

                    ExclusiveGroup {
                        id: tabReminderGroup
                    }

                    delegate: ZoomRadioButton {
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
                    id: repeatOptionsColumn
                    spacing: eventDialog.padding
                    width: parent.width
                    visible: activeExtrasIndex == 2
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Row {
                        id: repeatButtonRow
                        spacing: eventDialog.padding
                        ZoomButton {
                            id: repeatOnceButton
                            text: i18n.tr("Once")
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
                        ZoomButton {
                            id: repeatDailyButton
                            text: i18n.tr("Daily")
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
                        ZoomButton {
                            id: repeatWeeklyButton
                            text: i18n.tr("Weekly")
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
                        ZoomButton {
                            id: repeatMonthlyButton
                            text: i18n.tr("Monthly")
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
                        ZoomButton {
                            id: repeatYearlyButton
                            text: i18n.tr("Yearly")
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
                        ZoomCheckBox {
                            id: weeklyRepeatMon
                            text: (new Date()).weekStart(1).addDays(0).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            activeFocusOnTab: true
                            KeyNavigation.right: weeklyRepeatTue
                            KeyNavigation.up: repeatWeeklyButton
                            KeyNavigation.down: weeklyRepeatSat
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatTue
                            text: (new Date()).weekStart(1).addDays(1).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            KeyNavigation.right: weeklyRepeatWed
                            KeyNavigation.up: repeatWeeklyButton
                            KeyNavigation.down: weeklyRepeatSun
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatWed
                            text: (new Date()).weekStart(1).addDays(2).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            KeyNavigation.right: weeklyRepeatThu
                            KeyNavigation.up: repeatWeeklyButton
                            KeyNavigation.down: weeklyRepeatSun
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatThu
                            text: (new Date()).weekStart(1).addDays(3).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            KeyNavigation.right: weeklyRepeatFri
                            KeyNavigation.up: repeatWeeklyButton
                            KeyNavigation.down: weeklyRepeatSun
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatFri
                            text: (new Date()).weekStart(1).addDays(4).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            KeyNavigation.up: repeatWeeklyButton
                            KeyNavigation.down: weeklyRepeatSun
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatSat
                            text: (new Date()).weekStart(1).addDays(5).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                            activeFocusOnTab: true
                            KeyNavigation.right: weeklyRepeatSun
                        }
                        ZoomCheckBox {
                            id: weeklyRepeatSun
                            text: (new Date()).weekStart(1).addDays(6).toLocaleDateString(Qt.locale(), "ddd")
                            activeFocusOnPress: true
                        }
                    }

                    Row {
                        id: monthlyRepeatRow
                        spacing: eventDialog.padding
                        visible: internal.repeatIndex == 3
                        anchors.left: parent.left
                        anchors.right: parent.right
                        ZoomButton {
                            id: monthlyRepeatByDate
                            text: i18n.tr("By Date")
                            checkable: true
                            activeFocusOnTab: true
                            activeFocusOnPress: true
                            onClicked: {
                                setRepeatMonthlyButton(0,false);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setRepeatMonthlyButton(0,false);
                                }
                            }
                            KeyNavigation.right: monthlyRepeatByWeek
                        }
                        Label {
                            id: monthlyRepeatByDateLabel
                            text: startDate?startDate.getDate():""
                            font.pixelSize: app.appFontSize
                            visible: monthlyRepeatByDate.checked
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        ZoomButton {
                            id: monthlyRepeatByWeek
                            text: i18n.tr("By Week")
                            checkable: true
                            activeFocusOnPress: true
                            activeFocusOnTab: true
                            onClicked: {
                                setRepeatMonthlyButton(1,false);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setRepeatMonthlyButton(1,false);
                                }
                            }
                            KeyNavigation.right: monthlyRepeatByWeekLast
                        }
                        Label {
                            id: monthlyRepeatByWeekLabel
                            text: startDate?monthlyRepeatByWeekText(startDate):""
                            font.pixelSize: app.appFontSize
                            visible: monthlyRepeatByWeek.checked
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        ZoomButton {
                            id: monthlyRepeatByWeekLast
                            text: i18n.tr("By Week Last")
                            checkable: true
                            visible: startDate?startDate.isLastWeek():false
                            activeFocusOnPress: true
                            activeFocusOnTab: true
                            onClicked: {
                                setRepeatMonthlyButton(2,false);
                            }
                            onFocusChanged: {
                                if (activeFocus) {
                                    setRepeatMonthlyButton(2,false);
                                }
                            }
                        }
                    }

                    Row {
                        spacing: eventDialog.padding
                        visible: internal.repeatIndex > 0
                        width: parent.width
                        ZoomButton {
                            id: repeatUntilForeverButton
                            text: i18n.tr("Forever")
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
                        ZoomButton {
                            id: repeatUntilCountButton
                            text: i18n.tr("Count Occurrences")
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
                        ZoomButton {
                            id: repeatUntilDateButton
                            text: qsTr("Until Date")
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
                            margins: eventDialog.spacing
                        }
                        placeholderText: qsTr("Occurrences")
                        font.pixelSize: app.appFontSize
                    }
                    TextField {
                        id: repeatUntilDateField
                        inputMask: localeDateInputMask
                        visible: internal.repeatIndex > 0 && internal.repeatUntilIndex == 2
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: eventDialog.spacing
                        }
                        text: startDateField.text
                        font.pixelSize: app.appFontSize
                        onFocusChanged: {
                            if (!activeFocus) {
                                var repeatUntilDate = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
                                text = repeatUntilDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                datePicker.repeatUntilDate = true;
                                datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), repeatUntilDateField.text, Locale.ShortFormat);
                                datePicker.visible = true;
                            }
                        }
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Space) {
                                console.log("key Tab");
                                datePicker.repeatUntilDate = true;
                                datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
                                datePicker.visible = true;
                                event.accepted = true;
                            }
                        }
                    }
                }

                ListView {
                    id: calendarsListView
                    clip: true
                    visible: activeExtrasIndex == 3
                    width: parent.width
                    height: dialogFocusScope.height - (extrasButtonRow.height + eventDialog.padding * 3)
                    model: eventDialog.model?eventDialog.model.getWritableAndSelectedCollections():null

                    Connections {
                        target: eventDialog.model
                        onModelChanged: {
                            calendarsListView.model = eventDialog.model.getWritableAndSelectedCollections()
                        }
                        onCollectionsChanged: {
                            calendarsListView.model = eventDialog.model.getWritableAndSelectedCollections()
                        }
                    }

                    ExclusiveGroup {
                        id: tabCalendarGroup
                    }

                    delegate: ZoomRadioButton {
                        id: calendarButton
                        text: modelData.name
                        checked: modelData.collectionId === internal.collectionId
                        exclusiveGroup: tabCalendarGroup
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        onClicked: {
                            if (modelData.collectionId !== internal.collectionId) {
                                internal.collectionId = modelData.collectionId;
                            } else {
                                internal.collectionId = null
                            }
                        }
                        Keys.onEnterPressed: {
                            if (modelData.collectionId !== internal.collectionId) {
                                internal.collectionId = modelData.collectionId;
                            } else {
                                internal.collectionId = null
                            }
                        }
                        Keys.onReturnPressed: {
                            if (modelData.collectionId !== internal.collectionId) {
                                internal.collectionId = modelData.collectionId;
                            } else {
                                internal.collectionId = null
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: focusShade
            anchors.fill: parent
            opacity: datePicker.visible ? 0.5 : 0
            color: "black"

            Behavior on opacity {
                NumberAnimation {
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: parent.opacity > 0
                onClicked: datePicker.visible = false
            }
        }

        Calendar {
            property bool startDate: true
            property bool repeatUntilDate: false
            id: datePicker
            visible: false
            z: focusShade.z + 1
            width: height
            height: parent.height * 0.9
            anchors.centerIn: parent
            focus: visible
            onClicked: visible = false
            Keys.onBackPressed: {
                event.accepted = true;
                visible = false;
            }
            Keys.onPressed: {
                if ((event.key === Qt.Key_Space) || (event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                    event.accepted = true;
                    visible = false;
                } else if (event.key === Qt.Key_Escape) {
                    selectedDate = eventDialog.startDate;
                    event.accepted = true;
                    visible = false;
                }
            }
            onVisibleChanged: {
                if (!visible) {
                    if (repeatUntilDate) {
                        repeatUntilDateField.text = selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                        repeatUntilDateField.forceActiveFocus();
                    } else if (startDate) {
                        eventDialog.startDate = updateDateTimeWithDateText(eventDialog.startDate, selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat));
                        startDateField.text = eventDialog.startDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                        startDateField.forceActiveFocus();
                    } else {
                        console.log("end selectedDate"+selectedDate);
                        eventDialog.endDate = updateDateTimeWithDateText(eventDialog.endDate, selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat));
                        endDateField.text = eventDialog.endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                        endDateField.forceActiveFocus();
                    }
                }
            }
        }

        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                saveEvent(eventObject);
                eventDialog.close()
            }
        }
        Shortcut {
            sequence: "Ctrl+d"
            onActivated: {
                setCheckedButton(0);
                descriptionField.forceActiveFocus();
            }
        }
        Shortcut {
            sequence: "Ctrl+Shift+A"
            onActivated: {
                setCheckedButton(1);
                reminderListView.forceActiveFocus();
            }
        }
        Shortcut {
            sequence: "Ctrl+r"
            onActivated: {
                setCheckedButton(2);
                setRepeatButton(internal.repeatIndex, true);
            }
        }
        Shortcut {
            sequence: "Ctrl+g"
            onActivated: {
                setCheckedButton(3);
                calendarsListView.forceActiveFocus();
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
            if (event.key === Qt.Key_Tab) {
                if (datePicker.visible) {
                    event.accepted = true;
                }
            }
            if (event.key === Qt.Key_Right) {
                switch (activeFocusItem.parent) {
                case startTimeField:
                case endTimeField:
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
                if (activeFocusItem == descriptionButton) {
                    eventNameField.forceActiveFocus();
                }
                if (activeFocusItem == descriptionField) {
                    locationField.forceActiveFocus();
                }
            }
            if (event.key === Qt.Key_Down) {
                console.log("activeFocusItem"+activeFocusItem.id);
                switch (activeFocusItem) {
                case repeatButton:
                    setRepeatButton(internal.repeatIndex, true);
                    break;
                case repeatMonthlyButton:
                    console.log("monthlydown index"+internal.repeatMonthlyIndex)
                    setRepeatMonthlyButton(internal.repeatMonthlyIndex, true);
                    break;
                case repeatDailyButton:
                case repeatYearlyButton:
                case monthlyRepeatByDate:
                case monthlyRepeatByWeek:
                case monthlyRepeatByWeekLast:
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
                    } else if (internal.repeatIndex == 3) {
                        setRepeatMonthlyButton(internal.repeatMonthlyIndex, true);
                    } else {
                        setRepeatButton(internal.repeatIndex, true);
                    }
                    break;
                case monthlyRepeatByDate:
                case monthlyRepeatByWeek:
                case monthlyRepeatByWeekLast:
                    setRepeatButton(internal.repeatIndex, true);
                    break;
                }
            }
        }
    }

    QtObject {
        id: internal

        property var collectionId: null;
        property var originalCollectionId;
        property int eventSize: -1
        property int reminderValue: -1
        property int repeatIndex: 0
        property int repeatMonthlyIndex: 0
        property int repeatUntilIndex: 0

        property int fetchParentRequestId: -1;

        readonly property int millisecsInADay: 86400000
        readonly property int millisecsInAnHour: 3600000

    }

    Component.onCompleted: {
        if (eventObject === undefined) {
            console.log("Attempted to edit an undefined event");
            return;
        } else if (eventId != null) {
//            console.log("fetchByEventId"+eventId);
            internal.fetchParentRequestId = model.fetchItems([eventId]);
        } else if (eventObject === null) {
            addEvent();
            if (!eventDialog.endDate) {
                eventDialog.endDate = eventDialog.startDate;
            }
            if (allDay) {
                allDayEventCheckbox.checked = true;
            }
        } else if ((eventObject.itemType === Type.EventOccurrence) || (eventObject.itemType === Type.TodoOccurrence)) {
//            console.log("fetchByParentEventId"+eventObject.parentId);
            internal.fetchParentRequestId = model.fetchItems([eventObject.parentId]);
        } else {
            editEvent(eventObject);
        }
        eventNameField.forceActiveFocus();
        descriptionButton.checked = true;
        dialogFocusScope.visible = true;
    }
}
