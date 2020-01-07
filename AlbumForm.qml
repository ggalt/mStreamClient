import QtQuick 2.13
import QtQuick.Controls 2.13


ScrollingListView {
    id: albumPage

    formName: "Album List"
    myModel: albumListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]

    myDelegate: Item {
        id: albumDelegate
        height: 87
        width: parent.width

        property variant myData: model

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton // default is Qt.LeftButton only

            onPressAndHold: {
                console.log("Press and Hold for:", albumLabel.text)
            }

            onClicked: {
                if( mouse.button === Qt.RightButton) {
                    contextMenu.popup()
                } else {
                    albumDelegate.ListView.view.currentIndex=index
                    console.log("click for:", albumLabel.text)
                    mainWindow.requestAlbumSongs(albumLabel.text)
                }
            }
            onPressed: albumDelegateRect.color = "lightgrey"
            onReleased: albumDelegateRect.color = "white"
        }

        Menu {
            id: contextMenu
            MenuItem{
                text: "Add to Playlist"
                onClicked: mainWindow.updatePlaylist(albumLabel.text, "album", "add")
            }
            MenuItem {
                text: "Replace Playlist With"
                onClicked: mainWindow.updatePlaylist(albumLabel.text, "album", "replace")
            }
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

