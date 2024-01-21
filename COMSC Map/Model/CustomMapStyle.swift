//
//  CustomMapStyle.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 24/08/2023.
//

import Foundation


import Foundation

class CustomMapStyle {
    static func getCustomMapStyle() -> String? {
        if let infoDict = Bundle.main.infoDictionary,
           let customMapStyle = infoDict["CustomMapStyle"] as? String {
            return customMapStyle
        }
        return nil
    }
}
