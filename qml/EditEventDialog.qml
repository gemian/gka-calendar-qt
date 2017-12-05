import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

Dialog {
    id: eventDialog
    visible: true
    title: "Edit event"

    property var startDate:null;
    property var event:null;
    property var model:null;

    standardButtons: StandardButton.OK | StandardButton.Cancel

    onAccepted: console.log("Saving the event")
    onRejected: console.log("Cancel clicked")

    Label {
        text: "Hello world! newFor: "+
              (startDate?startDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat):"") +
              " start: " +
              (event?event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat):"");
    }
}
