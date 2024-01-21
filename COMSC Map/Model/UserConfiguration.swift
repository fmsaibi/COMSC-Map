//
//  UserConfiguration.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 12/08/2023.
//

import Foundation
enum Unit {
    case kph
    case mph
    case automatic
}

enum Orientation {
    case left
    case right
    case none
}

struct UserConfiguration {
    var unit: Unit = .automatic
    var orientation: Orientation = .none
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    func configureUserSettings(from userSetting: UserSetting) -> UserConfiguration {
        var configuration = UserConfiguration()
        
        switch userSetting.unit {
        case "kph":
            configuration.unit = .kph
        case "mph":
            configuration.unit = .mph
        default:
            configuration.unit = .automatic
        }
        
        switch userSetting.orientation {
        case "left":
            configuration.orientation = .left
        case "right":
            configuration.orientation = .right
        default:
            configuration.orientation = .none
        }
        
        return configuration
    }
}
