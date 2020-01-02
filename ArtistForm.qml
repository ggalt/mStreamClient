import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: artistPage

    property string formName: "Artist List"

    ScrollView {
        anchors.fill: parent

        ListView {
            id: listView
            highlightRangeMode: ListView.StrictlyEnforceRange
            anchors.fill: parent
            model: artistListJSONModel.model

            Timer {
                id: scrollTimer
                interval: 500
                onTriggered: {
                    stop()
                    lblLetter.state = "inactive"
                }
            }

            onContentYChanged: {
                lblLetter.state = "active"
                scrollTimer.start()
            }

            delegate: Item {
                id: artistDelegate
                height: 42
                width: parent.width

                property variant myData: model

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton // default is Qt.LeftButton only

                    onPressAndHold: {
                        console.log("Press and Hold for:", artistLabel.text)
                        contextMenu.popup()
                    }

                    onDoubleClicked: {
                        console.log("doubleclick")

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


                    onPressed: artistDelegateRect.color = "lightgrey"
                    onReleased: artistDelegateRect.color = "white"

                    Menu {
                        id: contextMenu
                        MenuItem{
                            text: "Add to Playlist"
                            onClicked: mainWindow.updatePlaylist(artistLabel.text, "artist", "add")
                        }
                        MenuItem {
                            text: "Replace Playlist With"
                            onClicked: mainWindow.updatePlaylist(artistLabel.text, "artist", "replace")
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

            Label {
                id: lblLetter
                x: 277
                y: 209
                width: 200
                height: 200
                text: listView.currentItem.myData.name[0]
                opacity: 0.5
                font.pointSize: 150
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                state: "inactive"

                states: [
                    State {
                        name: "inactive"
                        PropertyChanges {
                            target: lblLetter
                            opacity: 0.0
                        }
                    },
                    State {
                        name: "active"
                        PropertyChanges {
                            target: lblLetter
                            opacity: 0.5
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "active"

                        NumberAnimation {
                            target: lblLetter
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    },
                    Transition {
                        from: "*"
                        to: "inactive"

                        NumberAnimation {
                            target: lblLetter
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]
            }

        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
