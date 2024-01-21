//
//  CoreDataManager.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 13/08/2023.
//

import Foundation
import CoreData



class CoreDataManager {
    static let shared = CoreDataManager()

    private let context = CoreDataStack.shared.persistentContainer.viewContext

    // MARK: - Store Data

    func storeObject(unit: Unit, orientation: Orientation) {
        let newObject = UserSetting(context: context)
        newObject.unit = unitToString(unit)
        newObject.orientation = orientationToString(orientation)

        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func unitToString(_ unit: Unit) -> String {
        switch unit {
            case .automatic: return "automatic"
            case .kph: return "kph"
            case .mph: return "mph"
        }
    }
    
    private func orientationToString(_ orientation: Orientation) -> String {
        switch orientation {
            case .none: return "none"
            case .right: return "right"
            case .left: return "left"
        }
    }


    // MARK: - Retrieve Data

    func fetchObjects() -> [UserSetting] {
        let fetchRequest: NSFetchRequest<UserSetting> = UserSetting.fetchRequest()

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            print("Error fetching objects: \(error)")
            return []
        }
    }
    
}
