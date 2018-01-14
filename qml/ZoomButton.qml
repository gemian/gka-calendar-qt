import QtQuick 2.7
import QtOrganizer 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.1
import "ColorUtils.js" as ColorUtils

Button {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    property color checkedNotActiveColor: ColorUtils.blendColors(sysPalette.highlight, sysPalette.button, 0.5)

    style: ButtonStyle {
        background: Rectangle {
            opacity: control.enabled ? 1.0 : 0.5
            implicitWidth: 60
            implicitHeight: 25
            radius: app.appFontSize/3
            color: control.pressed || control.activeFocus ? sysPalette.highlight : sysPalette.button
            border.color: (control.activeFocus || control.hovered) ? sysPalette.highlight : "#999"
            border.width: control.activeFocus ? 2 : 1
            gradient: Gradient {
                GradientStop {
                    color: control.activeFocus ?
                               Qt.lighter(sysPalette.highlight, 1.03)
                             : control.checked ? checkedNotActiveColor : Qt.lighter(sysPalette.button, 1.01);
                    position: 0}
                GradientStop {
                    color: control.activeFocus ?
                               Qt.darker(sysPalette.highlight, 1.10)
                             : control.checked ? checkedNotActiveColor : Qt.darker(sysPalette.button, 1.03);
                    position: 1}
            }
        }
        label: Text {
            opacity: control.enabled ? 1.0 : 0.5
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: app.appFontSize
            text: control.text
        }
    }
}
