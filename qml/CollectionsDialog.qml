import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: collectionsDialog
    visible: true
    modality: Qt.ApplicationModal
    width: Math.max(questionRow.width, buttonRow.width)
    height: dialogColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var event
    property var model
    property var collections: collectionsDialog.model.getCollections()
    property int padding: 10

    function saveAndClose() {
        for (var i = 0 ; i < collections.length ; ++i) {
            var cal = collections[i];
            model.saveCollection(cal);
        }
        collectionsDialog.close()
    }

    Component.onCompleted: {
        calendarsListView.forceActiveFocus()
    }

    title: qsTr("Calendar Collections");

    Column {
        id: dialogColumn
        width: questionLabel.width
        topPadding: collectionsDialog.padding
        bottomPadding: collectionsDialog.padding
        spacing: collectionsDialog.padding

        Row {
            id: questionRow
            leftPadding: collectionsDialog.padding
            rightPadding: collectionsDialog.padding
            Label {
                id: questionLabel
                text: qsTr("Available Calendar Collections");
                wrapMode: Text.Wrap
            }
        }
        ListView {
            id: calendarsListView
            clip: true
            width: parent.width
            leftMargin: 5
            height: questionRow.height*5
            model: collections

            Connections {
                target: collectionsDialog.model
                onModelChanged: {
                    calendarsListView.model = collectionsDialog.model.getCollections()
                }
            }

            delegate: RadioButton {
                id: calendarRadioButton
                text: modelData.name
                activeFocusOnTab: true
                activeFocusOnPress: true
                checked: modelData.extendedMetaData("collection-selected") === true
                onCheckedChanged: {
                    modelData.setExtendedMetaData("collection-selected", checked);
                }
                Keys.onEnterPressed: {
                    checked = !checked
                }
                Keys.onReturnPressed: {
                    checked = !checked
                }
            }
        }

        Row {
            id: buttonRow
            leftPadding: collectionsDialog.padding
            rightPadding: collectionsDialog.padding
            spacing: collectionsDialog.padding

            Button {
                id: okButton
                text: qsTr("OK (ctrl-s)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.up: calendarsListView
                KeyNavigation.right: cancelButton
                onClicked: {
                    saveAndClose();
                }
                Keys.onEnterPressed: {
                    saveAndClose();
                }
                Keys.onReturnPressed: {
                    saveAndClose();
                }
            }

            Button {
                id: cancelButton
                text: qsTr("Cancel (esc)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.up: calendarsListView
                focus: true
                onClicked: {
                    collectionsDialog.close()
                }
                Keys.onEnterPressed: {
                    collectionsDialog.close()
                }
                Keys.onReturnPressed: {
                    collectionsDialog.close()
                }
            }
        }
        Keys.onEscapePressed: {
            collectionsDialog.close()
        }
        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                saveAndClose();
            }
        }
    }

    QtObject {
        id: internal

        property var collectionId;
        property var originalCollectionId;

    }
}
