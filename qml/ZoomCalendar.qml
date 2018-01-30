import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

FocusScope {
    id: zoomCalendar
    anchors.fill: parent

    property alias selectedDate: datePicker.selectedDate
    property var startDate
    signal setSelectedDate(var date)

    function updateDateTimeWithDate(dateTime, newDate) {
        var updated = new Date(dateTime);
        updated.setFullYear(newDate.getFullYear());
        updated.setMonth(newDate.getMonth());
        updated.setDate(newDate.getDate());
        return updated;
    }

    function setDateAndClose() {
        datePicker.visible = false;
        zoomCalendar.setSelectedDate(updateDateTimeWithDate(startDate, datePicker.selectedDate));
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
        id: datePicker
        visible: true
        z: focusShade.z + 1
        anchors.centerIn: parent
        focus: visible
        onClicked: {
            setDateAndClose()
        }
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }
        Keys.onPressed: {
            if ((event.key === Qt.Key_Space) || (event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                event.accepted = true;
                setDateAndClose();
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                visible = false;
            }
        }
    }

    Component.onCompleted: {
        datePicker.forceActiveFocus();
    }
}
