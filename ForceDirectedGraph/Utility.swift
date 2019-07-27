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

extension Sequence where Element == CGPoint {
  func computeBoundingBox() -> CGRect? {
    let xs = map { $0.x }
    let ys = map { $0.y }
    guard let xmin = xs.min(), let xmax = xs.max(),
      let ymin = ys.min(), let ymax = ys.max() else {
        return nil
    }
    return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
  }
}

extension Collection where Element == CGPoint {
  func computeAveragePoint() -> CGPoint? {
    guard count != 0 else { return nil }
    return reduce(.zero, +) / CGFloat(count)
  }
}

extension CGRect {
  @inlinable var center: CGPoint {
    return CGPoint(midX, midY)
  }
}
