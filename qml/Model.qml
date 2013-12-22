import QtQuick 2.1

import FileIO 1.0

QtObject {
    id: root
    property real time: 0
    property var layers: new Array()
    property var selectedLayers: new Array()
    property var focusLayerIndex: 0
    property var focusState: null
    property int msPerFrame: 500
    property bool recordMode: false

    signal layersUpdated(var removedLayer, var addedLayer)
    signal selectedLayersUpdated(var unselectedLayer, var selectedLayer)
    signal statesUpdated(var layer)

    function syncLayerPosition(layer)
    {
       if (!recordMode)
           return;

       var sprite = layer.sprite;
       var keyframe = sprite.getPositionKeyframe(time);
       if (!keyframe || keyframe.time !== time) {
           keyframe = sprite.createPositionKeyframe(time);
           sprite.addPositionKeyframe(keyframe);
       }
       keyframe.x = sprite.x;
       keyframe.y = sprite.y;
    }

//    function getState(layer, time)
//    {
//        // get state at time, or add a new
//        // one if non existing:
//        if (!layer)
//            return;
//        var state = layer.sprite.getState(time);
//        if (!state || state.time != time) {
//            // Add the new state at given time:
//            var state = layer.sprite.createKeyframe(time, true);
//            var index = layers.indexOf(layer);
//            setFocusLayer(index);
//            statesUpdated(index);
//        }
//        return state;
//    }

    function setTime(time)
    {
        root.time = time;
        for (var l in layers) {
            var layer = layers[l];
            layer.sprite.setTime(time);
        }
        layer = layers[focusLayerIndex];
        if (layer) {
            var keyframe = layer.sprite.getCurrentPositionKeyframe();
            root.focusState = (keyframe && keyframe.time === keyframe.sprite.spriteTime) ? keyframe : null;
        }
    }

    function setFocusLayer(layerIndex)
    {
        // Get the state that should be shown for the user to edit:
        focusLayerIndex = layerIndex;
        var foundState = null;
        var layer = layers[focusLayerIndex];
        if (layer) {
            var keyframe = layer.sprite.getCurrentPositionKeyframe();
            root.focusState = (keyframe && keyframe.time === keyframe.sprite.spriteTime) ? keyframe : null;
        } else {
            root.focusState = null;
        }
    }

    function addLayer(layer)
    {
        unselectAllLayers();
        layers.push(layer);
        layer.selected = false;
        layer.parentLayer = null;
        layer.hierarchyLevel = 0;
        layer.sprite.addPositionKeyframe(layer.sprite.createPositionKeyframe(0));
        layer.sprite.setTime(0);
        selectLayer(layer, true);
        layersUpdated(-1, layers.length);
        setFocusLayer(focusLayerIndex);
    }

    function unselectAllLayers()
    {
        for (var i in selectedLayers) {
            var layer = selectedLayers[i];
            layer.selected = false;
        }
        var unselectedLayers = selectedLayers;
        selectedLayers = new Array();
        for (var i = 0; i < unselectedLayers.length; ++i)
            selectedLayersUpdated(layers.indexOf(unselectedLayers[i]), -1);
    }

    function selectLayer(layer, select)
    {
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer)
            selectedLayersUpdated(-1, layers.indexOf(layer));
        } else {
            selectedLayers.splice(selectedLayers.indexOf(layer), 1);
            selectedLayersUpdated(layers.indexOf(layer), -1);
        }
    }
    
    function removeLayer(layer)
    {
        var index = layer.indexOf(layer);
        layers.splice(index, 1);
        if (layer.selected) {
            selectedLayers.splice(selectedLayers.indexOf(layer), 1);
            selectedLayersUpdated(layer.indexOf(layer), -1);
        }
        layersUpdated(index, -1); 
    }

    function descendantCount(index)
    {
        // Return number of levels that the sub
        // tree pointed to by index contains:
        var level = layers[index].hierarchyLevel;
        for (var lastDescendantIndex = index + 1; lastDescendantIndex < layers.length; ++lastDescendantIndex) {
            if (layers[lastDescendantIndex].hierarchyLevel <= level)
                break;
        }
        return lastDescendantIndex - index - 1;
    }

    function changeLayerParent(index, targetIndex, targetIsSibling)
    {
        // Remove the layer to be moved out of
        // layers and resolve key information:
        var layerCount = descendantCount(index) + 1;
        var layerTree = layers.splice(index, layerCount);
        if (targetIndex > index)
            targetIndex -= layerCount;

        var layer = layerTree[0];
        var parentLayer = targetIsSibling ? layers[targetIndex].parentLayer : layers[targetIndex];
        var newLevel = parentLayer ? parentLayer.hierarchyLevel + 1 : 0;
        var insertLevel = targetIsSibling ? newLevel + 1 : newLevel;

        for (var insertIndex = targetIndex + 1; insertIndex < layers.length; ++insertIndex) {
            if (layers[insertIndex].hierarchyLevel < insertLevel)
                break;
        }

        for (var i = layerTree.length - 1; i >= 0; --i)
            layers.splice(insertIndex, 0, layerTree[i]);
        layer.parentLayer = parentLayer;

        // Store the parent change (but not the geometry changes that will occur):
        var keyframe = myApp.model.getState(layer, myApp.model.time);
        keyframe.parent = parentLayer ? parentLayer.sprite : myApp.stage.sprites;
        // Reparent sprite:
        layer.sprite.changeParent(keyframe.parent);

        // Update hierarchyLevel of all descendants to match the new parent:
        var levelDiff = newLevel - layer.hierarchyLevel; 
        for (i = 0; i < layerCount; ++i) {
            layers[insertIndex + i].hierarchyLevel += levelDiff;
        }
    }

    function removeFocusState()
    {
        if (!focusState)
            return;
        var sprite = layers[focusLayerIndex].sprite;
        sprite.removePositionKeyframe(sprite.getCurrentPositionKeyframe());
        focusState = null;
        statesUpdated(focusLayerIndex);
    }

    function setLayerIndex(oldIndex, newIndex)
    {
        var layer = layers[oldIndex]
        newIndex = Math.max(0, Math.min(layers.length - 1, newIndex));
        if (newIndex === oldIndex)
            return;
        layers.splice(oldIndex, 1);
        layers.splice(newIndex, 0, layer);
    }

    function getLayerAt(p)
    {
        for (var i=layers.length - 1; i>=0; --i) {
            var sprite = layers[i].sprite
            var m = sprite.mapFromItem(myApp.stage.sprites, p.x, p.y);
            if (m.x >= 0 && m.x <= sprite.width && m.y >= 0 && m.y <= sprite.height)
                return layers[i]
        }
    }

    property FileIO file: FileIO { source: "save.anim.js" }

    function saveJSON()
    {
        var f = ".pragma library\n\nvar sprites = [\n{ image: 'dummy.jpeg', states: [\n";

        for (var i = 0; i < layers.length; ++i) {
            var layer = layers[i];
            var keyframes = layer.sprite.keyframes;
            for (var j = 0; j < keyframes.length; ++j) {
                var s = keyframes[j];
                f += "   { time: " + s.time
                + ", x: " + s.x.toFixed(2)
                + ", y: " + s.y.toFixed(2)
                + ", z: " + s.z.toFixed(2)
                + ", rotation: " + s.rotation.toFixed(2)
                + ", scale: " + s.scale.toFixed(2)
                + ", opacity: " + s.opacity.toFixed(2)
                + ", name: '" + s.name + "'"
                + " }"
                if (j < keyframes.length - 1)
                    f += ",\n"
            }
            f += (i < layers.length - 1) ? "\n]},{ image: 'dummy.jpeg', states: [\n" : "\n]}\n";
        }
        f += "]\n";

        file.write(f);
    }
}
