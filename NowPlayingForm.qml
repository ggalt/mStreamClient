import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import QtMultimedia 5.12

Item {
    id: element
    width: 400
    height: 400

    function loadPlaylist(currentPlaylist,  startingAt) {
        for( var i = startingAt; i < currentPlaylist.length; i++ ) {
            mediaPlayList.addItem(mainWindow.serverURL+"/media/"+currentPlaylist[i].filepath+"?token="+mainWindow.myToken)
//            console.log("add item:", mainWindow.serverURL+"/media/"+currentPlaylist[i].filepath+"?token="+mainWindow.myToken)
        }
    }

    MediaPlayer {
        id: mediaPlayer
        audioRole: MediaPlayer.MusicRole
        playlist: Playlist {
            id: mediaPlayList
        }
        onPlaybackStateChanged: {
            console.log("onPlaybackStateChanged", playbackState)
            if( playbackState === 0 ) {
                console.log("playlist has:", mediaPlayList.itemCount)
            }
        }

        onPlaylistChanged: {
            console.log("onPlaylistChanged")
        }

        onSourceChanged: {
            console.log("onSourceChanged")
        }

        onStatusChanged: {
            console.log("onStatusChanged", getStatus(), "error state:", errorString)
            if(mediaPlayList.currentIndex < mainWindow.playList.length && mediaPlayList.currentIndex >= 0) {
                console.log("current index and length of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
                mainWindow.toolBarText = "Artist:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["artist"]+" - Title:"+ mainWindow.playList[mediaPlayList.currentIndex].metadata["title"]
                coverImage.source=mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken


            } else {
                console.log("current index passed end of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
            }

            console.log("playlist current index:", mediaPlayList.currentIndex)
        }

        function getStatus() {
            if(status === 0)
                return "NoMedia - no media has been set."
            else if(status === 1)
                return "NoMedia - no media has been set."
            else if(status === 2)
                return "Loading - the media is currently being loaded."
            else if(status === 3)
                return "Loaded - the media has been loaded."
            else if(status === 4)
                return "Buffering - the media is buffering data."
            else if(status === 5)
                return "Stalled - playback has been interrupted while the media is buffering data."
            else if(status === 6)
                return "Buffered - the media has buffered data."
            else if(status === 7)
                return "EndOfMedia - the media has played to the end."
            else if(status === 8)
                return "InvalidMedia - the media cannot be played."
            else if(status === 9)
                return "UnknownStatus - the status of the media is unknown."
            else
                return "really unknown status!! HELP!!"

        }

        //        source: mainWindow.serverURL+"/media/"+mainWindow.playList[mainWindow.currentTrack].filepath+"?token="+mainWindow.myToken
    }

    Frame {
        id: controlFrame
        y: 320
        height: 80
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Button {
            id: btnPlay
            x: 80
            y: 8
            text: qsTr("Play")
            onClicked: {
                coverImage.source=mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
                mediaPlayer.play()
                console.log("Song duration:", mediaPlayer.duration)
                console.log("song position:", mediaPlayer.position)
                console.log("volume set:", mediaPlayer.volume)
            }
        }

        Button {
            id: btnPause
            x: 323
            y: 8
            width: 47
            height: 40
            text: qsTr("Pause")
            onClicked: mediaPlayer.pause()
        }

        Button {
            id: btnPrevious
            x: 0
            y: 8
            width: 67
            height: 40
            text: qsTr("Previous")
            onClicked:  {
                mediaPlayList.previous()
            }
        }

        Button {
            id: btnNext
            x: 202
            y: 8
            width: 65
            height: 40
            text: qsTr("Next")
            onClicked: {
                mediaPlayList.next()
            }
        }

    }

    Rectangle {
        id: rectangle
        x: 324
        y: 61
        width: 68
        height: 253
        color: "#ffffff"

        Tumbler {
            id: volTumbler
            property int volumeRange: 10
            property int currentVolume: mediaPlayer.volume * volumeRange
            anchors.fill: parent
            font.bold: true
            font.pointSize: 19
            wrap: false
            wheelEnabled: false
            visibleItemCount: 5
            model: volumeRange + 1

            currentIndex: currentVolume
            onCurrentIndexChanged: {
                currentVolume = currentIndex / volumeRange
                mediaPlayer.volume = currentIndex / volumeRange
            }
        }
    }

    Label {
        id: label
        x: 345
        y: 31
        text: qsTr("Volume:")
        anchors.horizontalCenter: rectangle.horizontalCenter
        font.pointSize: 13
    }

    Frame {
        id: imageFrame
        anchors.bottom: controlFrame.top
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Image {
            id: coverImage
            anchors.right: volTumbler.left
            anchors.rightMargin: 5
            anchors.bottom: progressBar.top
            anchors.bottomMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5

            //            source:  mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
            fillMode: Image.PreserveAspectFit
        }

        ColorProgressBar {
            id: progressBar
            y: 294
            height: 14
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            currentValue: mediaPlayer.position /mediaPlayer.duration
            progressColor: "green"
            progressOpacity: .80
            backgroundColor: "white"
        }
    }



}

/*##^##
Designer {
    D{i:2;anchors_height:200;anchors_width:200;anchors_x:43;anchors_y:48}D{i:1;anchors_width:200;anchors_x:31}
D{i:3;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}D{i:8;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}
D{i:10;anchors_width:359;anchors_x:6}
}
##^##*/

