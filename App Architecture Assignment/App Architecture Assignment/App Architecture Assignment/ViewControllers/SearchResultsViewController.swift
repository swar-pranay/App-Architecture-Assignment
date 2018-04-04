//
//  SearchResultsViewController.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class SearchResultsViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	
	var allAnnotations: [ACAnnotation] = []
	var selectedAnnotationId: String?
	var displayType: DisplayResultType = .allResult
	private let rangeRadius: CLLocationDistance = 100_000
	private var isSaved = true
	private var savedAnnotation: Annotation?
	var coreDataStack: CoreDataStack?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "All Result"
		self.mapView.delegate = self
		self.addAnnotationsToMap()
		if displayType == .singleResult {
			self.refreshSaveEditButton()
		}
	}
	
	private func refreshSaveEditButton() {
		guard let selectedAnnotationId = selectedAnnotationId else {
			return
		}
		self.navigationItem.rightBarButtonItem = nil
		fetchAnnotationWithId(selectedAnnotationId)
		if !isSaved {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveClicked))
		} else {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashClicked))
		}
	}
	
	@objc private func saveClicked() {
		
		guard let moc = coreDataStack?.managedObjectContext, let selectedAnnotationId = selectedAnnotationId else {
			return
		}
		
		guard let selectedACAnnotation = allAnnotations.filter({$0.id == selectedAnnotationId}).first else {
			print("Could not find ACAnnotation Object")
			return
		}
		
		// using Force Unwrap since its guranteed to be Annotation object 
		let newAnnotation = NSEntityDescription.insertNewObject(forEntityName: "Annotation", into: moc) as! Annotation
		
		newAnnotation.identifier = selectedACAnnotation.id
		newAnnotation.name = selectedACAnnotation.title
		newAnnotation.lattitude = selectedACAnnotation.lat
		newAnnotation.longitude = selectedACAnnotation.long
		coreDataStack?.save()
		refreshSaveEditButton()
	}
	
	@objc private func trashClicked() {
		
		let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete the annotation", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
			self.deleteAnnotation()
			self.refreshSaveEditButton()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	private func fetchAnnotationWithId(_ id: String)  {
		
		let fetchRequest = NSFetchRequest<Annotation>(entityName: "Annotation")
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
		do {
			let fetchResult = try coreDataStack?.managedObjectContext.fetch(fetchRequest)
			if let fetchedAnnotation = fetchResult?.first {
				isSaved = true
				savedAnnotation = fetchedAnnotation
			} else {
				isSaved = false
			}
		} catch {
			print("Could not complete the fetch request")
		}
	}
	
	private func deleteAnnotation() {
		guard let tobeDeletedAnnotation = savedAnnotation else {
			return
		}
		coreDataStack?.managedObjectContext.delete(tobeDeletedAnnotation)
	}
	
	private func addAnnotationsToMap() {
		
		let mkAnnotations = allAnnotations.map { (annotation) -> MKAnnotation in
			
			let newAnnotation = MKResultAnnotation(withTitle: annotation.title,
												   andCoordinates: CLLocationCoordinate2D(latitude: annotation.lat,
																						  longitude: annotation.long),
												   identifier: annotation.id)
			return newAnnotation
		}
		
		self.mapView.addAnnotations(mkAnnotations)
		
		if displayType == .singleResult {
			guard let selectedAnnotationId = selectedAnnotationId else {
				return
			}
			selectAnnotationWithId(selectedAnnotationId)
		} else {
			mapView.showAnnotations(mapView.annotations, animated: true)
		}
	}
	
	private func selectAnnotationWithId(_ idString: String) {
		
		guard let selectedACAnnotation = allAnnotations.filter({$0.id == idString}).first else {
			print("Could not find ACAnnotation Object")
			return
		}
		
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: selectedACAnnotation.lat,
																						 longitude:selectedACAnnotation.long), rangeRadius, rangeRadius)
		mapView.setRegion(coordinateRegion, animated: true)
		
		if let currentResultAnnotations = self.mapView.annotations as? [MKResultAnnotation] {
			let selectedMKResultAnnotation = currentResultAnnotations.filter { $0.identifier == selectedACAnnotation.id }
			if let selectedMKAnnotation = selectedMKResultAnnotation.first {
				mapView.selectAnnotation(selectedMKAnnotation , animated: true)
			}
		}
	}
	
}

extension SearchResultsViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

		guard let mkSelectedAnnotation = view.annotation as? MKResultAnnotation else {
			return
		}
		
		self.selectedAnnotationId = mkSelectedAnnotation.identifier
		selectAnnotationWithId(mkSelectedAnnotation.identifier)
		refreshSaveEditButton()
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard let annotation = annotation as? MKResultAnnotation else {
			return nil
		}
		
		let reuseIdentifier = "marker"
		var view: MKPinAnnotationView!
		
		if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView {
			view.annotation = annotation
			view = dequedView
		} else {
			view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			view.canShowCallout = true
			view.calloutOffset = CGPoint(x: -5.0, y: -10.0)
		}
		
		return view
	}
	
}
