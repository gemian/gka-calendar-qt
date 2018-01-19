import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.1

Window {
    id: collectionsDialog
    visible: true
    modality: Qt.ApplicationModal
    width: collectionsRow.width
    height: collectionsActionColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var event
    property var model
    property var collections: collectionsDialog.model.getCollections()
    property int padding: app.appFontSize

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    function addCollection() {
        subDialogLoader.setSource("EditCollectionDialog.qml", {
            "model":collectionsDialog.model,
            "collection":null
        });
    }

    function editCollection() {
        subDialogLoader.setSource("EditCollectionDialog.qml", {
            "model":collectionsDialog.model,
            "collection":collections[calendarsListView.currentIndex]
        });
    }

    function deleteCollection() {
        model.removeCollection(collections[calendarsListView.currentIndex].collectionId);
    }

    function selectCollection() {
        var cal = collections[calendarsListView.currentIndex]
        cal.setExtendedMetaData("collection-selected", !cal.extendedMetaData("collection-selected"));
        model.saveCollection(cal);
        console.log("selectCollection"+cal.extendedMetaData("collection-selected"));
    }

    title: qsTr("Calendar Collections");

    Loader {
        id: subDialogLoader
        visible: status == Loader.Ready
        onStatusChanged: {
            console.log("subDialogLoader onStateChanged");
        }
        onLoaded: {
            console.log("subDialogLoader onLoaded");
        }
        State {
            name: 'loaded';
            when: loader.status === Loader.Ready
        }
    }

    Row {
        id: collectionsRow
        spacing: collectionsDialog.padding

        Column {
            id: dialogColumn
            width: questionLabel.width+app.appFontSize*3
            topPadding: collectionsDialog.padding
            bottomPadding: collectionsDialog.padding
            rightPadding: collectionsDialog.padding
            spacing: collectionsDialog.padding

            Row {
                id: questionRow
                leftPadding: collectionsDialog.padding
                rightPadding: collectionsDialog.padding
                Label {
                    id: questionLabel
                    text: qsTr("Available Calendar Collections");
                    font.pixelSize: app.appFontSize
                    wrapMode: Text.Wrap
                }
            }
            ListView {
                id: calendarsListView
                clip: true
                width: dialogColumn.width
                height: collectionsActionColumn.height
                leftMargin: 5
                model: collections
                focus: true
                activeFocusOnTab: true

                Connections {
                    target: collectionsDialog.model
                    onModelChanged: {
                        collections = collectionsDialog.model.getCollections()
                        calendarsListView.model = collections
                    }
                }

                Component {
                    id: collectionDelegate

                    Item {
                        id: collectionItem
                        width: collectionRow.width
                        height: collectionName.height + collectionsDialog.padding

                        Rectangle {
                            anchors.fill: parent
                            visible: collectionItem.ListView.isCurrentItem
                            gradient: Gradient {
                                GradientStop {color: collectionItem.activeFocus ? Qt.lighter(sysPalette.highlight, 1.03) : Qt.lighter(sysPalette.button, 1.01) ; position: 0}
                                GradientStop {color: collectionItem.activeFocus ? Qt.darker(sysPalette.highlight, 1.10) :  Qt.darker(sysPalette.button, 1.03) ; position: 1}
                            }
                            color: collectionItem.pressed || collectionItem.activeFocus ? sysPalette.highlight : sysPalette.button
                            radius: app.appFontSize/3
                            border.color: (collectionItem.activeFocus || collectionItem.hovered) ? sysPalette.highlight : "#999"
                        }

                        Row {
                            id: collectionRow
                            leftPadding: collectionsDialog.padding/2
                            rightPadding: collectionsDialog.padding/2
                            topPadding: collectionsDialog.padding/2
                            bottomPadding: collectionsDialog.padding/2
                            spacing: collectionsDialog.padding

                            Rectangle {
                                width: padding*2
                                height: collectionName.height
                                radius: padding/2
                                color: modelData.color
                                Rectangle {
                                    width: padding
                                    height: collectionName.height
                                    radius: padding
                                    anchors.centerIn: parent
                                    opacity: collections[index].extendedMetaData("collection-selected")?0:0.5
                                    color: "white"
                                    Rectangle {
                                        width: padding
                                        height: padding/3
                                        radius: padding
                                        anchors.centerIn: parent
                                        color: modelData.color
                                    }
                                }
                            }

                            Label {
                                id: collectionName
                                text: modelData.name
                                font.pixelSize: app.appFontSize
                                font.bold: collections[index].extendedMetaData("collection-default")
                                color: collectionItem.activeFocus ? sysPalette.highlightedText : sysPalette.buttonText
                            }

                        }
                        Keys.onEnterPressed: {
                            editCollection();
                        }
                        Keys.onReturnPressed: {
                            editCollection();
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                calendarsListView.currentIndex = index
                                calendarsListView.currentItem.forceActiveFocus()
                            }
                        }
                    }
                }

                delegate: collectionDelegate
            }
        }

        Column {
            id: collectionsActionColumn
            topPadding: collectionsDialog.padding
            bottomPadding: collectionsDialog.padding
            leftPadding: collectionsDialog.padding
            rightPadding: collectionsDialog.padding
            spacing: collectionsDialog.padding

            ZoomButton {
                id: addCollectionButton
                activeFocusOnTab: true
                activeFocusOnPress: true
                text: qsTr("Add (ctrl-a)")
                onClicked: {
                    addCollection();
                }
                Keys.onEnterPressed: {
                    addCollection();
                }
                Keys.onReturnPressed: {
                    addCollection();
                }
                KeyNavigation.left: calendarsListView
                KeyNavigation.down: editCollectionButton
            }

            ZoomButton {
                id: editCollectionButton
                activeFocusOnTab: true
                activeFocusOnPress: true
                text: qsTr("Edit (ctrl-e)")
                onClicked: {
                    editCollection();
                }
                Keys.onEnterPressed: {
                    editCollection();
                }
                Keys.onReturnPressed: {
                    editCollection();
                }
                KeyNavigation.left: calendarsListView
                KeyNavigation.down: deleteCollectionButton
            }
            ZoomButton {
                id: deleteCollectionButton
                activeFocusOnTab: true
                activeFocusOnPress: true
                text: qsTr("Delete (ctrl-d)")
                onClicked: {
                    deleteCollection();
                }
                Keys.onEnterPressed: {
                    deleteCollection();
                }
                Keys.onReturnPressed: {
                    deleteCollection();
                }
                KeyNavigation.left: calendarsListView
                KeyNavigation.down: selectCollectionButton
            }
            ZoomButton {
                id: selectCollectionButton
                activeFocusOnTab: true
                activeFocusOnPress: true
                text: collections[calendarsListView.currentIndex].extendedMetaData("collection-selected") !== true?qsTr("Show (ctrl-s)"):qsTr("Hide (ctrl-s)")
                onClicked: {
                    selectCollection();
                }
                Keys.onEnterPressed: {
                    selectCollection();
                }
                Keys.onReturnPressed: {
                    selectCollection();
                }
                KeyNavigation.left: calendarsListView
                KeyNavigation.down: cancelButton
            }
            ZoomButton {
                id: cancelButton
                text: qsTr("Cancel (esc)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                onClicked: {
                    collectionsDialog.close()
                }
                Keys.onEnterPressed: {
                    collectionsDialog.close()
                }
                Keys.onReturnPressed: {
                    collectionsDialog.close()
                }
                KeyNavigation.left: calendarsListView
            }
        }

        Keys.onEscapePressed: {
            collectionsDialog.close()
        }

        Shortcut {
            sequence: "Ctrl+a"
            onActivated: {
                addCollection();
            }
        }

        Shortcut {
            sequence: "Ctrl+e"
            onActivated: {
                editCollection();
            }
        }

        Shortcut {
            sequence: "Ctrl+d"
            onActivated: {
                deleteCollection();
            }
        }

        Shortcut {
            sequence: "Ctrl+s"
            onActivated: {
                selectCollection();
            }
        }
    }

    Component.onCompleted: {
        calendarsListView.forceActiveFocus()
    }
}
