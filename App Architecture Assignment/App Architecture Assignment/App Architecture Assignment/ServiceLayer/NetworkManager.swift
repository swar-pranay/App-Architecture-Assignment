//
//  NetworkManager.swift
//  AvenueCodeChallenge
//
//  Created by Pranay Swar on 4/1/18.
//  Copyright © 2018 Pranay Swar. All rights reserved.
//

import Foundation

class NetworkManager {
	
	private static let searchPath = "http://maps.googleapis.com/maps/api/geocode/"
	private static let parameters = "json?address=%@&sensor=false"
	
	/*
	Purpose: is to make the API call and return the response in raw data
	Parameters: text: the search text
				completion: the completion block called when the the method has to return data
	Return Value: Void
	*/
	public static func getLocationForSearchText(_ text: String, withCompletion completion: @escaping (Data?) -> Void) {
		
		guard let textSearchString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
			print("Search string has invlid characters")
			return
		}
		let filledParameters = String(format: parameters, textSearchString)
		
		let completeUrlString = searchPath + filledParameters
		
		guard let url = URL(string: completeUrlString) else {
			print("Error in constructing URL")
			return
		}
		
		let urlReq = URLRequest(url: url)
		
		URLSession.shared.dataTask(with: urlReq) { (data, urlResponse, error) in
			
			// if more time, will do more with urlresponse and error to investigate why did it really failed
			if error == nil {
				completion(data)
			} else {
				completion(nil)
			}
		}.resume()
	}
	
	
	
}
