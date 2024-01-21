//
//  CoreDataStack.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 13/08/2023.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
