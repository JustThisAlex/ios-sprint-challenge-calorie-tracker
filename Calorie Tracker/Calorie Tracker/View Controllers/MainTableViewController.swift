//
//  MainTableViewController.swift
//  Calorie Tracker
//
//  Created by Alexander Supe on 28.02.20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class MainTableViewController: UITableViewController {
    lazy var fetchedResultsController: NSFetchedResultsController<Tracker> = {
        let fetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do { try frc.performFetch() } catch { fatalError("Fetch failed") }
        return frc
    }()
    let notificationCenter = NotificationCenter.default
    @IBOutlet private weak var chart: Chart!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.notificationCenter.addObserver(self, selector: #selector(self.updateChart), name: NSNotification.Name("DataChanged"), object: nil)
        self.notificationCenter.post(name: NSNotification.Name("DataChanged"), object: nil)
        TrackerController.shared.sync {
            self.notificationCenter.post(name: NSNotification.Name("DataChanged"), object: nil)
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Calorie Intake", message: "Enter kcal amount", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].keyboardType = .decimalPad
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            TrackerController.shared.create(kcals: Double(alert.textFields?[0].text ?? "") ?? 0) {
            self.notificationCenter.post(name: NSNotification.Name("DataChanged"), object: nil)
            }}))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func updateChart() {
        chart.removeAllSeries()
        let series = ChartSeries(fetchedResultsController.fetchedObjects?.compactMap({ $0.kcals }) ?? [])
        series.area = true
        chart.add(series)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Calories: \(fetchedResultsController.object(at: indexPath).kcals)"
        if let date = fetchedResultsController.object(at: indexPath).date {
            cell.detailTextLabel?.text = formatter.string(from: date) }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

extension MainTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
