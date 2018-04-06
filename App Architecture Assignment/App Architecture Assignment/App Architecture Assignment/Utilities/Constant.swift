//
//  Constant.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/6/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation
import CoreLocation

struct Constant {
	
	struct LocationSearchView {
		static let cellIdentifier = "locationSearchCellIdentifier"
		static let placeHolderText = "Search on Google Maps"
	}
	
	struct SearchResultsView {
		static let allResultsText = "All Result"
		static let rangeRadius: CLLocationDistance = 100_000
	}
	
}
