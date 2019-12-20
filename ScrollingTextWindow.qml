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

    function animateText() {

    }

    function setupScrolling() {
        if (textMetrics.width > scrollingTextWindow.width) {
            scrollStep = (((textMetrics.width - scrollingTextWindow.width) + scrollingTextWindow.width/3) * scrollTimer.interval) / scrollSpeed
            scrollTimer.start()
        }
    }


    Timer {
        id: scrollTimer
        interval: 33    // ~30 fps
        onTriggered: {
            animateText()
        }
    }

    Text {
        id: scrollingText
        x:0
        text: qsTr("Text")
        anchors.fill: parent
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
            name: "Fading"
        }
    ]

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
