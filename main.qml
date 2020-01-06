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
//        property alias settingToken: mainWindow.myToken
        property alias settingServerURL: mainWindow.serverURL
        property alias settingSetup: mainWindow.isSetup
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

    property var playList: []
    property var nowPlaying: []
    property int currentTrack: 0
    property bool isPlaying: false
    property int playlistAddAt: 0
    property alias toolBarText: toolBarLabel.text

    property string usrName: appSettings.settingUserName
    property string passWord: appSettings.settingPassWord
    property string myToken: ""
    property string serverURL: appSettings.settingServerURL
//    property string serverURL: appSettings.settingServerURL
    property bool isSetup: appSettings.settingSetup

    property int gettingArtists: 0
    property int gettingAlbums: 0
    property int gettingTitles: 0

    function fullyEncodeURI(uri) {
        var retURI = encodeURIComponent(uri)
        console.log("encoded URI:", retURI)
        retURI = retURI.replace("@", "%40")
        retURI = retURI.replace("!", "%21")
        retURI = retURI.replace("*", "%2A")
        retURI = retURI.replace("_", "%5F")
        console.log("Fixed URI:", retURI)
        return retURI
    }

    function setSettings() {
        if(settingForm.setServerURL.substring(0,7) !== "http://") {
            if(settingForm.setServerURL.substring(0,8) !== "https://") {
                serverURL = "http://"+settingForm.setServerURL.substring(8, settingForm.setServerURL.length-8)+":"+setingForm.setPortNumber
            } else {
                serverURL = "http://"+settingForm.setServerURL+":"+settingForm.setPortNumber
            }
        } else {
            serverURL = settingForm.setServerURL+":"+settingForm.setPortNumber
        }

        usrName = settingForm.setUserName
        passWord = settingForm.setPassword
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
                    console.log("ok")
                    console.log(xmlhttp.responseText)
                    var resp = JSON.parse(xmlhttp.responseText)
                    myToken = resp.token
                    console.log(resp.token)
                    console.log("end")
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
            console.log("setting token")
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
        console.log(xmlhttp.responseText)
        artistListJSONModel.json = xmlhttp.responseText
        artistListJSONModel.query = "$.artists[*]"
        stackView.push( "qrc:/ArtistForm.qml" )
    }

    function albumRequestResp(xmlhttp) {
        console.log(xmlhttp.responseText.substring(1,5000))
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
            console.log("Artist Click")
            requestArtists();
        } else if (action === "Albums") {
            console.log("Album Click")
            requestAlbums();
        } else if (action === "Playlists") {
            console.log("Playlist Click")
        }
    }

    function updatePlaylist(m_item, typeOfItem, action) { // m_item needs to be the name of an artist, album, playlist or song
        console.log("Update Playlist", m_item, typeOfItem, action)
        if(action === "replace") {
            playList = []
            currentPlayListJSONModel.clear()
            nowPlaying.clearPlaylist()
            playlistAddAt = 0
        } else {
            playlistAddAt = playList.length
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
        console.log("gettingArtists is:", gettingArtists, "gettingAlbums is:", gettingAlbums, "gettingTitles is:", gettingTitles)
        if( gettingArtists <= 0 && gettingAlbums <= 0 && gettingTitles <= 0) {
            console.log("loading playlist whch has length of:", playList.length)
            isPlaying = true
            nowPlaying.visible = true
            nowPlaying.loadPlaylist(playList, playlistAddAt)
//        } else {
//            console.log("gettingArtists is:", gettingArtists, "gettingAlbums is:", gettingAlbums, "gettingTitles is:", gettingTitles)
        }
    }

    function playlistAddSong(songObj) {   // this actually adds the songs to our playlist
        currentPlayListJSONModel.add(songObj)
        playList.push(songObj)
        gettingTitles--;
        loadToPlaylist();
    }

    function playlistAddAlbum(title) {  // add songs from album
        console.log("alubm get count:", gettingAlbums)
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
        var albumResp = JSON.parse(resp.responseText)
        for( var i = 0; i < albumResp.length; i++ ) {
            gettingTitles++;
            playlistAddSong(albumResp[i])
        }
        gettingAlbums--;
        console.log("exit getting albums with count:", gettingAlbums)
        loadToPlaylist()
    }

    function playlistAddArtistResp(resp) {
        var artistResp = JSON.parse(resp.responseText)

        for( var i = 0; i < artistResp.albums.length; i++) {
            playlistAddAlbum(artistResp.albums[i].name)
        }
        gettingArtists--;
        console.log("exit getting artists")
        loadToPlaylist()
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

        Label {
            id: toolBarLabel
            text: isPlaying ? "Artist:"+playList[currentTrack].metadata["artist"]+" - Title:"+ playList[currentTrack].metadata["title"] : "mStream Client"
            anchors.centerIn: parent
            font.pointSize: 20
        }
    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.66
        height: mainWindow.height
        SettingsForm {
            id: settingForm
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
        }
    }

//    property string settingUserName: ""
//    property string settingPassWord: ""
//    property string settingToken: ""
////        property string serverURL: "http://192.168.1.50:3000"
//    property string serverURL: "http://localhost:3000"
//    property bool restoreSession: false
//    property bool settingsComplete: false



    Component.onCompleted: {

        if( serverURL.length === 0 ) {
            // we assume that we aren't set up
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
