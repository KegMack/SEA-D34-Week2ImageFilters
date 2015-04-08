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
    self.title = "Timeline"
    retrievePhotos()
  }

  func retrievePhotos() {
    let query = PFQuery(className: "Post")
    query.findObjectsInBackgroundWithBlock { ([AnyObject]!, error) -> Void in
      if error != nil {
        println(error.localizedDescription)
      }
    }
  }
  
  
  
}
