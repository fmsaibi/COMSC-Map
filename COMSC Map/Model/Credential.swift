//
//  Credential.swift
//  Daleel Map
//
//  Created by Fahad Al Khusaibi on 09/03/2023.
//

import Foundation

class Credential {
    
    
    private let credent: NSDictionary
    
    init () {
        if let filePath = Bundle.main.path (forResource: "HereMapService-info", ofType: "plist"), let plist = NSDictionary (contentsOfFile: filePath) {
            
            self.credent =  plist
            
        } else {
            
            fatalError("Couldn't find file Here Map Service plist")
            
        }
    }


    func getAppID() -> String{

        return credent.object(forKey: "App_ID") as? String ?? ""

    }


    func getAppCode() -> String{

        return credent.object(forKey: "App_Code") as? String ?? ""

    }

    func getLicenseKey() -> String{

        return credent.object(forKey: "License_Key") as? String ?? ""

    }
    
}
