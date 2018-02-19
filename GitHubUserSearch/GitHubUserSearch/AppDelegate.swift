//
//  AppDelegate.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 1/31/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   var window: UIWindow?

   lazy var model = Model()

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      return true
   }
}
