//
//  SearchrResultsController.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import UIKit

class SearchrResultsController: UIViewController {

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
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setupPerPageResultsInModel()
   }
   
   override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
      
      coordinator.animate(alongsideTransition: { _ in
         self.displayLoadingIndicator(false)
      }, completion: { [weak self] _ in
         if let `self` = self {
            self.setupPerPageResultsInModel()
         }
      })
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      searchController?.isActive = false
   }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      model.didReceiveMemoryWarning()
      tableView.reloadData()
      searchController?.isActive = false
   }

   // MARK: -
   
   private func setupPerPageResultsInModel() {
      tableView.setContentOffset(CGPoint.zero, animated: false)
      let rowHeight = tableView.rowHeight
      let frame = tableView.frame
      let perPage = Int(ceil(frame.height / rowHeight)) + 1
      model.setUserSearchResultsPerPage(perPage)
   }
   
   private func setLoading(_ loading:Bool) {
      if (loading) {
         tableView.isUserInteractionEnabled = false
         displayLoadingIndicator(true)
      } else {
         displayLoadingIndicator(false)
         tableView.isUserInteractionEnabled = true
      }
   }
   
   private func displayLoadingIndicator(_ display:Bool) {
      if (display) {
         self.view.bringSubview(toFront: activityIndicator)
         
         UIView.animate(withDuration: 0.25, animations: {
            self.activityIndicator.alpha = 1.0
         })
         activityIndicator.startAnimating()
      } else {
         activityIndicator.stopAnimating()
         UIView .animate(withDuration: 0.25, delay: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.activityIndicator.alpha = 0.0
         }, completion: { _ in
            self.view.sendSubview(toBack: self.activityIndicator)
         })
      }
   }
   // MARK: -
}

extension SearchrResultsController : UITableViewDataSource {
   
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
      
      if let user = model.currentSearchData.items?[safe: indexPath.row] {
         cell.textLabel?.text = user.login ?? "<NAME>"
         cell.detailTextLabel?.text = "\(user.id ?? -1)"
      }
      return cell
   }
}

extension SearchrResultsController: UITableViewDelegate {
   // MARK: - UITableViewDelegate
   
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let count = model.currentNumberOfUsersFound
      if indexPath.row == count - 1, model.hasMoreUsersToLoad {
         
         setLoading(true)
         
         var insets = self.tableView.contentInset
         insets.bottom = 60.0
         tableView.contentInset = insets
         
         model.searchForUser(name: model.currentSearchText, completion: {
            self.tableView.reloadData()//reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.bottom)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {[weak self] in
               if let `self` = self {
                  self.tableView.contentInset = UIEdgeInsets.zero
                  self.setLoading(false)
               }
            })
         })
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      
      if let aUser = model.currentSearchData.items?[safe: indexPath.row] {
         model.currentUser = aUser
         performSegue(withIdentifier: segueToDetails, sender: nil)
      }
   }
}

extension SearchrResultsController:UISearchResultsUpdating {
   
   func updateSearchResults(for searchController: UISearchController) {
      if let aText = searchController.searchBar.text, aText.count > 3 {
         
         setLoading(true)
         tableView.setContentOffset(CGPoint.zero, animated: false)
         
         Model.shared.searchForUser(name: aText.lowercased(), completion: {[weak self] in
            guard let `self` = self else { return }
            
            self.tableView.reloadData()//reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.bottom)
            
            self.setLoading(false)
         })
      }
   }
}
