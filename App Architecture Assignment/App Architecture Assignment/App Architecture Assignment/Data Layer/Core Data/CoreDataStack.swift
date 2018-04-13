//
//  CoreDataStack.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation
import CoreData

/*
Purpose: This is the formation of the complete stack. Usually this stack would provide privateQueueMOC as well to run in background thread. But for the purpose of this app, MainQueueMOC is sufficient.
You will find lot of fatalError in this file since those are condition where you are not suppose to get error or fail. If its failing at those point, the app or program is in inconsistent condition. 
*/
class CoreDataStack: DataStoreProtocol {
	
	private static let modelName = "appArchitecture"
	
	private(set) lazy var managedObjectContext: NSManagedObjectContext = {
		
		let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		moc.persistentStoreCoordinator = self.persistentStoreCoordinator
		
		return moc
	}()
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		
		guard let modelPath = Bundle.main.url(forResource: CoreDataStack.modelName, withExtension: "momd") else {
			fatalError("could not find the momd file")
		}
		
		guard let mom = NSManagedObjectModel(contentsOf: modelPath) else {
			fatalError("could not create the managed Object model")
		}
		
		return mom
	}()
	
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		// Currently the file is located in the dicuments directory. If the app has enabled file sharing through native files app, I would move it to application support directory
		guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Could not find URL for documents directory")
		}
		
		let sqliteFile = documentsDir.appendingPathComponent("\(CoreDataStack.modelName).sqlite")
		
		do {
			try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteFile, options: nil)
		} catch {
			fatalError("Erro while creating the persistent store coordinator")
		}
		
		return persistentStoreCoordinator
	}()
	
	public func save() {
		
		if self.managedObjectContext.hasChanges {
			do {
				try self.managedObjectContext.save()
			} catch  {
				print("Failed to save the MOC")
			}
		}
	}
	
}
