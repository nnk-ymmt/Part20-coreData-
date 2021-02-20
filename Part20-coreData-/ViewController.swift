//
//  ViewController.swift
//  Part20-coreData-
//
//  Created by 山本ののか on 2021/02/15.
//

import UIKit
import CoreData

final class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(TableViewCell.loadNib(), forCellReuseIdentifier: TableViewCell.reuseIdentifier)
            tableView.isHidden = true
        }
    }

    private(set) var editIndexPath: IndexPath?
    private let useCase = FruitsUseCase()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
        tableView.isHidden = false
    }

    @IBAction func cancel(segue: UIStoryboardSegue) { }

    @IBAction func save(segue: UIStoryboardSegue) {
        guard let inputVC = segue.source as? InputViewController,
              let newFruit = inputVC.output else {
            return
        }
        useCase.append(fruit: newFruit)
        tableView.reloadData()
    }

    @IBAction func edit(segue: UIStoryboardSegue) {
        guard let inputVC = segue.source as? InputViewController,
              let fruit = inputVC.editName,
              let editIndexPath = editIndexPath else {
            return
        }
        useCase.replace(index: editIndexPath.row, fruit: fruit)
//        tableView.reloadRows(at: [editIndexPath], with: .automatic)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = (segue.destination as? UINavigationController)?.topViewController as? InputViewController {
            switch segue.identifier ?? "" {
            case "input":
                nextVC.mode = .input
            case "edit":
                guard let editIndexPath = editIndexPath else { return }
                nextVC.mode = .edit(useCase.fruits[editIndexPath.row])
            default:
                break
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.fruits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        cell.configure(fruit: useCase.fruits[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        useCase.toggleCheck(index: indexPath.row)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath
        performSegue(withIdentifier: "edit", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        useCase.remove(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

class FruitsUseCase {
    private(set) var fruits: [Fruit]
    private let repository = FruitsRepository()

    init() {
        fruits = repository.load() ?? []
    }

    func append(fruit: Fruit) {
        fruits.append(fruit)
        repository.save()
    }

    func replace(index: Int, fruit: String) {
        repository.update(index: index, fruit: fruit)
    }

    func toggleCheck(index: Int) {
        fruits[index].isChecked.toggle()
        repository.save()
    }

    func remove(index: Int) {
        repository.delete(fruit: fruits[index])
        fruits.remove(at: index)
    }
}

class FruitsRepository {
    static let key = "Fruit"
    private static var managedObjectContext: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }

    func create(name: String, isChecked: Bool) -> Fruit? {
        guard let context = Self.managedObjectContext,
              let newFruit = NSEntityDescription.insertNewObject(forEntityName: Self.key, into: context) as? Fruit else {
            print("エラー")
            return nil
        }
        
        newFruit.name = name
        newFruit.isChecked = false
        newFruit.uuid = UUID()
        newFruit.createdAt = Date()

        return newFruit
    }

    func save() {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func update(index: Int, fruit: String) {
        guard let results = load() else { return }

        if !results.isEmpty {
            results[index].setValue(fruit, forKey: "name")
        }

        save()
    }

    func delete(fruit: Fruit) {
        guard let context = FruitsRepository.managedObjectContext else { return }
        context.delete(fruit)
        save()
    }

    func load() -> [Fruit]? {
        guard let context = FruitsRepository.managedObjectContext else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FruitsRepository.key)
        let sortDescripter = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter]
        do {
            return try context.fetch(fetchRequest) as? [Fruit]
        } catch {
            print("エラー")
            return nil
        }
    }
}
