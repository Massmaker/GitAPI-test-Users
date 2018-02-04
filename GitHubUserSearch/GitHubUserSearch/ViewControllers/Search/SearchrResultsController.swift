//
//  SearchrResultsController.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import UIKit

class SearchrResultsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   var searchController:UISearchController?
   @IBOutlet var tableView:UITableView!
   
   lazy var activityIndicator:UIActivityIndicatorView = {
      let aView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
      aView.translatesAutoresizingMaskIntoConstraints = false
      
      self.view.addSubview(aView)
      
      aView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
      aView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
      aView.widthAnchor.constraint(equalToConstant:100.0).isActive = true
      aView.heightAnchor.constraint(equalToConstant:100.0).isActive = true
      aView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
      aView.layer.cornerRadius = 4.0
      aView.alpha = 0.0
      
      return aView
   }()
   
   var model:Model {
      return Model.shared
   }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
      
      searchController = UISearchController(searchResultsController: nil)
      searchController?.searchResultsUpdater = self
      searchController?.dimsBackgroundDuringPresentation = false
      self.navigationItem.searchController = searchController
      self.navigationItem.hidesSearchBarWhenScrolling = false
      
      //tableView.keyboardDismissMode = .interactive //when a finger reaches top edge of the kyeboard
      tableView.keyboardDismissMode = .onDrag
    }

   override func viewWillDisappear(_ animated: Bool) {
      searchController?.isActive = false
      super.viewWillDisappear(animated)
   }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      model.didReceiveMemoryWarning()
      self.tableView.reloadData()
      self.searchController?.isActive = false
   }

    // MARK: - UITableViewDatasource

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Model.shared.currentNumberOfUsersFound
    }

   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

      if let user = model.searchResults[safe: indexPath.row] {
         cell.textLabel?.text = user.login ?? "<NAME>"
         cell.detailTextLabel?.text = "\(user.id ?? -1)"
      }
        return cell
    }
    

   //MARK: - UITableViewDelegate
   
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let count = model.currentNumberOfUsersFound
      if indexPath.row == count - 1, model.hasMoreUsersToLoad {
         self.setLoading(true)
         model.currentPage += 1
         model.searchForUser(name: model.currentSearchText, completion: {
            var yOffset = self.tableView.contentOffset.y
            yOffset += 40.0
            self.tableView.setContentOffset(CGPoint(x:0, y:yOffset), animated: true)
            
            self.tableView.reloadData()//reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.bottom)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
               self.setLoading(false)
            })
            //DispatchQueue.main.asyncAfter(deadline: .now + 1.0) { self.setLoading(false) }
         })
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      
      //TODO: implement transfering to User Details view controller
      if let aUser = model.searchResults[safe: indexPath.row] {
         model.currentUser = aUser
         self.performSegue(withIdentifier: segueToDetails, sender: nil)
      }
   }
   
   //MARK: -
   private func setLoading(_ loading:Bool) {
      if (loading) {
         self.tableView.isUserInteractionEnabled = false
         displayLoadingIndicator(true)
      }
      else {
         displayLoadingIndicator(false)
         self.tableView.isUserInteractionEnabled = true
      }
   }
   
   private func displayLoadingIndicator(_ display:Bool) {
      if (display) {
         self.view.bringSubview(toFront: activityIndicator)
         
         UIView.animate(withDuration: 0.25, animations: {
            self.activityIndicator.alpha = 1.0
         })
         activityIndicator.startAnimating()
      }
      else {
         activityIndicator.stopAnimating()
         UIView .animate(withDuration: 0.25, delay: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.activityIndicator.alpha = 0.0
         }, completion:{ _ in
            self.view.sendSubview(toBack: self.activityIndicator)
         })
      }
   }
   //MARK: -
}

extension SearchrResultsController:UISearchResultsUpdating {
   
   func updateSearchResults(for searchController: UISearchController) {
      if let aText = searchController.searchBar.text, aText.count > 3 {
         
         print("searching : \(aText)")
         setLoading(true)
         Model.shared.searchForUser(name: aText.lowercased(), completion: {[weak self] in
            guard let `self` = self else { return }
            
            self.tableView.reloadData()//reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.bottom)
            
            self.setLoading(false)
         })
      }
   }
}
