import QtQuick 2.0

Item {
    id: qmlLogger
    property int debugLevel: 0
    property var output
    property int i: 0

    function log(...args){
        if(debugLevel >= 2) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(parent.objectName, output)
        }
    }

    function warn(...args){
        if(debugLevel >= 1) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(parent.objectName, output)
        }
    }

    function critical(...args){
        if(debugLevel >= 0) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(parent.objectName, output)
        }
    }

}
