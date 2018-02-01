//
//  APICaller.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import Foundation


typealias searchCompletionBlock = (_ searchResult:SearchResultResponse)->()

class APICaller {
   static let apiAdress = "https://api.github.com/search/users"
   
   static let jsonDecoder = JSONDecoder()
   var currentResultsPage = 1
   
   func searchForUser(name:String, completion:@escaping searchCompletionBlock) {
      
      let requestAddress = APICaller.apiAdress + "?q=" + name.lowercased() + "&page=\(currentResultsPage)" + "&per_page=20"
      currentResultsPage += 1 //0 or 1 pages return the same values
      guard let url = URL(string:requestAddress) else {
         let errorResponese = SearchResultResponse.createEmpty()
         completion(errorResponese)
         return
      }
      
      
      let dataTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
//         if let `response` = response {
            //print(response)
            if let aData = responseData {
               do {
                  let responseResult:SearchResultResponse = try APICaller.jsonDecoder.decode(SearchResultResponse.self, from: aData)
                  
                     completion(responseResult)
                  
               } catch let error as DecodingError{
                  print(error)
                  let errorResponse = SearchResultResponse.createEmpty()
                  
                     completion(errorResponse)
                  
               } catch let error {
                 print(error)
                  let errorResponse = SearchResultResponse.createEmpty()
                  
                     completion(errorResponse)
                  
               }
            }
//         }
      }
      dataTask.resume()
   }
}
