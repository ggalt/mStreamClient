import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import Qt.labs.settings 1.1
import QtMultimedia 5.12


ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 480
    color: "#7a7878"
    title: qsTr("mStreamClient")

    Settings {
        id: appSettings
        property alias settingUserName: mainWindow.usrName
        property alias settingPassWord: mainWindow.passWord
        property alias settingServerURL: mainWindow.serverURL
        property alias settingSetup: mainWindow.isSetup
        property alias settingVolume: mainWindow.mediaVolume
    }

    JSONListModel {
        id: artistListJSONModel
        objNm: "name"
    }

    JSONListModel {
        id: albumListJSONModel
    }

    JSONListModel {
        id: songListJSONModel
    }

    JSONListModel {
        id: currentPlayListJSONModel
    }

    MusicPlaylist {
        id: currentPlayList
    }

    property alias currentTrack: currentPlayList.currentIndex
    property bool isPlaying: false
    property int playlistAddAt: 0
    property alias toolBarText: toolBarLabel.scrollText
    property alias curPlayLst: currentPlayList

    property string usrName: appSettings.settingUserName
    property string passWord: appSettings.settingPassWord
    property string myToken: ""
    property string serverURL: appSettings.settingServerURL
    property real mediaVolume: appSettings.settingVolume
    property bool isSetup: appSettings.settingSetup

    property int gettingArtists: 0
    property int gettingAlbums: 0
    property int gettingTitles: 0

    property string currentAlbumArt: ""

    function fullyEncodeURI(uri) {
        var retURI = encodeURIComponent(uri)
        retURI = retURI.replace("@", "%40")
        retURI = retURI.replace("!", "%21")
        retURI = retURI.replace("*", "%2A")
        retURI = retURI.replace("_", "%5F")
        return retURI
    }

    function setSettings() {
        console.log(settingsForm.setServerURL, settingsForm.setPortNumber, settingsForm.setUserName, settingsForm.setPassword )
        if(settingsForm.setServerURL.substring(0,7) !== "http://") {
            if(settingsForm.setServerURL.substring(0,8) !== "https://") {
                serverURL = "http://"+settingsForm.setServerURL.substring(8, settingsForm.setServerURL.length-8)+":"+settingsForm.setPortNumber
            } else {
                serverURL = "http://"+settingsForm.setServerURL+":"+settingsForm.setPortNumber
            }
        } else {
            serverURL = settingsForm.setServerURL+":"+settingsForm.setPortNumber
        }

        usrName = settingsForm.setUserName
        passWord = settingsForm.setPassword
        sendLogin()
    }

    function sendLogin() {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+"/login";
        console.log("URL:", url)
        xmlhttp.open("POST", url, true);

        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");
        xmlhttp.onreadystatechange = function() { // Call a function when the state changes.
            if (xmlhttp.readyState === 4) {
                if (xmlhttp.status === 200) {
                    console.log("ResponseText:", xmlhttp.responseText)
                    var resp = JSON.parse(xmlhttp.responseText)
                    myToken = resp.token
                } else {
                    console.log("error: " + xmlhttp.status)
                }
            }
        }

        xmlhttp.send(JSON.stringify({ "username": usrName, "password": passWord }));
    }

    /// serverCall: Generic function to call the mStream server
    function serverCall(reqPath, JSONval, callType, callback) {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+reqPath;
        console.log("Request info:", callType, url, JSONval);
        xmlhttp.open(callType, url, true);
        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");

        if( myToken !== '' ) {
            xmlhttp.setRequestHeader("x-access-token", myToken)
        }

        if(callback !== '') {
            xmlhttp.onreadystatechange = function(){
                if(xmlhttp.readyState === 4) {
                    if(xmlhttp.status === 200) {
                        console.log("callback called")
                        callback(xmlhttp);
                    } else {
                        console.log("error: " + xmlhttp.status)
                    }
                }
            };
        }

        if(JSONval !== '') {
            xmlhttp.send(JSONval);
        } else {
            xmlhttp.send()
        }
    }

    function requestArtists() {
        serverCall("/db/artists", '', "GET", artistsRequestResp)
    }

    function requestAlbums() {
        serverCall("/db/albums", '', "GET", albumRequestResp)
    }

    function requestArtistAlbums(artistName) {
        console.log("Requesting albums for:", artistName)
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : artistName }), "POST", albumRequestResp)
    }

    function requestAlbumSongs(albumName) {
        console.log("Requesting songs for album:", albumName)
        serverCall("/db/album-songs", JSON.stringify({ 'album' : albumName }), "POST", songRequestResp)
    }

    function artistsRequestResp(xmlhttp) {
        console.log("artistRequestResp:", xmlhttp.responseText)
        artistListJSONModel.json = xmlhttp.responseText
        artistListJSONModel.query = "$.artists[*]"
        stackView.push( "qrc:/ArtistForm.qml" )
    }

    function albumRequestResp(xmlhttp) {
        console.log("albumRequestResp:", xmlhttp.responseText.substring(1,5000))
        albumListJSONModel.json = xmlhttp.responseText
        albumListJSONModel.query = "$.albums[*]"
        stackView.push("qrc:/AlbumForm.qml")
    }

    function songRequestResp(xmlhttp) {
        songListJSONModel.json = xmlhttp.responseText
        stackView.push( "qrc:/SongForm.qml" )
    }

    function actionClick(action) {
        if(action === "Artists") {
//            console.log("Artist Click")
            requestArtists();
        } else if (action === "Albums") {
//            console.log("Album Click")
            requestAlbums();
        } else if (action === "Playlists") {
//            console.log("Playlist Click")
        }
    }

    function updatePlaylist(m_item, typeOfItem, action) { // m_item needs to be the name of an artist, album, playlist or song
        console.log("Update Playlist", m_item, typeOfItem, action)
        if(action === "replace") {
            currentPlayList.clear()
//            playlistAddAt = 0
        }

        if(typeOfItem === "artist") {
            playlistAddArtist(m_item)
        } else if( typeOfItem === "album") {
            playlistAddAlbum(m_item)
        } else if( typeOfItem === "playlist") {
            playlistAddPlaylist(m_item)
        } else {
            playlistAddSong(m_item)
        }
    }

    function loadToPlaylist() {
//        console.log("gettingArtists is:", gettingArtists, "gettingAlbums is:", gettingAlbums, "gettingTitles is:", gettingTitles)
        if( gettingArtists <= 0 && gettingAlbums <= 0 && gettingTitles <= 0) {
//            console.log("loading playlist whch has length of:", curPlayLst.titleCount)
            isPlaying = true
            curPlayLst.updateList()
            nowPlaying.visible = true
            stackView.push("qrc:/PlayingListForm.qml")
            nowPlaying.currentSong.connect(stackView.currentItem.setCurrentIndex)
            nowPlaying.startPlay()
        }
    }

    function playlistAddSong(songObj) {   // this actually adds the songs to our playlist
        songObj.playListPosition = playlistAddAt++      // add the playListPosition role
        if(songObj.metadata["album-art"] === null) {
            console.log("NULL IMAGE")
        }
        currentPlayList.shuffleAdd(songObj)
//        console.log("song object:", JSON.stringify(songObj))
//        currentPlayList.add(songObj)
        gettingTitles--;
        loadToPlaylist();
    }

    function playlistAddAlbum(title) {  // add songs from album
//        console.log("album get count:", gettingAlbums)
        gettingAlbums++;
        serverCall("/db/album-songs", JSON.stringify({ 'album' : title }), "POST", playlistAddAlbumResp)
    }

    function playlistAddArtist(title) { // add albums from artist
        gettingArtists++;
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : title }), "POST", playlistAddArtistResp)
    }

    function playlistAddPlaylist(title) {

    }

    function playlistAddAlbumResp(resp) {
        var albumResp = JSON.parse(resp.responseText) // for some reason, our delegate doesn't like 'album-art'
        console.log("playlistAddAlbumResp:", resp.responseText)
        for( var i = 0; i < albumResp.length; i++ ) {
            gettingTitles++;
            if( albumResp[i].metadata["album-art"] === null )
                albumResp[i].metadata["album-art"] = albumListJSONModel.returnObjectContaining("name",albumResp[i].metadata["album"])["album_art_file"]
            playlistAddSong(albumResp[i])
        }
        gettingAlbums--;
//        console.log("exit getting albums with count:", gettingAlbums)
        loadToPlaylist()
    }

    function playlistAddArtistResp(resp) {
        var artistResp = JSON.parse(resp.responseText)

        for( var i = 0; i < artistResp.albums.length; i++) {
            playlistAddAlbum(artistResp.albums[i].name)
        }
        gettingArtists--;
//        console.log("exit getting artists")
        loadToPlaylist()
    }

    function selectSongAtIndex(idx) {
//        console.log("selected song at index:", idx)
        curPlayLst.setMusicPlaylistIndex(idx)
        nowPlaying.startPlay()
    }

    function setGlobalVolume(vol) {
        mainWindow.mediaVolume = vol
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// Visible Item
    /////////////////////////////////////////////////////////////////////////////////

    Keys.onPressed: {
        if( event.key === Qt.Key_MediaPlay )
            if( nowPlaying.visible ) {
                mediaPlayer.play()
            } else
        if( event.key === Qt.Key_MediaPause )
            if( nowPlaying.visible ) {
                mediaPlayer.pause()
            }
    }

    header: ToolBar {
        id: toolBar
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font.pointSize: 18
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        ScrollingTextWindow {
            id: toolBarLabel
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            scrollFontPointSize: 20
            scrollText: "mStream Client"
        }


    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.66
        height: mainWindow.height
        SettingsForm {
            id: settingsForm
        }

    }

    Frame {
        id: navFrame
        anchors.rightMargin: 0
        anchors.right: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: toolBar.bottom
        anchors.topMargin: 0


        StackView {
            id: stackView
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.fill: parent

            clip: true

            initialItem: "HomeForm.qml"

            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 200
                }
            }
            pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 200
                }
            }
            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 200
                }
            }
            popExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 200
                }
            }

        }

    }


    Frame {
        id: nowPlayingFrame
        anchors.left: navFrame.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: toolBar.bottom
        anchors.topMargin: 0
        NowPlayingForm {
            id: nowPlaying
            visible: false
            anchors.fill: parent
            mediaVolume: mainWindow.mediaVolume
        }
    }

    Component.onCompleted: {
        if( serverURL.length === 0 ) {
            drawer.open()
        } else {
            sendLogin()
        }
    }
}

/*##^##
Designer {
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:23;anchors_y:140}D{i:2;anchors_height:200;anchors_width:200;anchors_x:70;anchors_y:17}
D{i:3;anchors_x:43}D{i:4;anchors_x:592;anchors_y:104}D{i:10;anchors_height:433;anchors_y:47}
D{i:19;anchors_height:433;anchors_y:47}D{i:21;anchors_height:200;anchors_width:200}
}
##^##*/
