//
// Padmenu.swift
//
//  Created by jerry on 12/13/24.
//  This file has a pre-package manager workaround which will go away in the next version
//

import Foundation
import UIKit
import WebKit

private var disabledMenu: [String] = []
private var printDisabled: Bool = false


extension CDVViewController {
    open override func printContent(_: Any?) {
        commandDelegate.evalJs("PadMenu.onPrint('');")
     }

    @objc func menuKey(_ sender: UIKeyCommand) {
        let select = sender.propertyList as?  String ?? ""
        commandDelegate.evalJs("PadMenu.itemSelected('\(select)');")
    }

    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

         if #available(iOS 15.0, *) {
             //only one for now but there may be more to come
            switch action {
                case #selector(UIResponderStandardEditActions.printContent(_:)) where printDisabled == true:
                    return false
                default:
                    return super.canPerformAction(action, withSender: sender)
                }
         } else {
            return super.canPerformAction(action, withSender: sender)
    }
}

    open override func validate(_ command: UICommand) {
        if disabledMenu.count == 0 {
            return
        }
    
        if let commandPlistString = command.propertyList as? String {
            if disabledMenu.firstIndex(of: commandPlistString)   != nil {
                command.attributes = .disabled
            }
        }
    }
}

enum ReturnStatus {
    static let pre26: String = "0"
    static let badCommand: String = "1"
    static let badShortcut: String = "2"
}

@available(iOS 26.0, *)
private let menuIdentifier: [String: UIMenu.Identifier] = ["application": .application,
                                                           "file": .file,
                                                           "edit": .edit,
                                                           "view": .view,
                                                           "window": .window,
                                                           "help": .help,
                                                           "about": .about,
                                                           "preferences": .preferences,
                                                           "services": .services,
                                                           "hide": .hide,
                                                           "quit": .quit,
                                                           "newItem": .newItem,
                                                           "open": .open,
                                                           "openRecent": .openRecent,
                                                           "close": .close,
                                                           "print": .print,
                                                           "document": .document,
                                                           "unredo": .undoRedo,
                                                           "standardEdit": .standardEdit,
                                                           "find": .find,
                                                           "findPanel": .findPanel,
                                                           "replace": .replace,
                                                           "share": .share,
                                                           "textStyle": .textStyle,
                                                           "spelling": .spelling,
                                                           "spellingPanel": .spellingPanel,
                                                           "spellingOptions": .spellingOptions,
                                                           "substitutions": .substitutions,
                                                           "substitutionsPanel": .substitutionsPanel,
                                                           "substitutionOptions": .substitutionOptions,
                                                           "transformations": .transformations,
                                                           "speech": .speech,
                                                           "lookup": .lookup,
                                                           "learn": .learn,
                                                           "format": .format,
                                                           "autoFill": .autoFill,
                                                           "font": .font,
                                                           "textSize": .textSize,
                                                           "textColor": .textColor,
                                                           "textStylePasteboard": .textStylePasteboard,
                                                           "text": .text,
                                                           "writingDirection": .writingDirection,
                                                           "alignment": .alignment,
                                                           "toolbar": .toolbar,
                                                           "sidebar": .sidebar,
                                                           "fullscreen": .fullscreen,
                                                           "minimizeAndZoom": .minimizeAndZoom,
                                                           "bringAllToFront": .bringAllToFront,
                                                           "root": .root
                                                           ]

private let menuAttributes: [String: UIMenuElement.Attributes] = ["destructive": .destructive,
                                                          "disabled": .disabled,
                                                          "hidden": .hidden]

private let modifierFlags: [String: UIKeyModifierFlags] = ["command": .command,
                                                   "control": .control,
                                                   "option": .alternate,
                                                   "shift": .shift]

private var menuProperties = MenuProps()

@objc public class PadMenu: CDVPlugin {

