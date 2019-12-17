import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: albumPage

    property string formName: "Album List"

    ListView {
        anchors.fill: parent
        model: albumListJSONModel.model

        delegate: Item {
            id: albumDelegate
            height: 87
            width: parent.width

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onPressAndHold: {
                    console.log("Press and Hold for:", albumLabel.text)
                }

                onClicked: {
                    albumDelegate.ListView.view.currentIndex=index
                    console.log("click for:", albumLabel.text)
                    mainWindow.requestAlbumSongs(albumLabel.text)
                }
                onPressed: albumDelegateRect.color = "lightgrey"
                onReleased: albumDelegateRect.color = "white"
            }

            Rectangle {
                id: albumDelegateRect
                color: "white"
                anchors.fill: parent
                anchors.margins: 1
                Image {
                    id: albumImage
                    height: parent.height - 4
                    width: parent.height - 4
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: mainWindow.serverURL+"/album-art/"+model.album_art_file+"?token="+mainWindow.myToken
                }
                Text {
                    id: albumLabel
                    text: model.name
                    anchors.left: albumImage.right
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

