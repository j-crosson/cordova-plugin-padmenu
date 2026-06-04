# cordova-plugin-padMenu


iPadOS 26 and later includes a menu bar for every app. This plugin can remove unwanted menus, add new menus, and handle menu interaction.

* Add or remove menus 
* Add Keyboard Shortcuts
* Handles "print" menu


This plugin is for iPadOS only: it has no effect on iOS or Android versions of an app.

Handles the "print" menu. This is the only standard menu handled. 

Minimum supported Deployment Target is iOS13.  Has no effect unless running iOS26+. It will return a "pre26" error if run on iOS versions less the iOS26. 

The main menu should be set up as early as possible.  We can't do menu setup at the point Apple suggests: that would require native code.  What we can do is menu set up first thing in  "onDeviceReady".

## What’s Ahead

* SubMenus
* Additional placement options 
* Ability to manipulate menu items

## Installation
```bash
cordova plugin add cordova-plugin-padmenu
```

## Getting Started

The best way is to build the Demo App. This app demonstrates the following:

* Removing menus.
* Adding user-defined menu.
* Adding menu items to existing menu.
* Creating keyboard shortcuts

 - https://github.com/j-crosson/cordova-menu-demo


## Example

Remove all menus except for Application, Window, and Help

```javascript
    let remove = '{
            "iPadMenus": {
                "remove": [
                    "view",
                    "newItem",
                    "document",
                    "edit",
                    "format",
                    "preferences",
                    "file"
                ]
            }
        }';
    PadMenu.menuAction ('modify',null, () => {alert("Pre iOS26, no effect");},[remove]);

```

## menuAction
```javascript

    PadMenu.menuAction(action,success,error,arguments[])
    
```

Perform Menu Action such as creating menu items.


| Parameter | Type | Description | Default |
| --- | --- | --- |--- |
| action | String |  action  to perform | |
| success | Function | Success callback function| null |
| error | Function | Error callback | null|
| arguments | [String] |  action  data | [""]|



### actions:


***
**modify** 
***
Modify main iPad Menu Bar
Adds or removes Menu/Menu Items

Creates menu items either as an addition to an existing menu or a user-created menu, and removes existing menu items. 


```javascript

    PadMenu.menuAction ('modify', menuModified, modifyFailed,[modifyJSON])}; 
  
```


## modify JSON

Menu data is represented by the following JSON:



**PadMenus**

Menu items to add to and/or remove from main menu bar


| Property | Type | Description |
| --- | --- | --- |
| padMenu | [PadMenu] |  menus to add/modify |
| remove | [Identifier] | menu items to remove | 

**remove**

Menu items to remove

    Type: [Identifier]

 ```javascript
menuJSON = '{ 
      "remove": [
            "view",
            "newItem",
            "document",
            "file"
        ]
}';
```

**PadMenu**
    
Menu items to add 

| Property | Type | Description | 
| --- | --- | --- |
| type | MenuType |  type of menu |
| title | String |  title of user-defined menu | 
| menuElements | [MenuElement] |  Items to add | 
| identifier | Identifier | Unique ID or ID of standard menu | 
| afterMenuID | Identifier |  Menu User Menu follows  |


**type**
    
    Type: MenuType

Menu items are either added to an existing menu or a user-defined menu

| MenuType | Description |
| --- | --- |
| main | add items to an existing menu |
| user | add items to a user-defined menu |

```javascript
menuJSON = '{"type": "main"}';
```

**title**
    
    Type: String

Title of  user-defined menu. Not used if modifying an existing menu. 


```javascript
menuJSON = '{"title": "User Menu"}';
```

**MenuElement**

Item to add to menu 


| Property | Type | Description |
| --- | --- | --- |
| title | String|  item title |
| identifier | Identifier |  item identifier | 
| menuImage | Image | menu image | 
| attributes | [Attribute] | menu item attributes | 
| modifierFlags | [Modifier] | keyboard shortcut modifiers | 
| shortcut | String | keyboard shortcut key | 


**title**
    
    Type: String

Item title


```javascript
menuJSON = '{"title":"Item 3"}';
```


**Identifier**
    
    Type: Standard Menu Identifier, String



A Standard Menu identifier refers to a built-in menu, an Apple-defined menu that already exists, while an user-defined identifier is a unique identifier string for a user-defined menu. 

| Standard Menu Identifier | 
| --- | 
| application |  
| file | 
| edit | 
| view | 
| window | 
| help | 
| about | 
| preferences | 
| services | 
| hide | 
| quit | 
| newItem | 
| open | 
| openRecent | 
| close | 
| print | 
| document | 
| unredo | 
| standardEdit | 
| find | 
| findPanel | 
| replace | 
| share | 
| textStyle | 
| spelling | 
| spellingPanel | 
| spellingOptions | 
| substitutions | 
| substitutionsPanel | 
| substitutionOptions | 
| transformations | 
| speech | 
| lookup | 
| learn | 
| format | 
| autoFill | 
| font | 
| textSize | 
| textColor | 
| textStylePasteboard | 
| text | 
| writingDirection | 
| alignment | 
| toolbar | 
| sidebar | 
| fullscreen | 
| minimizeAndZoom | 
| bringAllToFront | 
| root | 



**identifier**

    Type: Identifier

Unique item identifier

```javascript

// user-defined 
menuJSON = '{"identifier": "item 3"}';


// Standard Menu Identifier
menuJSON = '{"identifier": "application"}';


```


**menuImage**

Type:   Image

Menu element image


```javascript
menuJSON = '{
  "menuImage": {
    "type": "symbol",
    "name": "dice",
    "symbolConfig": [
      {
        "type": "scale",
        "value": "large"
      }
    ]
  }
}';
```


