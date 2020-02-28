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
        convenience init(kcals: Double,
                         date: Date = Date(),
                         identifier: UUID = UUID(),
                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
            self.init(context: context); self.kcals = kcals; self.date = date; self.id = identifier
        }

        var trackerRepresentation: TrackerRepresentation? {
            guard let date = date, let identifier = id else { return nil }
            return TrackerRepresentation(kcals: kcals, time: date, identifier: identifier)
        }

        @discardableResult
        convenience init?(trackerRepresentation: TrackerRepresentation,
                          context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
            self.init(kcals: trackerRepresentation.kcals,
                      date: trackerRepresentation.time,
                      identifier: trackerRepresentation.identifier,
                      context: context)
        }
    }
