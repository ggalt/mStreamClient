import QtQuick 2.13
import QtQuick.Controls 2.13

Rectangle {
    id: root

    property real volume: 0.0
    property alias unVolumeColor: current2Max.color
    property alias volumeColor: min2Current.color
    property alias volButtonColor: sliderButton.color
    property alias volButtonGradient: sliderButton.gradient

    Rectangle {
        id: current2Max
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: sliderButton.horizontalCenter
    }

    Rectangle {
        id: min2Current
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: current2Max.bottom
        anchors.bottom: parent.bottom
    }

    Rectangle {
        id: sliderButton
        width: parent.width
        height: parent.width
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            onPressAndHold: {
                sliderButton.y = mouseY
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_width:200;anchors_x:171;anchors_y:91}
}
##^##*/
