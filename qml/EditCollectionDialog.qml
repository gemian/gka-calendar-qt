import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "dateExt.js" as DateExt
import "lunar.js" as Lunar

Window {
    id: collectionDialog
    visible: true
    modality: Qt.ApplicationModal
    title: i18n.tr("Enter event details")
    height: collectionDialogFocusScope.height
    width: collectionDialogFocusScope.width
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property int padding: app.appFontSize/2
    property int spacing: app.appFontSize/3

    property var model
    property var collection

    function addCollection() {
        console.log("Add Collection");
    }

    function editCollection(c) {
        console.log("Edit Collection c:"+c);

        collectionNameField.text = c.name;
        collectionDescriptionField.text = c.description;
        collectionColourField.text = c.color;
        //c.secondaryColor;
        if (c.extendedMetaData("collection-readonly")) {
        }
        if (c.extendedMetaData("collection-sync-readonly")) {
        }
        if (c.extendedMetaData("collection-type")) {
            //Calendar
        }
        collectionSelectedCheckbox.checked = c.extendedMetaData("collection-selected") === true;
        collectionDefaultCheckbox.checked = c.extendedMetaData("collection-default") === true;
    }

    function saveAndClose() {
        if (!collection) {
            collection = Qt.createQmlObject("import QtOrganizer 5.0; Collection {}", Qt.application, "EditCollectionDialog.qml");
            collection.setExtendedMetaData("collection-type", "Calendar");
        }
        collection.name = collectionNameField.text;
        collection.description = collectionDescriptionField.text;
        collection.color = collectionColourField.text;
        collection.setExtendedMetaData("collection-selected", collectionSelectedCheckbox.checked);
        collection.setExtendedMetaData("collection-default", collectionDefaultCheckbox.checked);

        model.saveCollection(collection);
        model.updateIfNecessary()

        collectionDialog.close()
    }

    FocusScope {
        id: collectionDialogFocusScope
        width: detailsRow.width
        height: 2 * collectionDialog.padding + Math.max(mainDetailsColumn.height, buttonsColumn.height)

        Row {
            id: detailsRow
            leftPadding: collectionDialog.padding
            rightPadding: collectionDialog.padding
            spacing: collectionDialog.padding

            Column {
                id: mainDetailsColumn
                topPadding: collectionDialog.padding
                bottomPadding: collectionDialog.padding
                spacing: collectionDialog.spacing

                Label {
                    text: i18n.tr("Collection name")
                    font.pixelSize: app.appFontSize
                }
                TextField {
                    id: collectionNameField
                    activeFocusOnPress: true
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: i18n.tr("Collection name")
                    font.pixelSize: app.appFontSize
                    KeyNavigation.down: collectionDescriptionField
                    KeyNavigation.right: saveButton
                }

                Label {
                    text: i18n.tr("Collection description")
                    font.pixelSize: app.appFontSize
                }
                TextField {
                    id: collectionDescriptionField
                    activeFocusOnPress: true
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: i18n.tr("Collection description")
                    font.pixelSize: app.appFontSize
                    KeyNavigation.down: collectionColourField
                    KeyNavigation.right: saveButton
                }

                Label {
                    text: i18n.tr("Collection colour")
                    font.pixelSize: app.appFontSize
                }
                TextField {
                    id: collectionColourField
                    activeFocusOnPress: true
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    placeholderText: i18n.tr("Collection colour")
                    font.pixelSize: app.appFontSize
                    KeyNavigation.down: collectionSelectedCheckbox
                    KeyNavigation.right: saveButton
                }

                ZoomCheckBox {
                    text: i18n.tr("Collection selected")
                    id: collectionSelectedCheckbox
                    activeFocusOnPress: true
                    onCheckedChanged: {
                    }
                    KeyNavigation.down: collectionDefaultCheckbox
                    KeyNavigation.right: saveButton
                }
                ZoomCheckBox {
                    text: i18n.tr("Collection default")
                    id: collectionDefaultCheckbox
                    activeFocusOnPress: true
                    onCheckedChanged: {
                    }
                    KeyNavigation.right: saveButton
                }
            }

            Column {
                id: buttonsColumn
                topPadding: collectionDialog.padding
                bottomPadding: collectionDialog.padding
                spacing: collectionDialog.padding

                ZoomButton {
                    id: saveButton
                    text: i18n.tr("Save (ctrl-s)")
                    activeFocusOnTab: true
                    activeFocusOnPress: true
                    KeyNavigation.down: cancelButton
                    KeyNavigation.left: collectionNameField
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

                ZoomButton {
                    id: cancelButton
                    text: i18n.tr("Cancel (esc)")
                    activeFocusOnTab: true
                    activeFocusOnPress: true
                    KeyNavigation.left: collectionNameField
                    focus: true
                    onClicked: {
                        collectionDialog.close()
                    }
                    Keys.onEnterPressed: {
                        collectionDialog.close()
                    }
                    Keys.onReturnPressed: {
                        collectionDialog.close()
                    }
                }
            }
        }

        Keys.onEscapePressed: {
            collectionDialog.close()
        }
        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                saveAndClose();
            }
        }
    }

    Component.onCompleted: {
        if (collection === undefined) {
            console.log("Attempted to edit an undefined collection");
            return;
        } else if (collection === null) {
            addCollection();
        } else {
            editCollection(collection);
        }
        collectionNameField.forceActiveFocus();
    }
}
