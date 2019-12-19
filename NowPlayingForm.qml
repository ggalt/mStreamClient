import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12

Item {
    id: element
    width: 400
    height: 400

    Frame {
        id: controlFrame
        y: 192
        height: 80
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }

    Frame {
        id: imageFrame
        anchors.bottom: controlFrame.top
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Image {
            id: coverImage
            anchors.fill: parent
            source:  mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
            fillMode: Image.PreserveAspectFit
        }
    }

}

/*##^##
Designer {
    D{i:1;anchors_width:200;anchors_x:31}D{i:3;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}
D{i:2;anchors_height:200;anchors_width:200;anchors_x:43;anchors_y:48}
}
##^##*/
