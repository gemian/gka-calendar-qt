import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: deleteDialog
    visible: true
    modality: Qt.ApplicationModal
    width: Math.max(questionRow.width, buttonRow.width)
    height: dialogColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var event;
    property var model;
    property int padding: 10;

    function deleteAndClose(eventId) {
        deleteDialog.model.removeItem(eventId);
        deleteDialog.model.updateIfNecessary();
        deleteDialog.close()
    }

    Component.onCompleted: {
        cancelButton.forceActiveFocus()
    }

    title: event.parentId ? qsTr("Delete Recurring Event") : qsTr("Delete Event");

    Column {
        id: dialogColumn
        width: questionLabel.width
        topPadding: deleteDialog.padding
        bottomPadding: deleteDialog.padding
        spacing: deleteDialog.padding

        Row {
            id: questionRow
            leftPadding: deleteDialog.padding
            rightPadding: deleteDialog.padding
            Label {
                id: questionLabel
                text: event.parentId ?
                          qsTr("Delete single event \"%1\", or all repeating events?").arg(event.displayLabel):
                          qsTr("Are you sure you want to delete the event \"%1\"?").arg(event.displayLabel);
                wrapMode: Text.Wrap
            }
        }
        Row {
            id: buttonRow
            leftPadding: deleteDialog.padding
            rightPadding: deleteDialog.padding
            spacing: deleteDialog.padding

            Button {
                id: deleteSeriesButton
                text: qsTr("Delete series")
                visible: event.parentId !== undefined
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.right: deleteIndividualButton
                onClicked: {
                    deleteAndClose(deleteDialog.event.parentId);
                }
                Keys.onEnterPressed: {
                    deleteAndClose(deleteDialog.event.parentId);
                }
                Keys.onReturnPressed: {
                    deleteAndClose(deleteDialog.event.parentId);
                }
            }

            Button {
                id: deleteIndividualButton
                text: event.parentId ? qsTr("Delete this") : qsTr("Delete")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.right: cancelButton
                onClicked: {
                    deleteAndClose(deleteDialog.event.itemId);
                }
                Keys.onEnterPressed: {
                    deleteAndClose(deleteDialog.event.itemId);
                }
                Keys.onReturnPressed: {
                    deleteAndClose(deleteDialog.event.itemId);
                }
            }

            Button {
                id: cancelButton
                text: qsTr("Cancel")
                activeFocusOnTab: true
                activeFocusOnPress: true
                focus: true
                onClicked: {
                    deleteDialog.close()
                }
                Keys.onEnterPressed: {
                    deleteDialog.close()
                }
                Keys.onReturnPressed: {
                    deleteDialog.close()
                }
            }
        }
        Keys.onEscapePressed: {
            deleteDialog.close()
        }
    }
}
