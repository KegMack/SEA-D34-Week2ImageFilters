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
        completionHandler(error!.localizedDescription)
      } else {
        completionHandler("Uploaded Successfully")
      }
    })
  }
  
  class func fetchImageFiles(completionHandler: (data: [PFObject]?, error: String?) -> Void) {
    let query = PFQuery(className: "PostImage")
    query.findObjectsInBackgroundWithBlock {(data, error) -> Void in
      if error != nil {
        completionHandler(data: nil, error: "\(error!.description)")
      } else {
        if let pffiles = data as? [PFObject] {
          completionHandler(data: pffiles, error: nil)
        }
      }
    }
  }
  
  class func fetchImageFromPFObject(pfObject: PFObject, completionHandler: (image: UIImage?, error: String?) -> Void)  {
    if let imageFile = pfObject["image"] as? PFFile {
      imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
        if error == nil {
          if let imageData = data  {
            if let photo = UIImage(data: imageData) {
              NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: photo, error: nil)
              })
            }
          }
        }
        else {
          completionHandler(image: nil, error: "Unable to Fetch Image from Parse")
        }
      })
    }
  }

}