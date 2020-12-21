import QtQuick 2.13
import QtQuick.Controls 2.13


ScrollingListView {
    id: albumPage
    objectName: "albumPage"

    formName: "Album List"
    myModel: albumListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]

    myDelegate: Item {
        //Item {
        id: albumDelegate
        height: 87
        width: parent.width

        property variant myData: model

        Rectangle {
            id: albumDelegateRect
            color: "white"
            anchors.fill: parent

            Frame {
                anchors.left: parent.left
                anchors.right: btnClearAndAddAlbum.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 2

                Image {
                    id: albumImage
                    x: -26
                    y: -12
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
                    x: 60
                    y: -14
                    text: model.name
                    anchors.left: albumImage.right
                    anchors.leftMargin: 5
                    height: parent.height
                    font.pointSize: 12
                    font.family: "Arial"
                    verticalAlignment: Text.AlignVCenter
                }
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

            }

            ImageButton {
                id: btnClearAndAddAlbum
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.verticalCenterOffset: 0
                anchors.rightMargin: 4
                height: parent.height - 2
                width: parent.height - 2
                onClicked: mainWindow.updatePlaylist(albumLabel.text, "album", "replace")
                buttonImage: "PlayListClearAdd.png"
            }
        }
    }
}



