//
//  SearchResultsViewController.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	
	var allAnnotations: [ACAnnotation] = []
	var selectedAnnotationId: String?
	var displayType: DisplayResultType = .allResult
	var dataStoreManager: DataStoreProtocol?

	private var savedAnnotation: Annotation?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = Constant.SearchResultsView.allResultsText
		// This view controller should not be the delegate for MapView.
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
		AnnotationModelManager.fetchAnnotationWithId(selectedAnnotationId,
													 usingManager: dataStoreManager) { (annotation) in
			
			if let fetchedAnnotation = annotation {
				self.savedAnnotation = fetchedAnnotation
				self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
																		 target: self,
																		 action: #selector(trashClicked))
			} else {
				self.savedAnnotation = nil
				self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
																		 target: self,
																		 action: #selector(saveClicked))
			}
		}
		
	}
	
	@objc private func saveClicked() {
		guard let selectedAnnotationId = selectedAnnotationId else {
			return
		}
		guard let selectedACAnnotation = allAnnotations.filter({$0.id == selectedAnnotationId}).first else {
			print("Could not find ACAnnotation Object")
			return
		}
		AnnotationModelManager.saveModel(selectedACAnnotation,
										 usingManager: dataStoreManager)
		refreshSaveEditButton()
	}
	
	@objc private func trashClicked() {
		
		let alertController = UIAlertController(title:
			NSLocalizedString(Constant.SearchResultsView.deleteWarningTitle, comment: ""),
												message:NSLocalizedString(Constant.SearchResultsView.deleteWarningMessage,
																		  comment: ""),
												preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] (action) in
			guard let strongSelf = self else { return }
			AnnotationModelManager.deleteAnnotation(strongSelf.savedAnnotation,
													usingManager: strongSelf.dataStoreManager)
			strongSelf.refreshSaveEditButton()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)

		present(alertController, animated: true, completion: nil)
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
		
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: selectedACAnnotation.lat,longitude:selectedACAnnotation.long), Constant.SearchResultsView.rangeRadius, Constant.SearchResultsView.rangeRadius)
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
		
		let reuseIdentifier = Constant.SearchResultsView.annotationViewReuseIdentifier
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
