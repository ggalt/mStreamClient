import QtQuick 2.13
import QtQuick.Controls 2.13

Item {
    height: 40

    property alias artistName: artistLabel.text


    Label {
        id: artistLabel
        text: ""
        font.pointSize: 12
        font.family: "Arial"
        verticalAlignment: Text.AlignVCenter
        anchors.leftMargin: 10
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressAndHold: console.log("Press and Hold for:", artistName.text)
        onClicked: console.log("click for:", artistName.text)
    }
}
