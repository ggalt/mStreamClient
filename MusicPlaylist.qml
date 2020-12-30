import QtQuick 2.13

JSONListModel {
    id: sorterModel

    property int currentIndex: 0
    property alias titleCount: sorterModel.count
    property var shuffleArray: []
    property var playListArray: []
    property bool looping: false
    property bool shuffle: false

    signal endOfList

    Logger {
        id:myLogger
        debugLevel: 1
    }

    function loop(status) {
        if( status === true )
            looping = true;
        else
            looping = false;
    }

    function setMusicPlaylistIndex(idx) {
        myLogger.log("set music play list to index number:", idx)
        currentIndex = idx
    }

    function knuthShuffle() {

        var rand, temp, i;

        for (i = shuffleArray.length - 1; i > 0; i -= 1) {
            rand = Math.floor((i + 1) * Math.random());//get random between zero and i (inclusive)
            temp = shuffleArray[rand];//swap i and the zero-indexed number
            shuffleArray[rand] = shuffleArray[i];
            shuffleArray[i] = temp;
        }

    }

    function shuffleAdd(jObj) {
        playListArray.push(jObj)
        shuffleArray.push(jObj)
    }

    function clearMe() {
        clear()
        playListArray.length = 0
        shuffleArray.length = 0
    }

    function updateList() {
        clear()
        myLogger.log("Playlist Array:", playListArray)
        if(shuffle) {
           for( var c=0; c < shuffleArray.length; c++) {
               add(shuffleArray[c]);
           }
        } else {
            for( var i=0; i < playListArray.length; i++) {
                add(playListArray[i]);
            }
        }
    }

    function shuffleOn() {
        knuthShuffle()
        shuffle = true
        currentIndex=0
        updateList()
    }

    function shuffleOff() {
        shuffle = false
        currentIndex=0
        updateList()
    }

    function currentSongObject() {
        if( shuffle ) {
            return get(currentIndex)
        } else {
            return get(currentIndex)
        }
    }

    function current() {
        return currentSongObject()["filepath"]
    }

    function next() {
        currentIndex++;
        if( currentIndex < titleCount ) {
            return current()
        } else {
            if(looping) {
                currentIndex = 0
                return current()
            } else {
                endOfList()
                return ""
            }
        }
    }

    function previous() {
        currentIndex--;
        if( currentIndex < 0 ) {    // always loop around, even if we are not "looping"
            currentIndex = titleCount-1
        }
        return current()
    }

    onCurrentIndexChanged: {
        myLogger.log("current index of playlist is:", currentIndex)
    }
}
