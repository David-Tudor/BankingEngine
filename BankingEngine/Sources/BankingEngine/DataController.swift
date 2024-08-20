//
//  DataController.swift
//  Tudor Bank
//
//  Created by David Tudor on 03/03/2024.
//

import CoreData
import Foundation

extension NSPersistentContainer {

    public convenience init(name: String, bundle: Bundle) {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
        }

        self.init(name: name, managedObjectModel: mom)
    }

}

public class DataController: ObservableObject {
    public let container: NSPersistentContainer
    
    public init() {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: "BankingData", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentContainer(name: "BankingData", managedObjectModel: model)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

