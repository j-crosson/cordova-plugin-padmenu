//
// Padmenu.swift
//
//  Created by jerry on 12/13/24.
//

import Foundation
import UIKit
import WebKit

extension CDVViewController {
    open override func printContent(_: Any?) {
        commandDelegate.evalJs("PadMenu.onPrint('');")
     }

    @objc func menuKey(_ sender: UIKeyCommand) {
        let select = sender.propertyList as?  String ?? ""
        commandDelegate.evalJs("PadMenu.itemSelected('\(select)');")
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
              let gAction  = command.arguments[0] as? String,
              let jstring  = command.arguments[1] as? String  else {
            commandError(command, ReturnStatus.badCommand)
            return
        }
        switch gAction {
            case "modify":

            if #available(iOS 26.0, *) {

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
                                                                     image: newImage(image: item.menuImage),
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
                                        menuChildren.append(UIAction(title: item.title ?? "",
                                                                      image: newImage(image: item.menuImage),
                                                                      identifier: UIAction.Identifier(
                                                                      item.identifier ?? ""),
                                                                      attributes: atts,
                                                                      handler: {  [unowned self] (_) in
                                        commandDelegate.evalJs("PadMenu.itemSelected('\(item.identifier  ?? "" )');")
                                        }))
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

            default:
                return
            }
        }
    }
