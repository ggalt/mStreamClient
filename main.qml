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
        navView.setCurrentIndex(0)
    }

    function requestAlbums() {
        serverCall("/db/albums", '', "GET", albumRequestResp)
    }

    function albumRequestResp(xmlhttp) {
        console.log(xmlhttp.responseText.substring(1,5000))
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
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: "stackView.currentItem.title"
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.66
        height: mainWindow.height
        Item {
            anchors.fill: parent
            Label {
                id: label
                x: 48
                y: 48
                text: qsTr("ServerURL:")
            }

            TextField {
                id: txtServerURL
                x: 123
                y: 36
                width: 392
                height: 40
                text: qsTr("Text Field")
            }

            GroupBox {
                id: groupBox
                x: 48
                y: 165
                width: 467
                height: 183
                title: qsTr("Credentials")
                enabled: checkLogin.checked

                TextField {
                    id: txtPassword
                    x: 93
                    y: 68
                    width: 346
                    height: 40
                    text: qsTr("")
                }

                TextField {
                    id: txtUserName
                    x: 93
                    y: 21
                    width: 346
                    height: 40
                    text: qsTr("")
                }

                Switch {
                    id: checkSession
                    x: 5
                    y: 114
                    width: 189
                    height: 31
                    text: qsTr("Preserve Session")
                }

                Label {
                    id: label2
                    x: 5
                    y: 80
                    text: qsTr("Password:")
                }

                Label {
                    id: label1
                    x: 5
                    y: 33
                    text: qsTr("Username:")
                }
            }

            Switch {
                id: checkLogin
                x: 48
                y: 93
                text: qsTr("Use login credentials")
            }

            Button {
                id: btnOK
                x: 48
                y: 365
                text: qsTr("OK")
                onClicked: drawer.close()
            }

            Button {
                id: btnCancel
                x: 185
                y: 365
                text: qsTr("Cancel")
                onClicked: drawer.close()
            }
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
            initialItem: "HomeForm.qml"
        }

    }

//    ScrollView {
//        id: scrollView
//        anchors.fill: parent
//        clip: true

//        ListView {
//            id: listView
//            anchors.fill: parent
//            delegate: Item {
//                x: 5
//                width: 80
//                height: 40
//                Row {
//                    id: row1
//                    Button {
//                        width: 40
//                        height: 40
//                        onClicked: actionClick(name)
//                    }

//                    Text {
//                        text: name
//                        anchors.verticalCenter: parent.verticalCenter
//                        font.bold: true
//                    }
//                    spacing: 10
//                }
//            }
//            model: ListModel {
//                ListElement {
//                    name: "Login"
//                }

//                ListElement {
//                    name: "Artists"
//                }

//                ListElement {
//                    name: "Albums"
//                }

//                ListElement {
//                    name: "Playlists"
//                }
//            }
//        }
//    }


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

        SwipeView {
            id: navView
            anchors.fill: parent
            clip: true
            Item {
                id: artistPage
                ListView {
                    anchors.fill: parent
                    model: artistJSONModel.model
                    delegate: ArtistDelegate {
                        artistName: model.name
                    }

//                    delegate: Rectangle {
//                        height: 40
//                        border.width: 0

//                        Label {
//                            id: artistLabel
//                            text: model.name
//                            font.pointSize: 12
//                            font.family: "Arial"
//                            verticalAlignment: Text.AlignVCenter
//                            anchors.leftMargin: 10
//                            anchors.fill: parent
//                        }

//                        MouseArea {
//                            id: mouseArea
//                            anchors.fill: parent
//                            onPressAndHold: console.log("Press and Hold for:", artistName.text)
//                            onClicked: console.log("click for:", artistName.text)
//                        }
//                    }


//                    delegate: Component {
//                        Text {
//                            text: model.name
//                        }
//                    }
                }
            }
            Item {
                id: secondPage
            }
            Item {
                id: thirdPage
            }
        }
        PageIndicator {
            id: indicator

            count: navView.count
            currentIndex: navView.currentIndex

            anchors.bottom: navView.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
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
