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
   
   //MARK: - UITableViewDataSource
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return model.repositories.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let aCell = tableView.dequeueReusableCell(withIdentifier: DetailsViewController.repositoryCellReuseIdentifier, for: indexPath)
      
      return aCell
   }

}
