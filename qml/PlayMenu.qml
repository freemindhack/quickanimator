import QtQuick 2.0

Item {
    id: root
    property bool contentsVisible: flickable.contentX < root.width

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.1
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: height
        contentWidth: root.width * 2

        Row {
            id: buttonRow
            height: parent.height
            width: childrenRect.width
            x: root.width - width

            MultiTouchButton {
                Text { x: 2; y: 2; text: "Undo" }
            }

            MultiTouchButton {
                onClicked: myApp.model.time = 0
                Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
            }

            MultiTouchButton {
                onClicked: myApp.timeline.userPlay = !myApp.timeline.userPlay
                Text { x: 2; y: 2; text:  myApp.timeline.userPlay ? "Stop" : "Play" }
            }

            MultiTouchButton {
                onClicked: menu.visible = true;
                Text { x: 2; y: 2; text: "Record" }
            }

            MultiTouchButton {
                onClicked: menu.visible = true;
                Text { x: 2; y: 2; text: "Menu" }
            }
        }
    }
}
