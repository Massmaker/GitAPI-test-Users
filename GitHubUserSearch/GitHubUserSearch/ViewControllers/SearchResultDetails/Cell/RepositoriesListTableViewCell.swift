//
//  RepositoryCell.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 2/4/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import UIKit

class RepositoriesListTableViewCell: UITableViewCell {

   @IBOutlet weak var ibTitle:UILabel?
   @IBOutlet weak var ibDesciption:UILabel?
   @IBOutlet weak var ibURLLabel:UILabel?
   
   var isPrivate:Bool = false {
      didSet {
         self.backgroundColor = (isPrivate) ? UIColor.red.withAlphaComponent(0.4) : UIColor.white
      }
   }
   
   var titleText:String? {
      didSet {
         ibTitle?.text = titleText
      }
   }
   
   var urlText:String? {
      didSet {
         ibURLLabel?.text = urlText
      }
   }
   
   var descriptionText:String? {
      didSet {
         ibDesciption?.text = descriptionText
      }
   }
   
   var repository:RepositoryData? {
      didSet {
         if let aRepo = repository {
            isPrivate = aRepo.isPrivate
            titleText = aRepo.name
            descriptionText = aRepo.description
            urlText = aRepo.html_url
         }
      }
   }
}
