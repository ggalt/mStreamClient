import QtQuick 2.13
import QtQuick.Controls 2.13


Item {
    id: scrollingListView

    property string formName: ""

    property alias myModel: listView.model
    property alias myDelegate: listView.delegate
    property alias highlightLetter: lblLetter.text
    property alias myCurrentItem: listView.currentItem
    property alias myCurrentIndex: listView.currentIndex
    property alias myHighLight: listView.highlight
    property alias highlightFollowsCurrentItem: listView.highlightFollowsCurrentItem
    property alias myhighlightRangeMode: listView.highlightRangeMode


    function setListViewIndex(idx) {
        console.assert(idx < listView.count || idx === null, "invalid index")

        listView.currentIndex = idx
    }

    function setLetterDisplayVisible(val) {
        if( val === true || val === false ) {
            lblLetter.visible = val
        }
    }

    Component.onCompleted: {
        if (listView.count > 10)
            setLetterDisplayVisible(true)
        else
            setLetterDisplayVisible(false)
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            id: listView
            highlightRangeMode: ListView.StrictlyEnforceRange
            anchors.fill: parent

            Timer {
                id: scrollTimer
                interval: 500
                onTriggered: {
                    stop()
                    lblLetter.state = "inactive"
                }
            }

            onContentYChanged: {
                lblLetter.state = "active"
                scrollTimer.start()
            }

            Label {
                id: lblLetter
                width: 2*scrollingListView.width/3
                height: 2*scrollingListView.height/3
                opacity: 0.5
                font.pointSize: 200
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: true

                state: "inactive"

                states: [
                    State {
                        name: "inactive"
                        PropertyChanges {
                            target: lblLetter
                            opacity: 0.0
                        }
                    },
                    State {
                        name: "active"
                        PropertyChanges {
                            target: lblLetter
                            opacity: 0.5
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "active"

                        NumberAnimation {
                            target: lblLetter
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    },
                    Transition {
                        from: "*"
                        to: "inactive"

                        NumberAnimation {
                            target: lblLetter
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]
            }

        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
