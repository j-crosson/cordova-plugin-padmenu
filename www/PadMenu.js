var exec = require('cordova/exec');

var PLUGIN_NAME = 'PadMenu';

var PadMenu = function() {};


PadMenu.prototype.menuAction = function ( action, success = null, fail = null, args = []) {
    exec(success, fail, 'PadMenu', 'menuAction',  [action,...args]);
    };
    
    PadMenu.prototype.onPrint = function(results){
        if (typeof this.print !== 'undefined' && this.print !== null)
            this.print(results);
            };
    
    PadMenu.prototype.itemSelected = function(identifier){
        if (typeof this.selected !== 'undefined' && this.selected !== null)
            this.selected(identifier);
            };
    
    PadMenu.prototype.onMenuKey = function(shortcut){
        if (typeof this.menuKey !== 'undefined' && this.menuKey !== null)
            this.menuKey(shortcut);
            };
 
    PadMenu.prototype.returnStatus = {
        no26:  "0",
        badCommand:  "1",
        badShortcut:  "2"
        };

module.exports = new PadMenu();
