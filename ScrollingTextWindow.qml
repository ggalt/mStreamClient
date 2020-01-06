import QtQuick 2.12

Rectangle {
    id: scrollingTextWindow
    clip: true

    property int scrollSpeed: 4000  // 4 seconds of scrolling
    property int scrollInterval: 3000   // 3 seconds of static text
    property real scrollStep: 0

    property alias scrollText: scrollingText.text
    property alias scrollFont: scrollingText.font
    property alias scrollTextColor: scrollingText.color
    property alias scrollTextOpacity: scrollingText.opacity

    state: "Static"

    function animateText() {
        scrollingText.left -= scrollStep
        if(scrollingText.left + textMetrics.width <= scrollingTextWindow.right) {
            scrollingTextWindow.state = "FadeOut"
        }
    }

    function setupScrolling() {
        if (textMetrics.width > scrollingTextWindow.width) {
            scrollStep = (((textMetrics.width - scrollingTextWindow.width) + scrollingTextWindow.width/3) * scrollTimer.interval) / scrollSpeed
            scrollTimer.start()
        }
    }

    Component.onCompleted: {
        staticDisplayTimer.start()
    }


    Timer {
        id: scrollTimer
        interval: 33    // ~30 fps
        onTriggered: {
            animateText()
        }
    }

    Timer {
        id: staticDisplayTimer
        interval: scrollInterval
        onTriggered: {
            staticDisplayTimer.stop()
            scrollingTextWindow.state = "Scrolling"
            scrollTimer.start()
        }
    }

    Text {
        id: scrollingText
        anchors.fill: parent

        text: qsTr("Text")
        font.pixelSize: 12
        onTextChanged: setupScrolling()
    }

    TextMetrics {
        id: textMetrics
        text: scrollingText.text
    }

    states: [
        State {
            name: "Static"
        },

        State {
            name: "Scrolling"
        },
        State {
            name: "FadeOut"
            PropertyChanges {
                target: scrollingText
                opacity: 0
            }
        },
        State {
            name: "FadeIn"
            PropertyChanges {
                target: scrollingText
                opacity: 100
            }
        }

    ]

    transitions: [
        Transition {
            from: "*"
            to: "FadeOut"

            NumberAnimation {
                target: scrollingText
                property: "opacity"
                duration: 500
                easing.type: Easing.InOutQuad
            }
            onRunningChanged: {
                if(!running && scrollingTextWindow.state==="FadeOut"){
                    scrollTimer.stop()
                    scrollingTextWindow.state="FadeIn"
                    scrollingText.left = 0
                }
            }
        },
        Transition {
            from: "*"
            to: "FadeIn"

            NumberAnimation {
                target: scrollingText
                property: "opacity"
                duration: 100
                easing.type: Easing.InOutQuad
            }
            onRunningChanged: {
                if(!running && scrollingTextWindow.state==="FadeIn"){
                    staticDisplayTimer.start()
                    scrollingTextWindow.state="Static"
                }
            }
        }
    ]

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
