//
//  DetailsViewController.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import UIKit



class DetailsViewController: UIViewController, UITableViewDataSource {
   
   
   @IBOutlet weak var ibNickName: UILabel!
   @IBOutlet weak var ibAavatar:UIImageView!
   @IBOutlet weak var ibAvatarLoadingIndicator:UIActivityIndicatorView!
   @IBOutlet weak var ibUserId: UILabel!
   @IBOutlet weak var ibRepositoriesListTableView: UITableView!
   
   static let repositoryCellReuseIdentifier = "RepositoryCell"
   
   lazy var model = Model.shared
   
   lazy var user:UserData? = model.currentUser
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Do any additional setup after loading the view.
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      ibAvatarLoadingIndicator.stopAnimating()
      
      if let aUser = model.currentUser {
         
         if let userId = aUser.id {
            ibUserId.text = "ID: " + "\(userId)"
         }
         else {
            ibUserId.text = "ID: unknown"
         }
         
         ibNickName.text = aUser.login
         
         ibAvatarLoadingIndicator.startAnimating()
         model.getAvatarForUser(aUser, completion: { [weak self] (image, error) in
            if let `self` = self {
               self.ibAavatar.image = image
               self.ibAvatarLoadingIndicator.stopAnimating()
               if let anError = error {
                  self.displayErrorAlertWith(anError)
               }
            }
         })
      }
   }
   
   func displayErrorAlertWith(_ error:Error) {
      var message = "Unknow error occured"
      
      if let customError = error as? RequestError {
         message = customError.errorDescription()
      }
      else {
         let systemError = error as NSError
         message = systemError.localizedDescription
      }
      
      let alertVC = UIAlertController.init(title: "Warning", message: message, preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
      
      self.present(alertVC, animated: true, completion: nil)
      
   }
   
   //MARK: - UITableViewDataSource
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return model.repositories.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let aCell = tableView.dequeueReusableCell(withIdentifier: DetailsViewController.repositoryCellReuseIdentifier, for: indexPath)
      
      return aCell
   }
   
   //view controller end
}
