import QtQuick 2.0

Item {
    ListView {
        id: listView
        anchors.fill: parent
        model: ListModel {
            ListElement {
                name: "Artists"
            }

            ListElement {
                name: "Albums"
            }

            ListElement {
                name: "Playlists"
            }
        }
        delegate: Item {
            id: homeDelegate
            width: parent.width
            height: 62
            anchors.left: parent.left
            MouseArea {
                id: delMouse
                anchors.fill: parent
                onClicked: {
                    homeDelegate.ListView.view.currentIndex=index
                    console.log("clicked at", index, name)
                    mainWindow.actionClick(name)
                }
                onPressed: delegateRect.color = "lightgrey"
                onReleased: delegateRect.color = "white"

            }

            Rectangle {
                id: delegateRect
                color: "white"
                anchors.fill: parent
                anchors.margins: 1
                Text {
                    text: name
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    height: parent.height
                    font.pointSize: 14
                    font.family: "Arial"
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.bold: true
                }
            }
        }

    }

}
