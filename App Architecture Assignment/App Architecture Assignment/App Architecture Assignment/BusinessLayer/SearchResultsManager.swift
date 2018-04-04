//
//  SearchResultsManager.swift
//  App Architecture Assignment
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation


class SearchResultsManager {
	
	/*
	Purpose:  Manager will make the API call and get the raw response, serialize it into data
	objects which can be passed around the app
	Parameters: text: the search text
	completion: the completion block called when the the method has to return ACAnnotation array
	Return Value: Void
	*/
	public static func getSearchResultsForTest(_ text: String, withCompletion completion: @escaping ([ACAnnotation]) -> Void) {
		
		NetworkManager.getLocationForSearchText(text) { (returnedData) in
			guard let result = returnedData else {
				completion([])
				return
			}
			
			let jsonDecoder = JSONDecoder()
			do {
				let annotationResult = try jsonDecoder.decode(SearchResults.self, from: result)
				completion(annotationResult.results)
			} catch {
				print("Error in decoding results")
				completion([])
			}
		}
	}
}


struct SearchResults: Decodable {
	var results: [ACAnnotation]
}