    func commandError(_ command: CDVInvokedUrlCommand, _ errorString: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus.error, messageAs: errorString)
        commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(menuAction:)
    func documentAction(command: CDVInvokedUrlCommand) {
        guard command.arguments.count > 0,
              let gAction  = command.arguments[0] as? String  else {
            commandError(command, ReturnStatus.badCommand)
            return
        }
        switch gAction {
            case "modify":

            if #available(iOS 26.0, *) {
                
            guard let jstring  = command.arguments[1] as? String else {
                commandError(command, ReturnStatus.badCommand)
                return
            }

            let config = UIMainMenuSystem.Configuration()

            if menuProperties.decodeProperties(json: jstring) {
                UIMainMenuSystem.shared.setBuildConfiguration(config) { menuBuilder in
                    //
                    // remove menu items
                    //
                    if let removeItems = menuProperties.menuProps.iPadMenus?.remove {
                        for removeItem in removeItems {
                            if let remove = menuIdentifier[removeItem] {
                                menuBuilder.remove(menu: remove)
                            }
                        }
                    }
                    //
                    // Add menu/elements
                    //
                    if let menus = menuProperties.menuProps.iPadMenus?.padMenu {
                        for menu in menus {
                            var menuChildren = [UIMenuElement]()
                            if let menuElements = menu.menuElements {
                                for item in menuElements {
                                    var  atts: UIKit.UIMenuElement.Attributes = []
                                    if let attributes = item.attributes {
                                        for attribute in attributes {
                                            if let menuAttribute = menuAttributes[attribute] {
                                                atts.insert(menuAttribute)
                                            }
                                        }
                                    }
                                    if let shortcut = item.shortcut {
                                        //
                                        // add item with keyboard shortcut
                                        //
                                        guard shortcut.count == 1 else {
                                            self.commandError(command, ReturnStatus.badShortcut)
                                            return
                                        }

                                        var  modifiers: UIKeyModifierFlags = []
                                        if let mods = item.modifierFlags {
                                            for mod in mods {
                                                if let modFlag = modifierFlags[mod] {
                                                    modifiers.insert(modFlag)
                                                }
                                            }
                                        }
                                        // default is .command
                                        if modifiers.isEmpty {
                                            modifiers.insert(.command)
                                        }

                                        let shortMenu = UIKeyCommand(title: item.title ?? "",
                                                                     image: newImages(image: item.menuImage),
                                                                     action: #selector(self.viewController.menuKey),
                                                                     input: shortcut,
                                                                     modifierFlags: modifiers,
                                                                     propertyList: item.identifier ?? "",
                                                                     attributes: atts)
                                        menuChildren.append(shortMenu)
                                    } else {
                                        //
                                        // add item without keyboard shortcut
                                        //
                                        let shortMenu = UICommand(title: item.title ?? "",
                                                                     image: newImages(image: item.menuImage),
                                                                     action: #selector(self.viewController.menuKey),
                                                                     propertyList: item.identifier ?? "",
                                                                     attributes: atts)
                                        menuChildren.append(shortMenu)
                                    }
                                }
                                if let theType = menu.type {
                                    if theType == MenuType.mainMenu.rawValue {
                                        //
                                        // add items to existing menu
                                        //
                                        guard let mId = menu.identifier, let menuId = menuIdentifier[mId] else {
                                            return
                                        }
                                        menuBuilder.insertElements(menuChildren, atEndOfMenu: menuId)
                                    } else if theType == MenuType.userMenu.rawValue {
                                        //
                                        // add items to user-created menu
                                        //
                                        guard let title = menu.title,
                                              let after = menu.afterMenuID,
                                              let afterID = menuIdentifier[after] else {
                                            return
                                        }

                                        // both missing ID and empty string count as no identifier
                                        let stringID = menu.identifier ?? ""
                                        let menuID = stringID.isEmpty ? nil : UIMenu.Identifier(stringID)

                                        let theMenu = UIMenu(title: title,
                                                             identifier: menuID,
                                                             options: .displayInline,
                                                             children: menuChildren)

                                        menuBuilder.insertSibling(theMenu, afterMenu: afterID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            } else {
                commandError(command, ReturnStatus.pre26)
            }

        case "disable":
            if #available(iOS 26.0, *) {
                guard let disableItems  = command.arguments[1] as? [String] else {
                    commandError(command, ReturnStatus.badCommand)
                    return
                }
                disabledMenu = disableItems
                
                // "print' is for now the only special case, a standard menu item
                if disabledMenu.firstIndex(of: "print")   != nil {
                    disabledMenu.removeAll(where: { $0 == "print" })
                    printDisabled = true
                } else {
                    printDisabled = false
                }

            } else {
                commandError(command, ReturnStatus.pre26)
            }

            default:
                return
            }
        }
    }

