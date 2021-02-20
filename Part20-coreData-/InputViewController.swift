//
//  InputViewController.swift
//  Part20-coreData-
//
//  Created by 山本ののか on 2021/02/15.
//

import UIKit
import CoreData

final class InputViewController: UIViewController {

    enum Mode {
        case input
        case edit(Fruit)
    }

    @IBOutlet private weak var textField: UITextField!

    var mode: Mode?
    private(set) var output: Fruit?
    private(set) var editName: String?

    private let repository = FruitsRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode is nil.")
        }

        textField.text = {
            switch mode {
            case .input:
                return ""
            case let .edit(fruit):
                return fruit.name
            }
        }()
    }

    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            guard let newFruit = repository.create(name: textField.text ?? "", isChecked: false) else {
                fatalError("newFruit is nil.")
            }
            output = newFruit
        case .edit:
            editName = textField.text ?? ""
        }

        performSegue(
            withIdentifier: {
                switch mode {
                case .edit:
                    return "edit"
                case .input:
                    return "save"
                }
            }(),
            sender: sender
        )
    }
}
