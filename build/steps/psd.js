
var fs = require('fs');
var PSD = require('psd');
var Jimp = require('Jimp');


var fn = function(done) {
    
    var root = __dirname + "/../../src/scenepsds/";
    
    console.log(root);
    
    fs.readdir(root, function(err, files) {
       
        if (err) {
            console.log(err);   
        }
        
        files.forEach(function(f) {
            
            if (f.endsWith(".psd")) {
             
                var psd = PSD.fromFile(root + f);
                psd.parse();
                var data = psd.tree().export();
                console.log(data);
                var docWidth = data.document.width;
                var docHeight = data.document.height;
                console.log(root + f);
                var roomName = f.substring(0, f.length - 4);
                var outputFolder = __dirname + "/../../game/gfx/scenes/" + roomName;
                if (!fs.existsSync(outputFolder)) fs.mkdirSync(outputFolder);
                
                var layers = psd.tree().descendants().map(function(x) { return x });
                
                var objects = {}
                
                console.log(layers.length + " layers to process");
                
                function next() {
                   
                    var layer = layers.shift();
                    
                    if (!layer) {
                        //save objects
                        var json = JSON.stringify(objects);
                        return fs.writeFile(outputFolder + "/objects.json", json, function(err) {
                            if(err) {
                                return console.log(err);
                            }
                            done();   
                        }); 
                    }
                    
                    var name = layer.get('name').toLowerCase();
                    
                    
                    
                    console.log("Processing: " + name);
                    
                    if (name == "walkable") {
                        if (!fs.existsSync(outputFolder + "/masks/")) fs.mkdirSync(outputFolder + "/masks/");
                        var buffer = new Buffer(layer.layer.image.pixelData);
                        var tmpFile = roomName + name + "tmp.png";
                        layer.saveAsPng(tmpFile).then(function() {
                            var image = new Jimp(tmpFile, function (err, image) {
                                if (err) {
                                    console.log("failed " + tmpFile);
                                    throw new Error(err);   
                                }
                                var finalImage = new Jimp(docWidth,docHeight, function (err, finalImage) {
                                    finalImage.blit(image, layer.get('left'), layer.get('top'));
                                    finalImage.write(outputFolder + "/masks/walkable.png", function() {
                                        console.log("written " + name);
                                        next();
                                    });
                                });    
                            });
                        });
                    }
                    else if (name == "hotspots") {
                        if (!fs.existsSync(outputFolder + "/masks/")) fs.mkdirSync(outputFolder + "/masks/");
                        var buffer = new Buffer(layer.layer.image.pixelData);
                        var tmpFile = roomName + name + "tmp.png";
                        layer.saveAsPng(tmpFile).then(function() {
                            var image = new Jimp(tmpFile, function (err, image) {
                                if (err) {
                                    throw new Error(err);   
                                }
                                var finalImage = new Jimp(docWidth,docHeight, function (err, finalImage) {
                                    finalImage.blit(image, layer.get('left'), layer.get('top'));
                                    finalImage.write(outputFolder + "/masks/hotspots.png", function() {
                                        console.log("written " + name);
                                        next();
                                    });
                                });    
                            });
                        });
                    }
                    else {
                        if (name != "background") {
                            objects[name] = {
                                x: layer.get('left'),
                                y: layer.get('top') + layer.get('height')
                            }
                        }
                        layer.saveAsPng(outputFolder + "/" + name + ".png").then(function() {
                            console.log("written " + name);
                            next();
                        });
                    }
                    
                }
                
                next();
                
            }
            
        });

    });
    
};

module.exports = fn;