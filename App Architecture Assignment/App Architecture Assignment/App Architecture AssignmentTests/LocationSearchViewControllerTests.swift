//
//  LocationSearchViewControllerTests.swift
//  AvenueCodeChallengeTests
//
//  Created by Pranay Swar on 4/2/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import XCTest
@testable import App_Architecture_Assignment

class LocationSearchViewControllerTests: XCTestCase {
	
	var viewController: LocationSearchViewController!
	
    override func setUp() {
		super.setUp()
		
		let storyBoard = UIStoryboard(name: "Main", bundle: nil)
		
		guard let navC = storyBoard.instantiateInitialViewController() as? UINavigationController,
			let vc = navC.topViewController as? LocationSearchViewController else {
			return
		}
		viewController = vc
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testLocationSearchViewControllerInitialization() {
		XCTAssertNotNil(viewController)
	}

	func testLocationSearchController() {
		XCTAssertNotNil(viewController?.view, "LocationSearch view could not be instantiated")
		
		XCTAssertNotNil(viewController?.navigationItem.searchController)
	}
	
	func testTableViewShowsNoResults() {
		XCTAssertNotNil(viewController?.view, "LocationSearch view could not be instantiated")

		let sectionTitle = viewController.tableView(viewController.tableView, titleForHeaderInSection: 0)
		
		XCTAssertEqual(sectionTitle, "NO RESULTS")
	}
	
	func testTableViewShowsBlackSectionHeader() {
		XCTAssertNotNil(viewController?.view, "LocationSearch view could not be instantiated")
		
		viewController.allAnnotations = [ACAnnotation(id: "eyjadyenst", title: "test Annotation", lat: 23.11, long: -23.12)]
		
		let sectionTitle = viewController.tableView(viewController.tableView, titleForHeaderInSection: 0)
		
		XCTAssertEqual(sectionTitle, "")
	}

	func testTableViewSectionNumbersForSingleAnnotation() {
		XCTAssertNotNil(viewController?.view, "LocationSearch view could not be instantiated")
		
		viewController.allAnnotations = [ACAnnotation(id: "eyjadyenst", title: "test Annotation", lat: 23.11, long: -23.12)]
		
		let sections = viewController.numberOfSections(in: viewController.tableView)
		
		XCTAssertEqual(sections, 1)
	}

	func testTableViewSectionNumbersForMultipleAnnotation() {
		XCTAssertNotNil(viewController?.view, "LocationSearch view could not be instantiated")
		
		viewController.allAnnotations = [ACAnnotation(id: "eyjadyenst", title: "test Annotation", lat: 23.11, long: -23.12),
		ACAnnotation(id: "arteewstlsr", title: "test Annotation", lat: 23.23, long: -23.11)]
		
		let zeroSection = viewController.numberOfSections(in: viewController.tableView)

		XCTAssertEqual(zeroSection, 2)
	}

	
}
