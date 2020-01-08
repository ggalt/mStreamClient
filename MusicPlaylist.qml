import QtQuick 2.13
import SortFilterProxyModel 0.2

SortFilterProxyModel {
    id: sortedModel

    property int currentIndex: 0
    property alias titleCount: origPlayList.count
    property var shuffleArray: []
    property bool looping: false
    property bool shuffle: false

    sourceModel: origPlayList.model

    JSONListModel {
        id: origPlayList
    }

    RoleSorter {
        id: shuffleSort
        roleName: "playListPosition"
        sortOrder: Qt.AscendingOrder
    }

    function loop(status) {
        looping = status
    }

    function knuthShuffle() {
        shuffleArray=[]
        for( var t = currentIndex; t < titleCount; t++) {  // create an array of ascending numbers to match what is left of the playlist
            shuffleArray.push(t)
        }

        var rand, temp, i;

        for (i = shuffleArray.length - 1; i > 0; i -= 1) {
            rand = Math.floor((i + 1) * Math.random());//get random between zero and i (inclusive)
            temp = shuffleArray[rand];//swap i and the zero-indexed number
            shuffleArray[rand] = shuffleArray[i];
            shuffleArray[i] = temp;
        }

        for( var c = currentIndex; c < titleCount; c++ ) {
            origPlayList.setProperty(c, "playListPosition", shuffleArray[c])
        }
    }

    function ShuffleOn() {
        knuthShuffle()
        shuffle = true
        sorters=shuffleSort
    }

    function ShuffleOff() {
        shuffle = false
        sorters=null
    }

    function next() {
        currentIndex++;
        if(currentIndex >= titleCount && looping) {
            currentIndex = 0
        } else {
            return sortedModel.get(currentIndex)["filepath"]
        }

        return
    }

    function previous() {
    }

}
