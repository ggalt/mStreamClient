import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.12
import Qt.labs.settings 1.1



ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 480
    color: "#7a7878"
    title: qsTr("mStreamClient")

    Settings {
        id: appSettings
        property string usrName: ""
        property string passWrd: ""
        property string storeToken: ""
        property string serverURL: "http://192.168.1.50:3000"
        property bool restoreSession: false
    }

    JSONListModel {
        id: artistJSONModel
        objNm: "name"
    }

    JSONListModel {
        id: albumJSONModel
    }

    property string myToken: ''
    property string serverURL: "http://192.168.1.50:3000"
    property string usrnm: "dummy"
    property string passwrd: "dumbo"

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

//        xmlhttp.send(JSON.stringify({ "username": "dummy", "password": "dumbo" }));
        xmlhttp.send(JSON.stringify({ "username": usrnm, "password": passwrd }));
    }

    /// serverCall: Generic function to call the mStream server
    function serverCall(reqPath, JSONval, callType, callback) {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+reqPath;
        console.log("Request info:", callType, url);
        xmlhttp.open(callType, url, true);
        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");

        if( myToken !== '' ) {
            console.log("sending token")
            xmlhttp.setRequestHeader("x-access-token", myToken)
        }

        if(callback !== '') {
            xmlhttp.onreadystatechange = function(){
                if(xmlhttp.readyState === 4) {
                    if(xmlhttp.status === 200) {
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

    function artistsRequestResp(xmlhttp) {
        console.log(xmlhttp.responseText)
        artistJSONModel.json = xmlhttp.responseText
        artistJSONModel.query = "$.artists[*]"
        stackView.push( "qrc:/ArtistForm.qml" )
    }

    function requestAlbums() {
        serverCall("/db/albums", '', "GET", albumRequestResp)
    }

    function albumRequestResp(xmlhttp) {
        console.log(xmlhttp.responseText.substring(1,5000))
        albumJSONModel.json = xmlhttp.responseText
        albumJSONModel.query = "$.albums[*]"
        stackView.push("qrc:/AlbumForm.qml")
    }

    function requestArtistAlbums(artistName) {
        console.log("Requesting albums for:", artistName)
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : artistName }), "POST", albumRequestResp)
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
            text: stackView.currentItem.formName
            anchors.centerIn: parent
            font.pointSize: 20
        }
    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.66
        height: mainWindow.height
        SettingsForm {

        }

    }

    Frame {
        id: navFrame
        anchors.right: parent.right
        anchors.rightMargin: parent.width / 2
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

    }

    Component.onCompleted: sendLogin()
}

/*##^##
Designer {
    D{i:4;anchors_x:592;anchors_y:104}D{i:3;anchors_x:43}D{i:1;anchors_height:200;anchors_width:200;anchors_x:23;anchors_y:140}
D{i:2;anchors_height:200;anchors_width:200;anchors_x:70;anchors_y:17}D{i:10;anchors_height:433;anchors_y:47}
D{i:19;anchors_height:433;anchors_y:47}
}
##^##*/
