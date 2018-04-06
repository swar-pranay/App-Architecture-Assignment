//
//  LocationSearchViewController.swift
//  App Architecture Assignment
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

	var coreDataStack: CoreDataStack?
	var currentSearchController: UISearchController?
	var locationSearchManager: LocationSearchManager?

	private var allAnnotations: [ACAnnotation] = []
	
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
		searchController.searchBar.placeholder = Constant.LocationSearchView.placeHolderText
		definesPresentationContext = true
		
		// setting up the search results delegate
		searchController.searchResultsUpdater = locationSearchManager
		searchController.searchBar.delegate = locationSearchManager
		locationSearchManager?.delegate = self
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

    override func tableView(_ tableView: UITableView,
							numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView,
							cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.LocationSearchView.cellIdentifier, for: indexPath)
		
		if allAnnotations.count > 1 && indexPath.section == 0 {
			cell.textLabel?.text = "Display All on Map"
			return cell
		}
		
		let currentLocation = allAnnotations[indexPath.row]
		
		cell.textLabel?.text = currentLocation.title
		
        return cell
    }

	override func tableView(_ tableView: UITableView,
							titleForHeaderInSection section: Int) -> String? {
		if allAnnotations.count > 0 {
			return ""
		} else {
			return "NO RESULTS"
		}
	}
	
	override func tableView(_ tableView: UITableView,
							heightForHeaderInSection section: Int) -> CGFloat {
		return 44.0
	}

    // MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let destinationVC = segue.destination as? SearchResultsViewController {
			let selectedIndexPath = self.tableView.indexPathForSelectedRow
			if allAnnotations.count > 1 && selectedIndexPath?.section == 0 {
				destinationVC.displayType = .allResult
			} else {
				assignSingleResultDisplayType(destinationVC,
											  forSelectedIndexPath: selectedIndexPath)
			}
			destinationVC.coreDataStack = self.coreDataStack
			destinationVC.allAnnotations = self.allAnnotations
		}
	}
	
	private func assignSingleResultDisplayType(_ viewController: SearchResultsViewController,
											   forSelectedIndexPath indexPath: IndexPath?) {
		guard let selectedRow = indexPath?.row else {
			return
		}
		viewController.displayType = .singleResult
		viewController.selectedAnnotationId = self.allAnnotations[selectedRow].id
	}
	
}

extension LocationSearchViewController: LocationSearchManagerProtocol {
	
	func didUpdateResults(locationSearchManager: LocationSearchManager,
						  annotationResults: [ACAnnotation]) {
		DispatchQueue.main.async {
			self.allAnnotations = annotationResults
			self.tableView.reloadData()
		}
	}
}

