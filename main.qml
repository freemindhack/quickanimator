import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768
    property alias timeline: timeline
    property int nextSpriteNr: 0

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent

        SplitView {
            width: parent.width
            height: 2 * parent.height / 3

            Column {
                id: imageProps
                width: parent.width / 3
                onWidthChanged: keyframeProps.width = width
                height: parent.height
                spacing: 5
                TitleBar {
                    title: "Image"
                    TitleBarRow {
                        layoutDirection: Qt.RightToLeft
                        ToolButton {
                            text: "+"
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: myApp.addImage("dummy.jpeg") 
                        }
                    }
                }
                TextField {
                    x: 3
                    placeholderText: "name"
                }
            }
            Stage {
                id: stage
                width: 2 * parent.width / 3
                height: parent.height
                clip: true
                timeline: timeline
            }
        }
        SplitView {
            width: parent.width
            height: parent.height / 3
            Column {
                id: keyframeProps
                width: parent.width / 3
                height: parent.height
                onWidthChanged: imageProps.width = width
                spacing: 5
                TitleBar {
                    title: "Keyframe"
                }
                GridLayout {
                    x: 5
                    rowSpacing: 2
                    columns: 3

                    Label {
                        text: "name:"
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: stateName
                        Layout.columnSpan: 2
                        enabled: false

                        onTextChanged: {
                            if (timeline.selectedLayers.length > 0)
                                timeline.selectedLayers[0].currentState.name = text;
                        }

                        Connections {
                            target: timeline
                            onSelectedLayersArrayChanged: {
                                if (timeline.selectedLayers.length > 0) {
                                    stateName.enabled = true;
                                    stateName.text = timeline.selectedLayers[0].currentState.name;
                                } else {
                                    stateName.enabled = false;
                                    stateName.text = "";
                                }
                            }
                        }
                    }
                    Label {
                        text: "x:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "x"
                    }
                    ItemComboBox { }
                    Label {
                        text: "y:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "y"
                    }
                    ItemComboBox { }
                    Label {
                        text: "z:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "z"
                        minimumValue: 0
                    }
                    ItemComboBox { }
                    Label {
                        text: "rotation:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "rotation"
                        stepSize: 45
                    }
                    ItemComboBox { }
                    Label {
                        text: "scale:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "scale"
                        stepSize: 0.1
                        minimumValue: 0
                    }
                    ItemComboBox { }
                    Label {
                        text: "opacity:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "opacity"
                        stepSize: 0.1
                        minimumValue: 0
                        maximumValue: 1
                    }
                    ItemComboBox { }
                    Button {
                        Layout.columnSpan: 3
                        text: "Remove state"
                        onClicked: timeline.removeCurrentState();
                    }
                }
            }
            Timeline {
                id: timeline
                width: 2 * parent.width / 3
                height: parent.height
            }
        }
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            Image {
                source: "dummy.jpeg"
            }
        }
    }

    function addImage(url)
    {
        var layer = {}
        layer.sprite = stageSpriteComponent.createObject(stage.sprites)
        layer.sprite.name =  "sprite_" + nextSpriteNr++;
        timeline.addLayer(layer);
    }
}
