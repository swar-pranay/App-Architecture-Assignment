//
//  AnnotationModelManager.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/6/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation
import CoreData

class AnnotationModelManager {
	
	private init() {}
	
	static func saveModel(_ annotation: ACAnnotation,
									usingManager stackManager: DataStoreProtocol?) {
		guard let coreDataStack = stackManager else {
			return
		}
		
		// using Force Unwrap since its guranteed to be Annotation object
		let newAnnotation = NSEntityDescription.insertNewObject(forEntityName: "Annotation", into: coreDataStack.managedObjectContext) as! Annotation
		newAnnotation.identifier = annotation.id
		newAnnotation.name = annotation.title
		newAnnotation.lattitude = annotation.lat
		newAnnotation.longitude = annotation.long
		coreDataStack.save()
	}
	
	static func fetchAnnotationWithId(_ annotationId: String,
									  usingManager stackManager: DataStoreProtocol?,
									  withCompletion completion: (Annotation?) -> Void) {
		guard let coreDataStack = stackManager else {
			completion(nil)
			return
		}
		
		let fetchRequest = NSFetchRequest<Annotation>(entityName: "Annotation")
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", annotationId)
		do {
			let fetchResult = try coreDataStack.managedObjectContext.fetch(fetchRequest)
			if let fetchedAnnotation = fetchResult.first {
				completion(fetchedAnnotation)
			} else {
				completion(nil)
			}
		} catch {
			print("Could not complete the fetch request")
			completion(nil)
		}
	}
	
	
	static func deleteAnnotation(_ annotation: Annotation?,
								 usingManager stackManager: DataStoreProtocol?) {
		guard let tobeDeletedAnnotation = annotation,
			let coreDataStack = stackManager else {
			return
		}
		coreDataStack.managedObjectContext.delete(tobeDeletedAnnotation)
		coreDataStack.save()
	}
}
