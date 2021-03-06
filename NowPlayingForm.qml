import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import QtMultimedia 5.12

Item {
    id: element
    width: 400
    height: 400

    signal shuffleOn
    signal shuffleOff
    signal settingGlobalVolume(real vol)

    signal currentSong(int pos)

    property bool isPlaying: false

    property int _NEXT: 1
    property int _PREVIOUS: -1
    property int _CURRENT: 0

    property alias mediaVolume: mediaPlayer.volume

    Logger {
        id:myLogger
        debugLevel: mainWindow.globalDebugLevel
    }

    function startPlay() {
        isPlaying = true;
        mediaPlayer.startPlaying()
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
            id: logoImage
            anchors.fill: parent
            source: "ms-icon-310x310.png"
            fillMode: Image.PreserveAspectFit
            visible: true
        }

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
            onValueChanged: {
                myLogger.log("volume:", value)
                mediaPlayer.volume = value
            }
        }


    }


    MediaPlayer {
        id: mediaPlayer
        audioRole: MediaPlayer.MusicRole

        autoPlay: true

        function endOfPlaylist() {
            myLogger.log("Playlist ended and received by player");
            isPlaying=false;
        }

        Component.onCompleted: {
            curPlayLst.endOfList.connect(endOfPlaylist);
            displaySongInfo()
        }

        function displaySongInfo() {
            if(isPlaying) {
                toolBarLabel.scrollText = "Artist:"+curPlayLst.currentSongObject().metadata["artist"] + " / "+
                        "Album:"+curPlayLst.currentSongObject().metadata["album"] + " / "+
                        "Title:"+curPlayLst.currentSongObject().metadata["title"];
                coverImage.source = serverURL+"/album-art/"+curPlayLst.currentSongObject().metadata["album-art"]+"?token="+myToken
                currentSong(curPlayLst.currentIndex)
            }
        }

        function playTrack(which) {
            myLogger.log("playing track, playlist lenght:", curPlayLst.count)
            if(which===_NEXT) {
                mediaPlayer.source = serverURL+"/media/"+encodeURIComponent(curPlayLst.next())+"?token="+myToken
            } else if( which===_PREVIOUS) {
                mediaPlayer.source = serverURL+"/media/"+encodeURIComponent(curPlayLst.previous())+"?token="+myToken
            } else {
                mediaPlayer.source = serverURL+"/media/"+encodeURIComponent(curPlayLst.current())+"?token="+myToken
            }
            //            mediaPlayer.play()
            displaySongInfo()
        }

        onPlaybackStateChanged: {
            myLogger.log("onPlaybackStateChanged", playbackState)
            if( playbackState === MediaPlayer.PlayingState ) {
                displaySongInfo()
            } else if( playbackState === MediaPlayer.PausedState ) {
                myLogger.log("Paused State")
            } else if( playbackState === MediaPlayer.StoppedState ) {
                myLogger.log("Stopped State")
            }
        }

        onPlaylistChanged: {
            myLogger.log("onPlaylistChanged")
        }

        onSourceChanged: {
            myLogger.log("onSourceChanged")
        }

        onStatusChanged: {
            if( status === MediaPlayer.EndOfMedia ) {
                playTrack(_NEXT)
            } else if( status === MediaPlayer.NoMedia) {
                playTrack(_CURRENT)
            }

            myLogger.log("onStatusChanged", getStatus(), "error state:", errorString)

        }

        function startPlaying() {
            playTrack(_CURRENT)
            //            if( status === MediaPlayer.NoMedia ) {
            //            mediaPlayer.source = serverURL+"/media/"+curPlayLst.current()+"?token="+myToken
            //            }
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

        function pauseOrPlay() {
            if(mediaPlayer.playbackState === MediaPlayer.PlayingState )
                mediaPlayer.pause()
            else
                mediaPlayer.play()
            myLogger.log("Song duration:", mediaPlayer.duration)
            myLogger.log("song position:", mediaPlayer.position)
            myLogger.log("volume set:", mediaPlayer.volume)
        }


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
                controlFrame.pauseOrPlay()
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
            onClicked: {
                myLogger.log("previous pressed")
                mediaPlayer.playTrack(_PREVIOUS)
                //                mediaPlayer.source = serverURL+"/media/"+curPlayLst.previous()+"?token="+myToken
            }
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
            onClicked: {
                myLogger.log("next pressed")
                mediaPlayer.playTrack(_NEXT)
                //                mediaPlayer.source = serverURL+"/media/"+curPlayLst.next()+"?token="+myToken
            }
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
                curPlayLst.loop(checked)
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
                myLogger.log("form name is:", stackView.currentItem.objectName)
                if( btnShuffle.checked ) {
                    curPlayLst.shuffleOn()
                    shuffleOn()
                    startPlay()
                    //                    if(stackView.currentItem.objectName==="playlistForm") {
                    //                        stackView.pop()
                    //                        stackView.push("qrc:/ShuffledPlayingListForm.qml")
                    //                        myLogger.log("pushed shuffle view")
                    //                    }
                } else {
                    curPlayLst.shuffleOff()
                    shuffleOff()
                    startPlay()
                    //                    if(stackView.currentItem.objectName==="shuffledPlaylistForm") {
                    //                        stackView.pop()
                    //                        stackView.push("qrc:/PlayingListForm.qml")
                    //                        myLogger.log("pushed standard view")
                    //                    }
                }

            }
        }


    }

    Keys.onPressed: {
//                if( event.key === Qt.Key_MediaPlay )
//                    if( nowPlaying.visible ) {
//                        mediaPlayer.play()
//                    } else
//                if( event.key === Qt.Key_MediaPause )
//                    if( nowPlaying.visible ) {
//                        mediaPlayer.pause()
//                    }
        myLogger.log("KEY PRESSED:", event.key)
        if( event.key === Qt.Key_MediaPlay || event.key === Qt.Key_MediaPause )
            controlFrame.pauseOrPlay()
        else if( event.key === Qt.Key_VolumeDown )
            volSlider.value -= 0.05
        else if( event.key === Qt.Key_VolumeUp )
            volSlider.value += 0.05
    }

    Component.onDestruction: mainWindow.setGlobalVolume(mediaPlayer.volume)
}

/*##^##
Designer {
    D{i:4;anchors_width:200;anchors_x:31}D{i:5;anchors_height:200;anchors_width:200;anchors_x:43;anchors_y:48}
D{i:6;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}D{i:3;anchors_height:14;anchors_y:294}
D{i:7;anchors_height:100;anchors_width:100;anchors_x:46;anchors_y:12}D{i:8;anchors_x:50}
D{i:10;anchors_x:110}D{i:11;anchors_x:205}D{i:12;anchors_x:262}D{i:9;anchors_x:0}
}
##^##*/

