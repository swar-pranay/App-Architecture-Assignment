//
//  MKResultAnnotation.swift
//  AvenueCodeChallenge
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation
import MapKit

/*
The purpose of this object is to create a custom MKAnnotation object so that
it could be added to the MKMapView. It conforms to MKAnnotation protocol
*/
class MKResultAnnotation: NSObject, MKAnnotation {
	var title: String?
	var coordinate: CLLocationCoordinate2D
	var identifier: String
	
	init(withTitle title: String, andCoordinates coordinate: CLLocationCoordinate2D, identifier: String) {
		self.title = title
		self.coordinate = coordinate
		self.identifier = identifier
	}
}
