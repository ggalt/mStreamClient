import QtQuick 2.13

ScrollingListView {
    id: playlistForm

    formName: "Playlist"
    myModel: currentPlayList.model
//    highlightLetter: myCurrentItem.myData.metadata.title[0]

//    function knuthShuffle(arr) {
//        var rand, temp, i;

//        for (i = arr.length - 1; i > 0; i -= 1) {
//            rand = Math.floor((i + 1) * Math.random());//get random between zero and i (inclusive)
//            temp = arr[rand];//swap i and the zero-indexed number
//            arr[rand] = arr[i];
//            arr[i] = temp;
//        }
//        return arr;
//    }


    myDelegate:Item {
        id: songTitleDelegate
        height: 87
        width: parent.width

        property variant myData: model

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton || Qt.RightButton

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
            id: songTitleDelegateRect
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
                source: mainWindow.serverURL+"/album-art/"+model.metadata["album-art"]+"?token="+mainWindow.myToken  // NOTE: using metadata.album-art fails
            }
            Text {
                id: albumLabel
                text: model.metadata.title
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


