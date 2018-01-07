import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: settingsDialog
    visible: true
    modality: Qt.ApplicationModal
    width: buttonRow.width
    height: dialogColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var settings
    property int padding: 10

    function saveAndClose() {
        settingsDialog.close()
    }

    title: qsTr("Settings");

    Column {
        id: dialogColumn
        width: buttonRow.width
        topPadding: settingsDialog.padding
        bottomPadding: settingsDialog.padding
        spacing: settingsDialog.padding

        RadioButton {
            id: showLunarCalendar
            text: qsTr("Show Lunar Calendar");
            activeFocusOnPress: true
            checked: settings.showLunarCalendar === true
            onCheckedChanged: {
                console.log("changed - "+settings+", sLC:"+settings.showLunarCalendar+", checked:"+checked)
                settings.showLunarCalendar = checked;
            }
            Keys.onEnterPressed: {
                checked = !checked
            }
            Keys.onReturnPressed: {
                checked = !checked
            }
        }


        Row {
            id: buttonRow
            leftPadding: settingsDialog.padding
            rightPadding: settingsDialog.padding
            spacing: settingsDialog.padding

            Button {
                id: okButton
                text: qsTr("OK (ctrl-s)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.up: showLunarCalendar
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
                KeyNavigation.up: showLunarCalendar
                focus: true
                onClicked: {
                    settingsDialog.close()
                }
                Keys.onEnterPressed: {
                    settingsDialog.close()
                }
                Keys.onReturnPressed: {
                    settingsDialog.close()
                }
            }
        }
        Keys.onEscapePressed: {
            settingsDialog.close()
        }
        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                saveAndClose();
            }
        }
    }
}
