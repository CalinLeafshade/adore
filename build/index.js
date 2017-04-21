
if (!String.prototype.endsWith) {
  String.prototype.endsWith = function(searchString, position) {
      var subjectString = this.toString();
      if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectString.length) {
        position = subjectString.length;
      }
      position -= searchString.length;
      var lastIndex = subjectString.indexOf(searchString, position);
      return lastIndex !== -1 && lastIndex === position;
  };
}

var fs = require('fs');

var steps = [];

fs.readdir(__dirname + "/steps", function(err, files) {
   
    files.forEach(function(f) {
        steps.push(require('./steps/' + f));
    });
    
    var next = function() {
        steps.shift();
        if (steps[0]) {
            steps[0](next);   
        }
    }
    
    steps[0](next);
    
    (function wait () {
        if (steps.length) setTimeout(wait, 1000);
    })();
    
});

