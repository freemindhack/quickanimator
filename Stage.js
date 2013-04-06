function StageClass() {
    var selectedLayers = new Array
    var layers = new Array;

    var mousedown = false;
    var pressStartTime = 0;
    var pressStartPos = undefined;
    var currentAction = {};

    this.getAngleAndRadius = function(p1, p2)
    {
        var dx = p2.x - p1.x;
        var dy = p1.y - p2.y;
        return {
            angle: (Math.atan2(dx, dy) / Math.PI) * 180,
            radius: Math.sqrt(dx*dx + dy*dy)
        }; 
    }

    this.getLayerAt = function(p)
    {
        for (var i=layers.length - 1; i>=0; --i) {
            var image = layers[i].image
            if (p.x >= image.x && p.x <= image.x + image.width
                && p.y >= image.y && p.y <= image.y + image.height) {
                return layers[i]
            }
        }
    }

    this.overlapsHandle = function(pos)
    {
        for (var i in selectedLayers) {
            var layer = selectedLayers[i];
            var image = layer.image
            var cx = image.x + (image.width / 2)
            var cy = image.y + (image.height / 2)
            var dx = pos.x - cx
            var dy = pos.y - cy
            var len = Math.sqrt((dx * dx) + (dy * dy))
            if (len < focusSize)
                return layer
        }
        return null;
    }

    this.pressStart = function(pos)
    {
        // start new layer operation, drag or rotate:
        mousedown = true;
        pressStartTime = new Date().getTime();
        pressStartPos = pos;

        if (selectedLayers.length !== 0) {
            var layer = this.overlapsHandle(pos);
            if (layer) {
                // start drag
                currentAction = {
                    layer: layer, 
                    dragging: true,
                    x: pos.x,
                    y:pos.y,
                };
            } else {
                // Start rotation
                var layer = selectedLayers[0];
                var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                currentAction = this.getAngleAndRadius(center, pos);
                currentAction.rotating = true
            }
        }
    }

    this.pressDrag = function(pos)
    {
        // drag or rotate current layer:
        if (mousedown) {
            if (currentAction.selecting) {
                var layer = this.getLayerAt(pos);
                if (layer && !layer.selected)
                    layer.select(true);
            } else if (selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    for (var i in selectedLayers) {
                        var image = selectedLayers[i].image;
                        image.x += pos.x - currentAction.x;
                        image.y += pos.y - currentAction.y;
                    }
                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    var layer = selectedLayers[0];
                    var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                    var aar = this.getAngleAndRadius(center, pos);
                    for (var i in selectedLayers) {
                        var image = selectedLayers[i].image;
                        if (rotateFocusItems)
                            image.rotation += aar.angle - currentAction.angle;
                        if (scaleFocusItems)
                            image.scale *= aar.radius / currentAction.radius;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            } else {
                var startSelect = (Math.abs(pos.x - pressStartPos.x) < 10 || Math.abs(pos.y - pressStartPos.y) < 10);
                currentAction.selecting = true;
            }
        }
    }

    this.pressEnd = function(pos)
    {
        mousedown = false;

        var click = (new Date().getTime() - pressStartTime) < 300 
            && Math.abs(pos.x - pressStartPos.x) < 10
            && Math.abs(pos.y - pressStartPos.y) < 10;

        if (click) {
            currentAction = {};
            var layer = this.getLayerAt(pos);
            var select = layer && !layer.selected
            for (var i = selectedLayers.length - 1; i >= 0; --i)
                selectedLayers[i].select(false)
            if (select)
                layer.select(select)
        }
    }

    this.addLayer = function(layer)
    {
        layers.push(layer);
        layer.selected  = layer.selected || false;

        layer.select = function(select)
        {
            if (select === layer.selected)
                return;
            layer.selected = select;

            if (select) {
                selectedLayers.push(layer);
                layer.focus = layerFocus.createObject(0)
                layer.focus.parent = focusFrames
                layer.focus.target = layer.image
            } else {
                var index = selectedLayers.indexOf(layer);
                selectedLayers.splice(index, 1);
                layer.focus.destroy()
            }

        }

        layer.remove = function()
        {
            layers.splice(layer.getZ(), 1);
            if (layer.selected) {
                var i = selectedLayers.indexOf(layer);
                selectedLayers.splice(i, 1);
            }
        }

        layer.setZ = function(z)
        {
            z = Math.max(0, Math.min(layers.length - 1, z));
            var currentZ = layer.getZ();
            if (z === currentZ)
                return;
            layers.splice(currentZ, 1);
            layers.splice(z, 0, layer);
        }

        layer.getZ = function()
        {
            return layers.indexOf(layer);
        }

        return layer;
    }
}
