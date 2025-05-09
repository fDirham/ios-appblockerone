//
//  Persistence.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import CoreData
import SwiftUI
import FamilyControls

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Get mock family activity
        var newFaSelection = ""
        if let path = Bundle.main.path(forResource: "mockFaSelection", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                newFaSelection = String(data: data, encoding: .utf8) ?? "FAILED"
            } catch {
                // handle error
                debugPrint("failed to load data \(error.localizedDescription)")
            }
        }
        else {
            debugPrint("Mock path not found")
        }
        
        for i in 0..<10 {
            let newItem = AppGroup(context: viewContext)
            newItem.timestamp = Date()
            newItem.faSelection = newFaSelection
            newItem.id = UUID()
            newItem.groupName = ["socials", "gaming", "porn", "news", "addiction", "danger"].randomElement()! + " \(i)"
            newItem.groupColor = ["blue", "red", "green", "orange"].randomElement()!
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static var previewObj: AppGroup  = {
        let newItem = AppGroup(context: Self.preview.container.viewContext)
        
        // Get mock family activity
        var newFaSelection = ""
        if let path = Bundle.main.path(forResource: "mockFaSelection", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                newFaSelection = String(data: data, encoding: .utf8) ?? "FAILED"
            } catch {
                // handle error
                debugPrint("Failed to load data \(error.localizedDescription)")
            }
        }
        else {
            debugPrint("mock path not found")
        }
        
        newItem.timestamp = Date()
        newItem.faSelection = newFaSelection
        newItem.id = UUID()
        newItem.groupName = "Test group"
        newItem.groupColor = ["blue", "red", "green", "orange"].randomElement()!
        newItem.s_blockingEnabled = true
        newItem.s_strictBlock = true
        
        return newItem
    }()
    
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AppBlockerOne")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        else {
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.appblockerone")!
            let storeURL = containerURL.appendingPathComponent("AppBlockerOne.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
