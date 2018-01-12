import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.1
import "ColorUtils.js" as ColorUtils

RadioButton {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    property color enabledCheckedColor: sysPalette.highlight
    property color enabledNotCheckedColor: ColorUtils.blendColors(sysPalette.windowText, sysPalette.window, 0.5)
    property color hoveredColor: ColorUtils.blendColors(sysPalette.highlight, sysPalette.window, 0.5)
    property color disabledColor: ColorUtils.blendColors(sysPalette.windowText, sysPalette.window, 0.4)

    style: RadioButtonStyle {

        indicator: Rectangle {
            opacity: control.enabled ? 1.0 : 0.5
            implicitWidth: app.appFontSize*1.2
            implicitHeight: app.appFontSize*1.2
            radius: width/2
            border.color: (control.activeFocus || control.hovered) ? hoveredColor : "#999"
            border.width: 1
            Rectangle {
                visible: control.checked
                color: control.checked ? (control.enabled ? enabledCheckedColor : disabledColor) : enabledNotCheckedColor
                radius: width/2
                anchors.margins: app.appFontSize/3
                anchors.fill: parent
            }
        }

        label: Item {
            opacity: control.enabled ? 1.0 : 0.5
            implicitWidth: __radioButtonText.implicitWidth + 4
            implicitHeight: __radioButtonText.implicitHeight + 4
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
                color: control.activeFocus ? sysPalette.highlight : "transparent"
            }
            Text {
                id: __radioButtonText
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.pixelSize: app.appFontSize
                text: control.text
                color: sysPalette.windowText
            }
        }
    }
}
