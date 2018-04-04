//
//  Annotation.swift
//  AvenueCodeChallenge
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation

// AC prefix for Avenue Code
/*
Purpose: The purpose of this object is to hold on to the result so, that
it could be passes around inside the entire app
*/
struct ACAnnotation: Decodable {
	var id: String
	var title: String
	var lat: Double
	var long: Double
	
	init(id: String, title: String, lat: Double, long: Double) {
		self.id = id
		self.title = title
		self.lat = lat
		self.long = long
	}
	
	enum CodingKeys: String, CodingKey {
		case formattedAddress = "formatted_address"
		case id = "place_id"
		case geometry = "geometry"
	}
	
	enum GeometryKeys: String, CodingKey {
		case location = "location"
	}
	
	enum LocationKeys: String, CodingKey {
		case lat = "lat"
		case long = "lng"
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.title = try values.decode(String.self, forKey: .formattedAddress)
		self.id = try values.decode(String.self, forKey: .id)
		let geometryValues = try values.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
		let location = try geometryValues.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
		self.lat = try location.decode(Double.self, forKey: .lat)
		self.long = try location.decode(Double.self, forKey: .long)
	}
}



