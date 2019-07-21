//
//  Utility.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import Foundation
import SwiftUI


/// A palette of colors for visualizations
struct Palette {
  static func color(for index: Int) -> Color {
    return colors[index % colors.count]
  }
  private static let colors: [Color] = [.red, .green, .blue, .orange, .yellow, .purple, .pink, .black]
}

func randomScreenPoint() -> CGPoint {
  return CGPoint(x: Int.random(in: 0..<Int(UIScreen.main.bounds.width)),
                 y: Int.random(in: 0..<Int(UIScreen.main.bounds.height)))
}

let screenCenter = CGPoint(UIScreen.main.bounds.size.width,
                           UIScreen.main.bounds.size.height) * 0.5

extension CGPoint {
  @inlinable
  init(_ x: CGFloat, _ y: CGFloat) {
    self.init(x: x, y: y)
  }
  
  @inlinable
  static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(lhs.x+rhs.x, lhs.y+rhs.y)
  }
  
  @inlinable
  static prefix func -(point: CGPoint) -> CGPoint {
    return CGPoint(-point.x, -point.y)
  }
  
  @inlinable
  static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + (-rhs)
  }
  
  @inlinable
  static func +=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
  }
  
  @inlinable
  static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(lhs.x*rhs, lhs.y*rhs)
  }
  
  @inlinable
  static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(lhs.x/rhs, lhs.y/rhs)
  }
  
  @inlinable
  var distanceSquared: CGFloat {
    return x*x + y*y
  }
  
  @inlinable
  var distance: CGFloat {
    return distanceSquared.squareRoot()
  }
}

