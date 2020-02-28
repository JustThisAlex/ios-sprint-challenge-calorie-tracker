//
//  Tracker+Convenience.swift
//  Calorie Tracker
//
//  Created by Alexander Supe on 28.02.20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation
import CoreData

extension Tracker {
    @discardableResult
    convenience init(kcals: Double, date: Date = Date(), identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context); self.kcals = kcals; self.date = date; self.id = identifier
    }
}
