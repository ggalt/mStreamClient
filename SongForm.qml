import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: songPage

    property string formName: "Song List"

    ListView {
        id: songList
        anchors.fill: parent
        model: songListJSONModel.model

        delegate: Item {
            id: songDelegate
            height: 42
            width: parent.width

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onPressAndHold: {
                    console.log("Press and Hold for:", songLabel.text)
                }

                onClicked: {
                    songDelegate.ListView.view.currentIndex=index
                    console.log("click for:", songListJSONModel.get(index).metadata.title)
                }
                onPressed: songDelegateRect.color = "lightgrey"
                onReleased: songDelegateRect.color = "white"
            }

            Rectangle {
                id: songDelegateRect
                color: "white"
                anchors.fill: parent
                anchors.margins: 1
                Image {
                    id: songImage
                    height: parent.height
                    width: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: parent.top
                    fillMode: Image.PreserveAspectFit
                    source: mainWindow.serverURL+"/album-art/"+model.metadata.album-art+"?token="+mainWindow.myToken
                }
                Text {
                    id: songLabel
                    text: model.metadata.title
                    anchors.left: songImage.right
                    anchors.leftMargin: 5
                    height: parent.height
                    font.pointSize: 12
                    font.family: "Arial"
                    verticalAlignment: Text.AlignVCenter
                }
            }

        }

    }

}

