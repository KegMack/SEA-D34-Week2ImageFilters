//
//  TimelineViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    retrievePhotos()
  }

  func retrievePhotos() {
    let query = PFQuery(className: "Post")
    query.findObjectsInBackgroundWithBlock {(data, error) -> Void in
      if error != nil {
        println(error.localizedDescription)
      } else {
        println(data.count)
      }
    }
  }
  
  
  
}
