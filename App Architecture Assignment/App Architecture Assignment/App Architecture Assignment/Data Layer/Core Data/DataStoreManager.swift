//
//  DataStoreManager.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/13/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation
import CoreData

protocol DataStoreProtocol {
	func save()
	var managedObjectContext: NSManagedObjectContext { get }
}

class DataStoreManager: DataStoreProtocol {
	
	var dataStack: DataStoreProtocol!

	init(withDataStack stack: DataStoreProtocol) {
		self.dataStack = stack
	}
	
	var managedObjectContext: NSManagedObjectContext {
		get {
			return self.dataStack.managedObjectContext
		}
	}
	
	func save() {
		dataStack.save()
	}
	
}
