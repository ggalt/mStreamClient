import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import QtMultimedia 5.12

Item {
    id: element
    width: 400
    height: 400

    function loadPlaylist(currentPlaylist) {
        for( var i = 0; i < currentPlaylist.length; i++ ) {
            mediaPlayList.addItem(mainWindow.serverURL+"/media/"+currentPlaylist[i].filepath+"?token="+mainWindow.myToken)
            console.log("add item:", mainWindow.serverURL+"/media/"+currentPlaylist[i].filepath+"?token="+mainWindow.myToken)
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
        }

        onPlaylistChanged: {
            console.log("onPlaylistChanged")
        }

        onSourceChanged: {
            console.log("onSourceChanged")
        }

        onStatusChanged: {
            console.log("onStatusChanged", status)
            mainWindow.toolBarText = "Artist:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["artist"]+" - Title:"+ mainWindow.playList[mediaPlayList.currentIndex].metadata["title"]
            console.log(mediaPlayList.currentIndex)
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

        ProgressBar {
            id: progressBar
            y: 294
            height: 14
            layer.mipmap: false
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            value: mediaPlayer.position /mediaPlayer.duration
        }

        Tumbler {
            id: volTumbler
            x: 316
            y: 36
            wrap: false
            wheelEnabled: true
            visibleItemCount: 4
            model: 10
        }
    }

}

/*##^##
Designer {
    D{i:2;anchors_height:200;anchors_width:200;anchors_x:43;anchors_y:48}D{i:1;anchors_width:200;anchors_x:31}
D{i:3;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}D{i:10;anchors_width:359;anchors_x:6}
D{i:8;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}
}
##^##*/
