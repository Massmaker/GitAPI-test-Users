//
//  APICaller.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import Foundation
import UIKit

typealias searchCompletionBlock = (_ searchResult:UserSearchResultResponse)->()

typealias imageDownloadBlock = (_ image:UIImage?, _ error:Error?) -> ()

typealias repositoriesDownloadBlock = (_ repos:[RepositoryData]?, _ error:Error?) -> ()

class APICaller {
   
   static let apiUsersAddress = "https://api.github.com/search/users"
   
   static let apiRepositoriesAddress = "https://api.github.com/users/<USERNAME>/repos"//?page=<NUMBER_OF_PAGE>&per_page=<USERS_PER_PAGE>"
   
   static let jsonDecoder = JSONDecoder()
   var usersPerPage = 20
   //var currentRepositoriesPage = 1
   
   var currentUserSearchTask:URLSessionDataTask?
   var currentAvatarLoadingTask:URLSessionDataTask?
   var currentRepositoriesLoadingTask:URLSessionDataTask?
   
   //MARK: - Methods
   //----------------
   func searchForUser(name:String, page:Int, completion:@escaping searchCompletionBlock) {
      
      let aPage = page + 1 //0 or 1 pages return the same values
      
      let requestAddress = APICaller.apiUsersAddress + "?q=" + name.lowercased() + "&page=\(aPage)" + "&per_page=\(usersPerPage)"
      
      guard let url = URL(string:requestAddress) else {
         let errorResponese = UserSearchResultResponse.createEmpty()
         completion(errorResponese)
         return
      }
      
      currentUserSearchTask?.cancel()
      currentUserSearchTask = nil
      
      currentUserSearchTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
         print("current Users Page: \(aPage)")
         if let aData = responseData {
            do {
               let responseResult:UserSearchResultResponse = try APICaller.jsonDecoder.decode(UserSearchResultResponse.self, from: aData)
               
                  completion(responseResult)
               
            } catch let error as DecodingError{
               print(error)
               let errorResponse = UserSearchResultResponse.createEmpty()
               
                  completion(errorResponse)
               
            } catch let error {
              print(error)
               let errorResponse = UserSearchResultResponse.createEmpty()
               
                  completion(errorResponse)
               
            }
         }
      }
      
      currentUserSearchTask?.resume()
      
   }
   
   //-------
   func loadUserAvatarOn(_ url:String, completion:imageDownloadBlock? ) {
      guard let imageUrl = URL(string:url) else {
         completion?(nil, RequestError.badURLFormat(message: "Could not creste an URL from avater URL string"))
         return
      }
      
      currentAvatarLoadingTask?.cancel()
      
      currentAvatarLoadingTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
         if let errorLoading = error {
            performOnMainThreadAsync {
               completion?(nil, errorLoading)
            }
            return
         }
         
         if let imageData = data {
            if let anImage = UIImage(data:imageData) {
               performOnMainThreadAsync {
                  //completion?(nil, RequestError.unknownError(message: "Test debug error"))
                  completion?(anImage, nil)
               }
            }
            else {
               performOnMainThreadAsync {
                  completion?(nil, RequestError.wrongData(message: "Could not convert data to image"))
               }
            }
            return
         }
         
         if let aResponse = response as? HTTPURLResponse {
             performOnMainThreadAsync {
               completion?(nil, RequestError.apiRequestsLimitReached(message: "UnknownError: \n Code: \(aResponse.statusCode) \n"))
               return
            }
         }
         
         performOnMainThreadAsync {
            completion?(nil, RequestError.unknownError(message:nil))
         }
      }
      
      currentAvatarLoadingTask?.resume()
   }
   
   //------
   func searchForRepositoriesOf(_ userName:String, completion:repositoriesDownloadBlock?) {
      //repositoriesAdress
      let userRepositiryAddress = APICaller.apiRepositoriesAddress.replacingOccurrences(of: "<USERNAME>", with: userName)//.replacingOccurrences(of: "<NUMBER_OF_PAGE>", with: "\(currentRepositoriesPage)")
      
      guard let reposURL = URL(string:userRepositiryAddress) else {
         completion?(nil, RequestError.badURLFormat(message: "Could not create URL with username\" \(userName) \""))
         return
      }
      
      currentRepositoriesLoadingTask?.cancel()
      
      currentRepositoriesLoadingTask = URLSession.shared.dataTask(with: reposURL, completionHandler: { (data, response, error) in
         if let reposData = data {
            do{
               let repos:[RepositoryData] = try APICaller.jsonDecoder.decode([RepositoryData].self, from: reposData)
               performOnMainThreadAsync {
                  completion?(repos, nil)
               }
            }
            catch let tryError {
               print(tryError)
               performOnMainThreadAsync {
                  completion?(nil, tryError)
               }
            }
         }
         else if let anError = error {
            performOnMainThreadAsync {
               completion?(nil, anError)
            }
         }
         else {
            performOnMainThreadAsync {
               completion?(nil, RequestError.unknownError(message: "Unknown error while loading repository data."))
            }
         }
      })
      currentRepositoriesLoadingTask?.resume()
   }
}
