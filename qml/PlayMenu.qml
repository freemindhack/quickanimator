import QtQuick 2.0

Item {
    id: root

    Rectangle {
        id: background
        x: -5
        width: parent.width - (x * 2)
        height: parent.height - x
        anchors.fill: parent
        border.color: "blue"
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(0.5, 0.5, 0.9, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.2, 0.2, 0.7, 1.0)
            }
        }
        opacity: myApp.model.fullScreenMode || buttonRow.x >= width || buttonRow.x <= -buttonRow.width ? 0 : 0.3
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: buttonRow
        width: childrenRect.width
        height: parent.height
        x: root.width - recordButton.x - recordButton.width //parent.width - width

        ProxyButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        ProxyButton {
            onClicked: myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
            Text { x: 2; y: 2; text:  myApp.timeFlickable.userPlay ? "Stop" : "Play" }
        }

        ProxyButton {
            id: recordButton
            Text { x: 2; y: 2; text: "Record" }
            onClicked: print("Record")
            flickStop: true
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Undo" }
            onClicked: print("undo")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Redo" }
            onClicked: print("redo")
            flickStop: true
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Foo" }
            onClicked: print("foo")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Bar" }
            onClicked: print("bar")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Baz" }
            onClicked: print("baz")
            flickStop: true
        }
    }

    FlickableMouseArea {
        anchors.fill: parent

        PropertyAnimation {
            id: snapAnimation
            target: buttonRow
            properties: "x"
            duration: 200
            easing.type: Easing.OutExpo
        }

        PropertyAnimation {
            id: bounceAnimation
            target: buttonRow
            properties: "x"
            duration: 200
            easing.type: Easing.OutBounce
        }

        function closestButton(right)
        {
            var children = buttonRow.children;
            var bestChild = null;
            var bestChildDist = right ? Number.MAX_VALUE : -Number.MAX_VALUE

            for (var i in children) {
                var child = children[right ? i : children.length - i - 1];
                if (!child.flickStop)
                    continue;
                var dist = root.width - root.mapFromItem(buttonRow, child.x, child.y).x - child.width;
                if ((right && dist > 0 && dist < bestChildDist) || (!right && dist < 0 && dist > bestChildDist)) {
                    bestChild = child;
                    bestChildDist = dist;
                }
            }

            return bestChild;
        }

        property int leftStop: parent.width
        property int rightStop: parent.width - buttonRow.width
        property int overshoot: 100

        onMomentumXUpdated: {
            // Ensure that the menu cannot be dragged passed the stop
            // points, and apply some overshoot resitance.
            var dist = Math.max(0, rightStop - buttonRow.x);
            buttonRow.x += momentumX * Math.pow(1 - (dist / overshoot), 2);
            if (buttonRow.x > leftStop)
                buttonRow.x = leftStop;
            else if (buttonRow.x < rightStop - overshoot)
                buttonRow.x = rightStop - overshoot;
        }

        onPressedChanged: {
            if (pressed) {
                snapAnimation.stop();
            } else {
                // Check if we should bounce to a button stop or the right edge
                var button = Math.abs(momentumX) > 15 ? closestButton(momentumX > 0) : null;
                if (button) {
                    stopMomentumX();
                    bounceAnimation.stop();
                    snapAnimation.to = root.width - button.x - button.width;
                    snapAnimation.restart();
                } else if (buttonRow.x < rightStop) {
                    stopMomentumX();
                    snapAnimation.stop();
                    bounceAnimation.to = rightStop
                    bounceAnimation.restart();
                }
            }
        }

        onClicked: {
            var p = mapToItem(buttonRow, mouseX, mouseY);
            var button = buttonRow.childAt(p.x, p.y);
            if (button)
                button.clicked();
        }
    }
}
