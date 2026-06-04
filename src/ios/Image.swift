//
//  Image.swift
//
//  Created by jerry on 11/4/21.
//

import Foundation

//
// For now we only support system symbols and file.  This may change in the future.
//

func newImage(image: MenuProperties.Image?) -> UIImage? {
    let symbolScale: [String: UIImage.SymbolScale] = ["default": .default,
                                                      "unspecified": .unspecified,
                                                      "small": .small,
                                                      "medium": .medium,
                                                      "large": .large]

    let symbolWeight: [String: UIImage.SymbolWeight] = ["unspecified": .unspecified,
                                                        "ultraLight": .ultraLight,
                                                        "thin": .thin,
                                                        "light": .light,
                                                        "regular": .regular,
                                                        "medium": .medium,
                                                        "semibold": .semibold,
                                                        "bold": .bold,
                                                        "heavy": .heavy,
                                                        "black": .black]

    // only "symbol"  or "file" is valid
    guard (image?.type == "symbol") || (image?.type == "file")  else {
       return nil
    }

    guard let theName = image?.name  else {
       return nil
    }

    if image?.type == "file" {
        return UIImage(contentsOfFile: theName)
    }

    var config = UIImage.SymbolConfiguration(scale: .default)

    if let symbolConfig = image?.symbolConfig {
        for item in symbolConfig {
            switch item.type {
            case "scale":
                if let configScale = item.value, let scaleEnum = symbolScale[configScale] {
                    let config1 =  UIImage.SymbolConfiguration(scale: scaleEnum)
                    config = config.applying(config1)
                }
            case "weight":
                if let configWeight = item.value, let weightEnum = symbolWeight[configWeight] {
                    let config1 =  UIImage.SymbolConfiguration(weight: weightEnum)
                    config = config.applying(config1)
                }
            default:
                continue
            }
        }
    }
    return UIImage(systemName: theName, withConfiguration: config)
}
