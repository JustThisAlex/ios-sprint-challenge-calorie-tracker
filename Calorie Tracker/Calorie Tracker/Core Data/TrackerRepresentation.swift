//
//  TrackerRepresentation.swift
//  Calorie Tracker
//
//  Created by Alexander Supe on 28.02.20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation

struct TrackerRepresentation: Codable {
    var kcals: Double
    var time: Date
    var identifier: UUID
}
