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
    property int padding: app.appFontSize/5

    function deleteAndClose(eventId) {
        deleteDialog.model.removeItem(eventId);
        deleteDialog.model.updateIfNecessary();
        deleteDialog.close()
    }

    Component.onCompleted: {
        cancelButton.forceActiveFocus()
    }

    title: event.parentId ? i18n.tr("Delete Recurring Event") : i18n.tr("Delete Event");

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
                          i18n.tr("Delete single event \"%1\", or all repeating events?").arg(event.displayLabel):
                          i18n.tr("Are you sure you want to delete the event \"%1\"?").arg(event.displayLabel);
                font.pixelSize: app.appFontSize
                wrapMode: Text.Wrap
            }
        }
        Row {
            id: buttonRow
            leftPadding: deleteDialog.padding
            rightPadding: deleteDialog.padding
            spacing: deleteDialog.padding

            ZoomButton {
                id: deleteSeriesButton
                text: i18n.tr("Delete series (ctrl-s)")
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

            ZoomButton {
                id: deleteIndividualButton
                text: event.parentId ? i18n.tr("Delete this (ctrl-d)") : i18n.tr("Delete (ctrl-d)")
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

            ZoomButton {
                id: cancelButton
                text: i18n.tr("Cancel")
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
        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                deleteAndClose(deleteDialog.event.parentId);
            }
        }
        Shortcut {
            sequence: "Ctrl+d"
            onActivated: {
                deleteAndClose(deleteDialog.event.itemId);
            }
        }
    }
}
