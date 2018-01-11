import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: colourDialog
    visible: true
    modality: Qt.ApplicationModal
    width: redSlider.width + padding * 2
    height: dialogColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var colour;
    property int padding: 10;

    function saveAndClose() {
        colourDialog.close()
    }

    function toHex(d) {
        var hex = Math.round(d).toString(16);

        while (hex.length < 2) {
            hex = "0" + hex;
        }

        return hex;
    }

    function updateHex() {
        colourHexField.text = "#" + toHex(redSlider.value) + toHex(greenSlider.value) + toHex(blueSlider.value)
    }

    function updateSliders() {

    }

    title: qsTr("Colour for collection");

    Column {
        id: dialogColumn
        leftPadding: colourDialog.padding
        rightPadding: colourDialog.padding
        topPadding: colourDialog.padding
        bottomPadding: colourDialog.padding
        spacing: colourDialog.padding

        Label {
            id: questionLabel
            text: qsTr("Adjust colour");
        }

        TextField {
            id: colourHexField
            placeholderText: qsTr("Colour hex")
            KeyNavigation.down: redSlider
            KeyNavigation.right: saveButton
        }

        Slider {
            id: redSlider
            activeFocusOnTab: true
            activeFocusOnPress: true
            KeyNavigation.down: greenSlider
            minimumValue: 0
            maximumValue: 255
            onValueChanged: activeFocus ? updateHex() : null
        }

        Slider {
            id: greenSlider
            activeFocusOnTab: true
            activeFocusOnPress: true
            KeyNavigation.down: blueSlider
            minimumValue: 0
            maximumValue: 255
            onValueChanged: activeFocus ? updateHex() : null
        }

        Slider {
            id: blueSlider
            activeFocusOnTab: true
            activeFocusOnPress: true
            KeyNavigation.down: saveButton
            minimumValue: 0
            maximumValue: 255
            onValueChanged: activeFocus ? updateHex() : null
        }

        Row {
            id: buttonsRow
            topPadding: colourDialog.padding
            bottomPadding: colourDialog.padding
            spacing: colourDialog.padding

            Button {
                id: saveButton
                text: qsTr("Save (ctrl-s)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.up: blueSlider
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
                text: qsTr("Cancel")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.up: blueSlider
                onClicked: {
                    colourDialog.close()
                }
                Keys.onEnterPressed: {
                    colourDialog.close()
                }
                Keys.onReturnPressed: {
                    colourDialog.close()
                }
            }
        }
        Keys.onPressed: {
            console.log("key:"+event.key)
        }

        Keys.onEscapePressed: {
            colourDialog.close()
        }
        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                saveAndClose();
            }
        }
    }

    Component.onCompleted: {
        redSlider.forceActiveFocus()
    }

}
