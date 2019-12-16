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

                onPressAndHold: {
                    console.log("Press and Hold for:", artistLabel.text)
                }

                onClicked: {
                    artistDelegate.ListView.view.currentIndex=index
                    console.log("click for:", artistLabel.text)
                    mainWindow.requestArtistAlbums(artistLabel.text)
                }
                onPressed: artistDelegateRect.color = "lightgrey"
                onReleased: artistDelegateRect.color = "white"
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

