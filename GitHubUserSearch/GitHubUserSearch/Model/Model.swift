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
   
   //search
   
   var totalResultsCount:Int64 = 0
   lazy var searchResults:[UserData] = [UserData]()
   
   lazy var cache = NSCache<AnyObject, AnyObject>()
   
   var currentPage = 1
   var currentSearchText = ""
   let apiCaller = APICaller()
   
   var currentNumberOfUsersFound:Int {
      return self.searchResults.count
   }
   
   var hasMoreUsersToLoad:Bool {
      return currentNumberOfUsersFound < totalResultsCount
   }
   
   //user
   var currentUser:UserData?
   lazy var repositories:[RepositoryData] = [RepositoryData]()
   
   //MARK: - memory
   
   func didReceiveMemoryWarning() {
      cache.removeAllObjects()
      cleanUserSearchResults()
   }
   
   //MARK: -
   func searchForUser(name:String, completion:(()->())? ) {
      if currentSearchText != name {
         cleanUserSearchResults()
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
   
   func cleanUserSearchResults() {
      totalResultsCount = 0
      currentPage = 1
      currentSearchText = ""
      searchResults.removeAll()
      apiCaller.currentResultsPage = 1
   }
   
   func getAvatarForUser(_ user:UserData, completion:imageDownloadBlock?) {
      
      guard let userId = user.id else {
         completion?(nil,RequestError.wrongData(message: "No User ID supplied"))
         return
      }
      
      //--return image from cache
      if let anImageData = cache.object(forKey: "\(userId)" as AnyObject) as? Data,
         let image = UIImage(data:anImageData) {
         print("Avatar from chache")
         completion?(image,nil)
         
         return
      }
      
      //----
      if let anUrl = user.avatarURL {
         print("Loading avatar")
         self.apiCaller.loadUserAvatarOn(anUrl, completion: {[weak self] (image, error) in
            print("Loading avatar finished")
            if let `self` = self {
               if let anImage = image {
                  if let aData = UIImageJPEGRepresentation(anImage, 1.0) {
                     self.cache.setObject(aData as AnyObject, forKey: "\(userId)" as AnyObject)
                  }
                  completion?(anImage, nil)
               }
               else if let anError = error {
                  completion?(nil, anError)
               }
            }
         })
      }
   }
   
   func getCurrentUserRepositories(completion:repositoriesDownloadBlock?) {
      apiCaller.searchForRepositoriesOf(currentUser!.login!, completion: completion)
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
   let avatarURL:String?
   let userProfilePageURLString:String?
   //custon coding key need to be declared in enum
   private enum CodingKeys:String, CodingKey {
      case login
      case id
      case avatarURL = "avatar_url"
      case userProfilePageURLString = "url"
   }
}

struct RepositoryData:Decodable {
   var isPrivate:Bool = false
   var name:String?
   var description:String?
   var html_url:String?

   //custon coding key need to be declared in enum
   private enum CodingKeys: String, CodingKey {
      case isPrivate = "private" // "private" key in JSON will pe mapped to "isPrivate" property of the struct RepositoryData
      case name
      case description
      case html_url
   }
}

enum RequestError:Error {
   
   case resultsLimitReached(message:String)
   case apiRequestsLimitReached(message:String)
   case badURLFormat(message:String)
   case wrongData(message:String)
   case unknownError(message:String?)
   
   func errorDescription() -> String {
      switch self {
         case .unknownError(message: let messageString) :
            return "Unknown: " + (messageString ?? "No message")
         
         case .wrongData(message: let message) :
            return "Wrong Data Format: " + message
         
         case .badURLFormat(message: let message) :
            return "Bad URL: " + message
         
         case .apiRequestsLimitReached(message: let message) :
            return "Request Limit Reached: " + message
         
         case .resultsLimitReached(message: let message) :
            return "Limit of results reached: " + message
//         default:
//            return "Bad Error"
      }
   }
}
