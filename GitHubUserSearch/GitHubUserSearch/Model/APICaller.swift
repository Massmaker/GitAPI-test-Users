//
//  APICaller.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import Foundation
import UIKit

typealias searchCompletionBlock = (_ searchResult:SearchResultResponse)->()

typealias imageDownloadBlock = (_ image:UIImage?, _ error:Error?) -> ()

typealias repositoriesDownloadBlock = (_ repos:[RepositoryData]?, _ error:Error?) -> ()

class APICaller {
   static let apiAdress = "https://api.github.com/search/users"
   static let repositoriesAdress = "https://api.github.com/users/<USERNAME>/repos?page=<NUMBER_OF_PAGE>&per_page=20"
   
   static let jsonDecoder = JSONDecoder()
   var currentResultsPage = 1
   var currentRepositoriesPage = 1
   
   var currentUserSearchTask:URLSessionDataTask?
   var currentAvatarLoadingTask:URLSessionDataTask?
   var currentRepositoriesLoadingTask:URLSessionDataTask?
   
   //MARK: - Methods
   //----------------
   func searchForUser(name:String, completion:@escaping searchCompletionBlock) {
      
      let requestAddress = APICaller.apiAdress + "?q=" + name.lowercased() + "&page=\(currentResultsPage)" + "&per_page=30"
      currentResultsPage += 1 //0 or 1 pages return the same values
      guard let url = URL(string:requestAddress) else {
         let errorResponese = SearchResultResponse.createEmpty()
         completion(errorResponese)
         return
      }
      
      currentUserSearchTask?.cancel()
      currentUserSearchTask = nil
      
      currentUserSearchTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
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
      let userRepositiryAddress = APICaller.repositoriesAdress.replacingOccurrences(of: "<USERNAME>", with: userName).replacingOccurrences(of: "<NUMBER_OF_PAGE>", with: "\(currentRepositoriesPage)")
      
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
