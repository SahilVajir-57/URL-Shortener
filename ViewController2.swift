//
//  ViewController2.swift
//  URL Shortener
//
//  Created by Lab5student on 2024-03-18.
//
import UIKit
import CoreData

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "cell"
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let request: NSFetchRequest<URL> = URL.fetchRequest()
        let context = AppDelegate.viewContext
        
        let fetchSort = NSSortDescriptor(key:"id", ascending: true)
        request.sortDescriptors = [fetchSort]
        
        let fetchRequest: NSFetchRequest<URL> = URL.fetchRequest()
        fetchRequest.fetchLimit = 1  // Fetch only one object
        
        do {
            if let url = try context.fetch(fetchRequest).first {
                print("Fetched URL object:")
                print("Long URL: \(url.longURL?.absoluteString ?? "Unknown")")
                print("Short URL: \(url.shortURL?.absoluteString ?? "Unknown")")
            } else {
                print("No URL objects found in Core Data.")
            }
        } catch {
            print("Error fetching URL object from Core Data: \(error)")
        }
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil) as? NSFetchedResultsController<NSFetchRequestResult>
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections,
           
            sections.count > 0{
            return sections[section].numberOfObjects
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DataCell
        let url = fetchedResultsController.object(at: indexPath) as! URL
        cell.shorlURLCol.text = url.shortURL?.absoluteString
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails2", sender: indexPath)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showDetails2"{
            if let indexPath = tableView.indexPathForSelectedRow {
                let url = fetchedResultsController.object(at: indexPath) as! URL
                let dest = segue.destination as! DetailViewController
                dest.selectedURL = url
            }
        }
    }
}
