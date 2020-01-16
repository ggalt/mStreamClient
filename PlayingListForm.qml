import QtQuick 2.13

ScrollingListView {
    id: playlistForm
    objectName: "playlistForm"

    formName: "Playlist"
    myModel: currentPlayList.model

    myHighLight: highlight
    myhighlightRangeMode: ListView.NoHighlightRange

    property int delegateHeight: 87
    property int delegateWidth: width

    highlightFollowsCurrentItem: true

    function setCurrentIndex(idx) {
        console.log("set current index to:", idx)
        setListViewIndex(idx)
    }

    myDelegate:Item {
        id: songTitleDelegate
        height: delegateHeight
        width: delegateWidth

        property variant myData: model

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton || Qt.RightButton

            onPressAndHold: {
                console.log("Press and Hold for:", albumLabel.text)
            }

            onClicked: {
                console.log("clicked on item nubmer:", index)
                setCurrentIndex(index)
                mainWindow.selectSongAtIndex(myCurrentIndex)
            }
            onPressed: songTitleDelegateRect.color = "lightgrey"
            onReleased: songTitleDelegateRect.color = "white"
        }

        Rectangle {
            id: songTitleDelegateRect
//            color: "white"
            anchors.fill: parent
            anchors.margins: 2
            opacity: myCurrentIndex === index ? 0.8 : 1.0
            Image {
                id: albumImage
                height: parent.height - 4
                width: parent.height - 4
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: mainWindow.serverURL+"/album-art/"+model.metadata["album-art"]+"?token="+mainWindow.myToken  // NOTE: using metadata.album-art fails
            }
            Text {
                id: albumLabel
                text: model.metadata.track+" - "+model.metadata.title
                anchors.left: albumImage.right
                anchors.leftMargin: 5
                height: parent.height
                font.pointSize: 12
                font.family: "Arial"
                verticalAlignment: Text.AlignVCenter
            }
        }

    }
    Component {
        id: highlight
        Rectangle {
            width: delegateWidth
            height: delegateHeight
            color: "yellow"
            border.width: 2
            border.color: "yellow"
            y: playlistForm.myCurrentItem.y
//            Behavior on y {
//                SpringAnimation {
//                    spring: 3
//                    damping: 0.2
//                }
//            }
        }
    }
}
