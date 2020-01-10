import QtQuick 2.13
import SortFilterProxyModel 0.2

JSONListModel {
    id: sorterModel

    property int currentIndex: 0
    property alias titleCount: sorterModel.count
    property var shuffleArray: []
    property bool looping: false
    property bool shuffle: false

    signal endOfList

    SortFilterProxyModel {
        id: sortedModel

        sourceModel: sorterModel.model

        sorters: RoleSorter {
            id: shuffleSort
            roleName: "playListPosition"
            sortOrder: Qt.AscendingOrder
        }
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
            console.log(shuffleArray[c])
            setProperty(c, "playListPosition", shuffleArray[c])
        }
    }

    function shuffleOn() {
        knuthShuffle()
        shuffle = true
    }

    function shuffleOff() {
        shuffle = false
    }

    function current() {
        if( shuffle ) {
            return sortedModel.get(currentIndex)["filepath"]
        } else {
            return sorterModel.get(currentIndex)["filepath"]
        }
    }

    function next() {
        currentIndex++;
        if( currentIndex > titleCount ) {
            if(looping) {
                currentIndex = 0
                return current()
            } else {
                endOfList()
                return ""
            }
        } else {
            return current()
        }
    }

    function previous() {
        currentIndex--;
        if( currentIndex < 0 ) {    // always loop around, even if we are not "looping"
            currentIndex = titleCount-1
        }
        return current()
    }

}
