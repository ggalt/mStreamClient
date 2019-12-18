import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: artistPage

    property string formName: "Artist List"

    ListView {
        anchors.fill: parent
        model: artistListJSONModel.model

        delegate: Item {
            id: artistDelegate
            height: 42
            width: parent.width

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton // default is Qt.LeftButton only

                onPressAndHold: {
                    console.log("Press and Hold for:", artistLabel.text)
                    contextMenu.popup()
                }

                onClicked: {
                    if( mouse.button === Qt.RightButton) {
                        contextMenu.popup()
                    } else {
                        artistDelegate.ListView.view.currentIndex=index
                        console.log("click for:", artistLabel.text)
                        mainWindow.requestArtistAlbums(artistLabel.text)
                    }
                }

                onDoubleClicked: {
                    console.log("doubleclick")

                }

                onPressed: artistDelegateRect.color = "lightgrey"
                onReleased: artistDelegateRect.color = "white"

                Menu {
                    id: contextMenu
                    MenuItem{
                        text: "Add to Playlist"
//                        mainWindows.updatePlaylist(artistLabel.text, "artist", "add")
                    }
                    MenuItem {
                        text: "Replace Playlist With"
                    }
                    onClosed: {
                        if( contextMenu.currentIndex === 1 ) {
                            console.log("context menu item:", contextMenu.currentIndex)
                        }
                    }
                }
            }

            Rectangle {
                id: artistDelegateRect
                color: "white"
                anchors.fill: parent
                anchors.margins: 1
                Text {
                    id: artistLabel
                    text: model.name
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    height: parent.height
                    font.pointSize: 12
                    font.family: "Arial"
                    verticalAlignment: Text.AlignVCenter
                }
            }

        }

    }

}

