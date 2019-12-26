import QtQuick 2.0
import QtQuick.Controls 2.13

Item {
    anchors.fill: parent
    property alias setServerURL: txtServerURL.text
    property alias setUserName: txtUserName.text
    property alias setPassword: txtPassword.text

    Label {
        id: label
        x: 48
        y: 37
        text: qsTr("ServerURL:")
    }

    TextField {
        id: txtServerURL
        x: 123
        y: 25
        width: 392
        height: 40
        text: qsTr("Text Field")
    }



    Switch {
        id: checkLogin
        x: 48
        y: 71
        text: qsTr("Use login credentials")
    }

    GroupBox {
        id: defaultBehaviorGroupBox
        x: 48
        y: 308
        width: 467
        height: 75
        title: qsTr("Default Behavior")

        Button {
            id: btnAdd2PlayList
            x: 0
            y: -6
            width: 111
            height: 40
            text: checked ? qsTr("Add To Playlist") : qsTr("Replace Playlist")
            checkable: true
        }

        Button {
            id: btnShuffle
            x: 117
            y: -6
            text: checked ? qsTr("Shuffle Tracks") : qsTr("Track Order")
            checkable: true
        }

        Button {
            id: btnRepeat
            x: 230
            y: -6
            width: 87
            height: 40
            text: checked ? qsTr("Repeat") : qsTr("No Repeat")
            checkable: true
        }

        Button {
            id: btnAutoplay
            x: 337
            y: -6
            text: checked ? qsTr("Autoplay") : qsTr("No Autoplay")
            checkable: true
        }


    }

    GroupBox {
        id: groupBox
        x: 48
        y: 109
        width: 467
        height: 183
        title: qsTr("Credentials")
        enabled: checkLogin.checked


        Label {
            id: label1
            x: 5
            y: 33
            text: qsTr("Username:")
        }


        TextField {
            id: txtUserName
            x: 93
            y: 21
            width: 346
            height: 40
            text: qsTr("")
        }



        Label {
            id: label2
            x: 5
            y: 80
            text: qsTr("Password:")
        }

        TextField {
            id: txtPassword
            x: 93
            y: 68
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
    }



    Button {
        id: btnOK
        x: 48
        y: 420
        text: qsTr("OK")
        onClicked:  {
            mainWindow.setSettings()
            drawer.close()
        }
    }



    Button {
        id: btnCancel
        x: 185
        y: 420
        text: qsTr("Cancel")
        onClicked: drawer.close()
    }


}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