**Image**

| Property | Type | Description |
| --- | --- | --- | 
| type | Image Type | Image type |
| name  | String | File or symbol name | 
| symbolConfig  | [Configuration] | Symbol attributes  | 

**type**

Type:   Image Type

Type of Image.  Either a user-supplied image or an Apple SF symbol.

| Image Type | Description |
| --- | --- |
| symbol | Apple SF symbol.  A collection of thousands of symbols.  See Apple SF Symbol docs. |
| file | Image file    |



```javascript
menuJSON = '{"type": "symbol"}';
```


 **name**

Type:   String
   
 File name of image or symbol name
 
 
```javascript
menuJSON = '{"name": "dice"}';
// "dice" is an SF symbol
```


**symbolConfig**

Type:   [Configuration]

 Array of symbol attributes  


**Configuration**

Configuration options for Symbol Images
See Apple docs for UIImage.SymbolConfiguration


| Property | Type | Description | 
| --- | --- | --- | 
| type | Configuration Type | Configuration type |
| value  | Attribute Value | attribute value  |

**type**

Type:   Configuration Type

Type of configuration.  Currently support “scale” and “weight”.


| Configuration Type | Description |
| --- | --- |
| scale |  symbol scale |
| weight | symbol weight |



```javascript
menuJSON = '{"type": "weight"}';
```


**value**

Type:   Attribute Value

> scale

| Attribute Value | Description |
| --- | --- |
| default |  system default |
| unspecified | unspecified scale |
| small | small symbol image |
| medium | medium symbol image |
| large | large symbol image |

> weight

| Attribute Value | Description |
| --- | --- |
| unspecified | unspecified weight |
| ultraLight | ultraLight weight |
| thin | thin weight |
| light | light weight |
| regular | regular weight |
| medium | medium weight |
| semibold | semibold weight |
| bold | bold weight |
| heavy | heavy weight |
| black | ultra-heavy weight |



```javascript
menuJSON = '{"value": "bold"}';
```

**attributes**

Menu element attributes

Type:   Attribute

| Attribute | Description |
| --- | --- |
| destructive | more prominent style |
| disabled | element can’t be selected |
| hidden | element not displayed |


```javascript
menuJSON = '{"attributes": ["destructive"]}';
```

**modifierFlags**

Keyboard shortcut modifiers.  Key(s) pressed simultaneously with shortcut key. Default is "command".

Type:   Modifier


| Modifier | Description |
| --- | --- |
| command | Command key |
| control | Control key |
| option |  Option key |
| shift | Shift key |


```javascript
menuJSON = '{
    "modifierFlags": [
        "command",
        "option"
        ]
    }';
```

**shortcut**

Menu shortcut key.  Must be single character

Type:   String

```javascript
menuJSON = '{"shortcut": "6"}';
```


**afterMenuID**

Type:   Identifier

Standard Menu identifier of Menu that User Menu is inserted after.

```javascript
menuJSON = '{"afterMenuID": "application"}';
```


## Print Menu

To handle a print menu selection, set  "PadMenu.print" to the print handler

### Example

```javascript
    PadMenu.print = onPrintSelected;
    // in onDeviceReady()

    function onPrintSelected() {
        alert("Print Selected");
    }
```

## Selection Handler

When a menu item is selected, the handler assigned to Padmenu.selected is called.

```javascript
selection_handler(identifier)
```

| Parameter | Type | Description |
| --- | --- | --- |
| identifier | String |Unique item identifier |


```javascript
    PadMenu.selected = onSelected;
    // in onDeviceReady()

    function onSelected(identifier) {
        alert("Selected "+ identifier);
    }
```



## Example

```javascript
let menuJSON = 
'{
  "iPadMenus": {
    "remove": [
      "view",
      "newItem",
      "document",
      "edit",
      "format",
      "preferences"
    ],
    "padMenu": [
      {
        "type": "user",
        "title": "User Menu",
        "afterMenuID": "application",
        "menuElements": [
          {
            "title": "Item 1",
            "identifier": "item 1",
            "shortcut": "6",
            "modifierFlags": [
              "command"
            ],
            "menuImage": {
              "type": "symbol",
              "name": "dice",
              "symbolConfig": [
                {
                  "type": "scale",
                  "value": "large"
                }
              ]
            }
          },
          {
            "title": "Item 2",
            "identifier": "item 2",
            "shortcut": "7",
            "modifierFlags": [
              "command",
              "option"
            ],
            "menuImage": {
              "type": "symbol",
              "name": "dice",
              "symbolConfig": [
                {
                  "type": "weight",
                  "value": "bold"
                }
              ]
            }
          },
          {
            "title": "Item 3",
            "identifier": "item 3",
            "menuImage": {
              "type": "symbol",
              "name": "dice",
              "symbolConfig": [
                {
                  "type": "scale",
                  "value": "large"
                },
                {
                  "type": "weight",
                  "value": "bold"
                }
              ]
            }
          },
          {
            "title": "Item 4",
            "identifier": "item 4",
            "menuImage": {
              "type": "symbol",
              "name": "dice"
            }
          },
          {
            "title": "Stop",
            "identifier": "item 5",
            "menuImage": {
              "type": "symbol",
              "name": "flame.fill"
            },
            "attributes": [
              "destructive"
            ]
          }
        ],
        "menuTitle": "Menu",
        "identifier": "file"
      }
    ]
  }
}';

    PadMenu.menuAction ('modify',null, () => {alert("Pre iOS26, no effect");},[menuJSON]);

```
