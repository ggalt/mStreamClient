import QtQuick 2.0
import QtQuick.Controls 2.13

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
    }

    Button {
        id: btnCancel
        x: 185
        y: 365
        text: qsTr("Cancel")
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
