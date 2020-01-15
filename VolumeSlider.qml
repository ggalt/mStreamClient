import QtQuick 2.13
import QtQuick.Controls 2.13

Rectangle {
    id: root

    property real volume: 0.3
    property real max: 1.0
    property real min: 0.0

    property alias unVolumeColor: current2Max.color
    property alias volumeColor: min2Current.color
    property alias volButtonColor: sliderButton.color
    property alias volButtonGradient: sliderButton.gradient

    Rectangle {
        id: current2Max
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: sliderButton.verticalCenter
    }

    Rectangle {
        id: min2Current
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: sliderButton.verticalCenter
        anchors.bottom: parent.bottom
    }

    Rectangle {
        id: sliderButton
        width: parent.width
        height: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        y: volume * (root.height - sliderButton.height)

        MouseArea {
            anchors.fill: parent

            drag {
                target: sliderButton
                axis:   Drag.YAxis
                maximumY: root.height - sliderButton.height
                minimumY: 0
            }

            onPositionChanged: {
                if( drag.active ) {
                    sliderButton.y = mouseY
                    console.log("y changed:", mouseY)
                }
            }
        }
    }

    Component.objectName: console.log("original y:", sliderButton.y, volume * (root.height - sliderButton.height))
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_width:200;anchors_x:171;anchors_y:91}
}
##^##*/
