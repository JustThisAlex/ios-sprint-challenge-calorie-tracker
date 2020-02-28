//
//  TrackerController.swift
//  Calorie Tracker
//
//  Created by Alexander Supe on 28.02.20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

class TrackerController {
    static let shared = TrackerController()
    let database = Firestore.firestore()
    var ref: DocumentReference?

    func create(kcals: Double, completion: () -> Void) {
        let tracker = Tracker(kcals: kcals)
        do {
            try database.collection("kcals").document("\(tracker.id?.uuidString ?? UUID().uuidString)")
                .setData(from: tracker.trackerRepresentation)
            try CoreDataStack.shared.save()
            completion()
        } catch {
            print("Error saving data: \(NSError())")
        }
    }

    func sync(completion: @escaping () -> Void) {
        database.collection("kcals").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: TrackerRepresentation.self)
                    }
                    switch result {
                    case .success(let tracker):
                        if let tracker = tracker {
                            self.update(tracker: tracker)
                        }
                    case .failure(let error):
                        print("Error decoding: \(error)")
                    }
                }
            }
            completion()
        }
    }

    func update(tracker: TrackerRepresentation) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracker")
        fetchRequest.predicate = NSPredicate(format: "id = %@", tracker.identifier.uuidString)
        do {
            let elementCount = try CoreDataStack.shared.mainContext.count(for: fetchRequest)
            if elementCount == 0 { throw NSError() }
        } catch {
            Tracker(trackerRepresentation: tracker)
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                CoreDataStack.shared.mainContext.reset()
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }
}
