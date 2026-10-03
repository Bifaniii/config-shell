// Botão "Atividades" no estilo do GNOME 45+: pílula da área de trabalho atual + bolinhas.
// Um clique abre/fecha a Visão geral do KWin (janelas abertas em miniatura). Sem ação ao passar o mouse.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    toolTipMainText: "Atividades"
    toolTipSubText: "Mostra as janelas abertas"

    P5Support.DataSource {
        id: comando
        engine: "executable"
        onNewData: (fonte) => disconnectSource(fonte)
    }

    fullRepresentation: MouseArea {
        id: area
        Layout.minimumWidth: Kirigami.Units.gridUnit * 2.6
        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.6
        hoverEnabled: true
        onClicked: comando.connectSource("qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut Overview")

        Rectangle {  // fundo arredondado só ao passar o mouse (realce, não abre nada)
            anchors.centerIn: parent
            width: parent.width; height: Math.min(parent.height, Kirigami.Units.gridUnit * 1.6)
            radius: height / 2
            color: Kirigami.Theme.textColor
            opacity: area.containsMouse ? 0.12 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
        Row {
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing
            Rectangle {  // área de trabalho atual
                width: Kirigami.Units.gridUnit * 1.1; height: Kirigami.Units.gridUnit * 0.45
                radius: height / 2
                color: area.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Repeater {
                model: 2
                Rectangle {
                    width: Kirigami.Units.gridUnit * 0.45; height: width; radius: width / 2
                    color: Kirigami.Theme.textColor; opacity: 0.55
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
