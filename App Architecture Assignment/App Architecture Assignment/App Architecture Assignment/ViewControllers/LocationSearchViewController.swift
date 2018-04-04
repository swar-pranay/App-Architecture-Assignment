//
//  LocationSearchViewController.swift
//  AvenueCodeChallenge
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import UIKit

/*
Purpose: This enum is to specify the type of the result being displayed.
Weather its a single result or all the results
*/
enum DisplayResultType {
	case singleResult
	case allResult
}

class LocationSearchViewController: UITableViewController {

	private static let cellIdentifier = "locationSearchCellIdentifier"
	var allAnnotations: [ACAnnotation] = []
	var coreDataStack: CoreDataStack?
	var currentSearchController: UISearchController?
	private var dispatchWorkItem: DispatchWorkItem?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.tableHeaderView = UIView()
		self.tableView.tableFooterView = UIView()
		
		let searchController = UISearchController(searchResultsController: nil)
		if #available(iOS 9.1, *) {
			searchController.obscuresBackgroundDuringPresentation = false
		} else {
			// Fallback on earlier versions
		}
		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
		} else {
			navigationItem.titleView = searchController.searchBar
		}
		currentSearchController = searchController
		searchController.loadViewIfNeeded()
		searchController.searchBar.sizeToFit()
		searchController.searchBar.placeholder = "Search on Google Maps"
		searchController.searchResultsUpdater = self
		searchController.searchBar.delegate = self
		searchController.delegate = self
		definesPresentationContext = true
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		currentSearchController?.isActive = true
		currentSearchController?.hidesNavigationBarDuringPresentation = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		currentSearchController?.searchBar.becomeFirstResponder()
	}
	
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
		if allAnnotations.count > 1 {
			return 2
		} else {
        	return 1
		}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			if allAnnotations.count > 1 {
				return 1
			} else {
				return allAnnotations.count
			}
		} else {
			return allAnnotations.count
		}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchViewController.cellIdentifier, for: indexPath)
		
		if allAnnotations.count > 1 && indexPath.section == 0 {
			cell.textLabel?.text = "Display All on Map"
			return cell
		}
		
		let currentLocation = allAnnotations[indexPath.row]
		
		cell.textLabel?.text = currentLocation.title
		
        return cell
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if allAnnotations.count > 0 {
			return ""
		} else {
			return "NO RESULTS"
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44.0
	}

    // MARK: - Navigation

	// there is a lot of repetition here, I would have another method take care of all these cases
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let destinationVC = segue.destination as? SearchResultsViewController {
			
			destinationVC.coreDataStack = self.coreDataStack
			if allAnnotations.count > 1 {
				let selectedIndexPath = self.tableView.indexPathForSelectedRow
				
				if selectedIndexPath?.section == 0 {
					destinationVC.displayType = .allResult
				} else {
					guard let selectedRow = selectedIndexPath?.row else {
						return
					}
					destinationVC.displayType = .singleResult
					destinationVC.selectedAnnotationId = self.allAnnotations[selectedRow].id
				}
				destinationVC.allAnnotations = self.allAnnotations

			} else {
				let selectedIndexPath = self.tableView.indexPathForSelectedRow

				guard let selectedRow = selectedIndexPath?.row else {
					return
				}
				destinationVC.displayType = .singleResult
				destinationVC.selectedAnnotationId = self.allAnnotations[selectedRow].id
				destinationVC.allAnnotations = self.allAnnotations
			}
		}
	}
}


extension LocationSearchViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
	
	// called when keyboard search button pressed
	// The view controller is handling this logic of calling the business layer for getting
	// the search results. If I had more time I would had made some other object handle
	// it in place of the view controller
	func updateSearchResults(for searchController: UISearchController) {
		
		guard let searchText = searchController.searchBar.text, searchText != "" else {
			DispatchQueue.main.async {
				self.allAnnotations = []
				self.tableView.reloadData()
			}
			return
		}
		
		// making the delay to avoid sedning too many request when user is typing fast
		dispatchWorkItem?.cancel()
		
		dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
			self?.searchFortext(searchText)
		})
		
		// using force unwrap here since dispatchWorkItem is gurantted to be present at this point
		DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(250), execute: dispatchWorkItem!)
	}
	
	private func searchFortext(_ searchText: String) {
		
		SearchResultsManager.getSearchResultsForTest(searchText) { [weak self] (results) in
			DispatchQueue.main.async {
				self?.allAnnotations = results
				self?.tableView.reloadData()
			}
		}
	}
	
}


