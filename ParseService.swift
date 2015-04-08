//
//  ParseService.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import Foundation

class ParseService {

  class func uploadImage(image : UIImage, completionHandler : (String) -> Void) {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let imageFile = PFFile(name: "post.jpg", data: imageData)
    let post = PFObject(className: "PostImage")
    post["image"] = imageFile
    
    post.saveInBackgroundWithBlock({ (finished, error) -> Void in
      if error != nil {
        completionHandler(error.localizedDescription)
      } else {
        completionHandler("Uploaded Successfully")
      }
    })
    
  }
}