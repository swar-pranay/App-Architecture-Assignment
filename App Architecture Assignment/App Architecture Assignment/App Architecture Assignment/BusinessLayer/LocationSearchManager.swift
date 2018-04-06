//
//  LocationSearchDelegate.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/6/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import UIKit

protocol LocationSearchManagerProtocol: class {
	func didUpdateResults(locationSearchManager: LocationSearchManager?,
						  annotationResults: [ACAnnotation])
}

class LocationSearchManager: NSObject, UISearchResultsUpdating, UISearchBarDelegate {
	
	weak var delegate: LocationSearchManagerProtocol?
	private var dispatchWorkItem: DispatchWorkItem?

	public func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text, searchText != "" else {
			DispatchQueue.main.async {
				self.delegate?.didUpdateResults(locationSearchManager: self, annotationResults: [])
			}
			return
		}
		
		// making the delay to avoid sedning too many request when user is typing fast
		dispatchWorkItem?.cancel()
		
		dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
			self?.searchFortext(searchText)
		})
		
		// using force unwrap here since dispatchWorkItem is guranteed to be present at this point
		DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(250), execute: dispatchWorkItem!)
	}

	private func searchFortext(_ searchText: String) {
		SearchResultsManager.getSearchResultsForTest(searchText) { [weak self] (results) in
			self?.delegate?.didUpdateResults(locationSearchManager: self, annotationResults: results)
		}
	}
	
}
