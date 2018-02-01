//
//  Model.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import Foundation
import UIKit

class Model {
   
   static var shared:Model {
      return (UIApplication.shared.delegate as! AppDelegate).model
   }
   
   var totalResultsCount:Int64 = 0
   lazy var searchResults:[UserData] = [UserData]()
   var currentPage = 1
   var currentSearchText = ""
   let apiCaller = APICaller()
   
   var currentNumberOfUsersFound:Int {
      return self.searchResults.count
   }
   
   var hasMoreUsersToLoad:Bool {
      return currentNumberOfUsersFound < totalResultsCount
   }
   
   //MARK: -
   func searchForUser(name:String, completion:(()->())? ) {
      if currentSearchText != name {
         cleanSearchResults()
         currentSearchText = name
      }
      
      apiCaller.searchForUser(name: currentSearchText) { (result) in
         
         if let users = result.items, !users.isEmpty {
            self.currentPage = self.apiCaller.currentResultsPage
            self.totalResultsCount = result.total_count ?? 0
            self.searchResults.append(contentsOf:users)
         }
         performOnMainThreadAsync {
            completion?()
         }
      }
   }
   
   func cleanSearchResults() {
      totalResultsCount = 0
      currentPage = 1
      currentSearchText = ""
      searchResults.removeAll()
      apiCaller.currentResultsPage = 1
   }
   
   
}

//MARK: -
struct SearchResultResponse:Decodable {
   let total_count:Int64?
   let incomplete_results:Bool?
   let items:[UserData]?
   
   static func createEmpty() -> SearchResultResponse{
      return SearchResultResponse(total_count: nil, incomplete_results: false, items: nil)
   }
}

struct UserData:Decodable {
   let login:String?
   let id:Int?
   let avatar_url:String?
   let url:String?
   
   var userProfilePageUrlString:String? {
      return url
   }
}

enum RequestError:Error {
   
   case resultsLimitReached(message:String)
   case apiRequestsLimitReached(message:String)
   case badURLFormat(message:String)
}
