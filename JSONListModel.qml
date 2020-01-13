/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.13
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string objNm: "name"   // object name to substitute if the set of data is a JSON array of strings

    property ListModel model: ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);

        for ( var key in objectArray ) {
            var jo = objectArray[key];
            if( typeof jo === 'string' ) {
                var jojo = '{ "' + objNm + '" : "'+ jo + '" }'
                var newJo = JSON.parse(jojo);
                jsonModel.append(newJo);
            } else {
                jsonModel.append( jo );
            }
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function clear() {
        jsonModel.clear()
    }

    function add(jObj) {
        if(typeof jObj === 'object') {
            jsonModel.append(jObj)
        }
    }

    function move(from, to) {
        jsonModel.move(from, to, 1)
    }

    function get(index) {
        return jsonModel.get(index)
    }

    function setProperty(index, prop, val) {
        jsonModel.setProperty(index, prop, val)
    }

    function set(index, jObj) {
        if( typeof jObj === 'object' ) {
            jsonModel.set(index, jObj)
        }
    }
}
