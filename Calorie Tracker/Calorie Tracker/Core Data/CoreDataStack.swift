//
//  CoreDataStack.swift
//  Calorie Tracker
//
//  Created by Alexander Supe on 28.02.20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Failed to load persistent stores: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var mainContext: NSManagedObjectContext {
        container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var outputError: Error?
        context.performAndWait {
            do { try context.save() } catch { outputError = error }
        }
        if let error = outputError { throw error }
    }

}
