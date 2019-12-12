import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: artistPage
    ListView {
        anchors.fill: parent
        model: artistJSONModel.model

        delegate: Item {
            id: artistDelegate
            height: 42

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                onPressAndHold: {
                    console.log("Press and Hold for:", artistLabel.text)
                }

                onClicked: {
                    artistDelegate.ListView.view.currentIndex=index
                    console.log("click for:", artistLabel.text)
                }
                onPressed: artistDelegate.color = "lightgrey"
                onReleased: artistDelegate.color = "white"
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
                    anchors.fill: parent
                }
            }

        }

    }

}

