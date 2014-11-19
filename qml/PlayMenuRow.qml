import QtQuick 2.0

Row {
    id: root
    width: parent.width
    height: parent.height
    layoutDirection: Qt.RightToLeft
    opacity: parent.currentMenu === root ? 1 : 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
}
