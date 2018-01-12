import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.1
import "ColorUtils.js" as ColorUtils

CheckBox {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    property color enabledCheckedColor: sysPalette.highlight
    property color enabledNotCheckedColor: ColorUtils.blendColors(sysPalette.windowText, sysPalette.window, 0.5)
    property color hoveredColor: ColorUtils.blendColors(sysPalette.highlight, sysPalette.window, 0.5)
    property color disabledColor: ColorUtils.blendColors(sysPalette.windowText, sysPalette.window, 0.6)

    style: CheckBoxStyle {


        indicator: Rectangle {
            opacity: control.enabled ? 1.0 : 0.5
            implicitWidth: app.appFontSize*1.2
            implicitHeight: app.appFontSize*1.2
            radius: app.appFontSize/3
            border.color: (control.activeFocus || control.hovered) ? sysPalette.highlight : "#999"
            border.width: 1
            Rectangle {
                visible: control.checked
                color: control.enabled ? ((control.checked  || control.checkedState === Qt.PartiallyChecked) ? enabledCheckedColor : enabledNotCheckedColor) : disabledColor
                radius: 1
                anchors.margins: app.appFontSize/3
                anchors.fill: parent
            }
        }

        label: Item {
            opacity: control.enabled ? 1.0 : 0.5
            implicitWidth: __checkBoxText.implicitWidth + 4
            implicitHeight: __checkBoxText.implicitHeight + 4
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
                id: __checkBoxText
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.pixelSize: app.appFontSize
                text: control.text
                color: sysPalette.windowText
            }
        }
    }
}
