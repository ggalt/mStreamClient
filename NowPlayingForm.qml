import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import QtMultimedia 5.12
import SortFilterProxyModel 0.2

Item {
    id: element
    width: 400
    height: 400

    function loadPlaylist(currentPlaylist,  startingAt) {
        for( var i = startingAt; i < currentPlaylist.length; i++ ) {
            mediaPlayList.addItem(mainWindow.serverURL+"/media/"+mainWindow.fullyEncodeURI(currentPlaylist[i].filepath)+"?token="+mainWindow.myToken)
        }
    }

    function clearPlaylist() {
        mediaPlayList.clear()
    }

    Frame {
        id: imageFrame
        x: 0
        y: 320
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
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: volSlider.left
            anchors.rightMargin: 5

            //            source:  mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
            fillMode: Image.PreserveAspectFit
        }

        ColorProgressBar {
            id: progressBar
            backgroundOpacity: 1
//            progressColor: "#0da3fa"
            progressGradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#286efe"
                }

                GradientStop {
                    position: 1
                    color: "#000000"
                }
            }
            backgroundRadius: height/2
            progressRadius: height/2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.top: coverImage.bottom
            anchors.topMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            currentValue: mediaPlayer.position /mediaPlayer.duration
            progressOpacity: 0.6
            backgroundColor: "white"
        }

        Slider {
            id: volSlider
            anchors.bottom: progressBar.top
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            orientation: Qt.Vertical
            value: mediaPlayer.volume
            onValueChanged: mediaPlayer.volume = value

        }
    }

    MediaPlayer {
        id: mediaPlayer
        audioRole: MediaPlayer.MusicRole

        autoPlay: true

        playlist: Playlist {
            id: mediaPlayList

        }
        onPlaybackStateChanged: {
            console.log("onPlaybackStateChanged", playbackState)
            if( playbackState === MediaPlayer.PlayingState ) {
                console.log("playlist has:", mediaPlayList.itemCount)
                if(mediaPlayList.currentIndex < mainWindow.playList.length && mediaPlayList.currentIndex >= 0) {
                    console.log("current index and length of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
                    mainWindow.toolBarText = "Artist:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["artist"]+" - Album:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["album"]+" - Title:"+ mainWindow.playList[mediaPlayList.currentIndex].metadata["title"]
                    coverImage.source=mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken


                } else {
                    console.log("current index passed end of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
                }
            } else if( playbackState === MediaPlayer.PausedState ) {
                console.log("Paused State")
            } else if( playbackState === MediaPlayer.StoppedState ) {
                console.log("Stopped State")
            }
        }

        onPlaylistChanged: {
            console.log("onPlaylistChanged")
        }

        onSourceChanged: {
            console.log("onSourceChanged")
        }

        onStatusChanged: {
            if( status === MediaPlayer.Loading || status === MediaPlayer.Loaded ) {
                if(mediaPlayList.currentIndex < mainWindow.playList.length && mediaPlayList.currentIndex >= 0) {
                    console.log("current index and length of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
                    mainWindow.toolBarText = "Artist:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["artist"]+" - Album:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["album"]+" - Title:"+ mainWindow.playList[mediaPlayList.currentIndex].metadata["title"]
//                    mainWindow.toolBarText = "Artist:"+mainWindow.playList[mediaPlayList.currentIndex].metadata["artist"]+" - Title:"+ mainWindow.playList[mediaPlayList.currentIndex].metadata["title"]
                    coverImage.source=mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
                    console.log("Cover image URL:", mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"])


                } else {
                    console.log("current index passed end of playlist:", mediaPlayList.currentIndex, mainWindow.playList.length)
                }
            }

            console.log("onStatusChanged", getStatus(), "error state:", errorString)

        }

        function getStatus() {
            if(status === 0)
                return "Status 0, No idea what this means"
            else if(status === MediaPlayer.NoMedia)
                return "NoMedia - no media has been set."
            else if(status === MediaPlayer.Loading)
                return "Loading - the media is currently being loaded."
            else if(status === MediaPlayer.Loaded)
                return "Loaded - the media has been loaded."
            else if(status === MediaPlayer.Buffering)
                return "Buffering - the media is buffering data."
            else if(status === MediaPlayer.Stalled)
                return "Stalled - playback has been interrupted while the media is buffering data."
            else if(status === MediaPlayer.Buffered)
                return "Buffered - the media has buffered data."
            else if(status === MediaPlayer.EndOfMedia)
                return "EndOfMedia - the media has played to the end."
            else if(status === MediaPlayer.InvalidMedia)
                return "InvalidMedia - the media cannot be played."
            else if(status === MediaPlayer.UnknownStatus)
                return "UnknownStatus - the status of the media is unknown."
            else
                return "really unknown status!! HELP!!"

        }
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

        ImageButton {
            id: btnPausePlay
            y: 8
            width: 50
            height: 50
            anchors.left: btnReverse.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            buttonImage: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "qrc:/pause.png" : "qrc:/play.png"
            onClicked: {
                coverImage.source=mainWindow.serverURL+"/album-art/"+mainWindow.playList[mainWindow.currentTrack].metadata["album-art"]+"?token="+mainWindow.myToken
                if(mediaPlayer.playbackState === MediaPlayer.PlayingState )
                    mediaPlayer.pause()
                else
                    mediaPlayer.play()
                console.log("Song duration:", mediaPlayer.duration)
                console.log("song position:", mediaPlayer.position)
                console.log("volume set:", mediaPlayer.volume)

            }
        }

        ImageButton {
            id: btnReverse
            y: 8
            width: 50
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            buttonImage: "reverse.png"
            onClicked:  mediaPlayList.previous()
        }

        ImageButton {
            id: btnForward
            y: 8
            width: 50
            height: 50
            anchors.left: btnPausePlay.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            buttonImage: "forward.png"
            onClicked: mediaPlayList.next()
        }

        ImageButton {
            id: btnLoop
            y: 8
            width: 50
            height: 50
            checkable: true
            anchors.left: btnForward.right
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            buttonImage: checked ? "loop.png" : "noloop.png"
            onClicked: {
                if(btnLoop.checked) {
                    mediaPlayList.playbackMode = Playlist.Loop
                } else {
                    mediaPlayList.playbackMode = Playlist.CurrentItemOnce
                }
            }
        }

        ImageButton {
            id: btnShuffle
            y: 8
            width: 50
            height: 50
            checkable: true
            anchors.left: btnLoop.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            buttonImage: checked ? "shuffle.png" : "noshuffle.png"
            onClicked: {
                if( btnShuffle.checked ) {
//                    mediaPlayList.playbackMode = Playlist.Random
                    mediaPlayList.shuffle()
                    console.log("Selected Shuffle.  Playback state is:", mediaPlayList.playbackMode, Playlist.Random)
                } else {
                    mediaPlayList.playbackMode = Playlist.Sequential
                }

            }
        }


    }

}

/*##^##
Designer {
    D{i:3;anchors_height:14;anchors_y:294}D{i:4;anchors_width:200;anchors_x:31}D{i:6;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}
D{i:5;anchors_height:200;anchors_width:200;anchors_x:43;anchors_y:48}D{i:8;anchors_x:50}
D{i:9;anchors_x:0}D{i:10;anchors_x:110}D{i:11;anchors_x:205}D{i:12;anchors_x:262}
D{i:7;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}
}
##^##*/

