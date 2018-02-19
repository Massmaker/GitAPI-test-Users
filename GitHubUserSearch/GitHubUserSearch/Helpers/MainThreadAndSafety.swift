//
//  MainThreadSafety.swift
//  GitHubUserSearch
//
//  Created by Ivan Iavorin on 2/1/18.
//  Copyright © 2018 Ivan Iavorin. All rights reserved.
//

import Foundation

func performOnMainThreadAsync(block:@escaping (() -> Void )) {
   DispatchQueue.main.async {
      block()
   }
}

extension Collection {
   
   /// Returns the element at the specified index iff it is within bounds, otherwise nil.
   subscript (safe index: Index) -> Iterator.Element? {
      return indices.contains(index) ? self[index] : nil
   }
}
