//
//  MenuProperties.swift
//
//  Created by jerry on 5/18/22.
//

import Foundation

enum MenuType: String {
    case mainMenu = "main"
    case userMenu = "user"
    case subMenu = "sub"
}

struct MenuProps {
    var menuProps =  MenuProperties()
    var lastError: String = "no error"
    mutating func decodeProperties(json: String) -> Bool {
        guard let jsonData = json.data(using: .utf8) else {
            lastError = "malformed"
            return false
        }
        do {
            menuProps = try JSONDecoder().decode(MenuProperties.self, from: jsonData)
            return true
        } catch {
            lastError = "decode failed"
            return false
       }
    }
}

struct MenuProperties: Codable {

    struct Configuration: Codable {
        var type: String?
        var value: String?
    }

    struct Image: Codable {
        var type: String?
        var name: String?
        var symbolConfig: [Configuration]?
    }

    struct  MenuElement: Codable {
        var title: String?
        var identifier: String?
        var menuImage: Image?
        var attributes: [String]?
        var modifierFlags: [String]?
        var shortcut: String?
    }

    struct  PadMenu: Codable {
        var type: String? // main or sub or user
        var title: String?
        var menuElements: [MenuElement]?
        var identifier: String?
        var afterMenuID: String?
    }

    struct  PadMenus: Codable {
        var padMenu: [PadMenu]?
        var remove: [String]?
    }

    var iPadMenus: PadMenus?
}
