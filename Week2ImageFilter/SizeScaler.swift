//
//  SizeScaler.swift
//  Week2ImageFilter
//
//  Created by User on 4/10/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import Foundation

class SizeScaler {

  var minimumLength: CGFloat?
  var maximumLength: CGFloat?
  var originalSize: CGSize!
  let defaultDimension: CGFloat = 100
  
  init(min: CGFloat, max: CGFloat, size: CGSize) {
    self.minimumLength = min
    self.maximumLength = max
    self.originalSize = size
  }
  
  init() {
    self.originalSize = CGSizeMake(self.defaultDimension, self.defaultDimension)
  }
  
  
  func sizeSquareToScale(scale: CGFloat) -> CGSize {
    var newLength: CGFloat = self.originalSize.width * scale
    if self.minimumLength != nil {
      newLength = max(newLength, self.minimumLength!)
    }
    if self.maximumLength != nil {
      newLength = min(newLength, self.maximumLength!)
    }
    return CGSizeMake(newLength, newLength)
  }
  
  
}