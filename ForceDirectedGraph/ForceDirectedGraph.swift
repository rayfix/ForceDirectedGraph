//
//  ForceDirectedGraph.swift
//
//  Created by Ray Fix on 7/19/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI

struct ForceDirectedGraph {
  
  var viscosity = CGFloat(20)
  var friction = CGFloat(0.7)
  var gravityRejectionDistanceSquared = CGFloat(25000)
  var springLength = CGFloat(55)
  var springConstant = CGFloat(0.05)
  var chargeConstant = CGFloat(50)
  var gravityConstant = CGFloat(200)
  
  private func computeSpringForces(source: CGPoint, targets: [CGPoint]) -> CGPoint {
    var accum = CGPoint.zero
    
    for target in targets {
      let delta = target - source
      let length = delta.distance
      let unit = delta / length
      accum += unit * (length-springLength) * springConstant
    }
    
    guard !accum.x.isNaN, !accum.y.isNaN else {
      return .zero
    }
    
    return accum
  }
  
  private func computeRepulsion(at reference: CGPoint, from others: [CGPoint], skipIndex: Int) -> CGPoint {
    
    var accum = CGPoint.zero
    
    for (offset, other) in others.enumerated() {
      guard offset != skipIndex else { continue }
      let diff = reference - other
      accum += diff / diff.distanceSquared * chargeConstant
    }
    return accum
  }
  
  private func computeCenteringForce(at: CGPoint, center: CGPoint) -> CGPoint {
    let diff = center-at
    let dist = diff.distanceSquared
    return dist > gravityRejectionDistanceSquared  ? diff / dist * gravityConstant : .zero
  }
  
  func compute(positions p: [CGPoint], velocities v: [CGPoint], gravityCenter: CGPoint,
               linkIndices: [[Int]], steps: Int) -> ([CGPoint], [CGPoint]) {
    
    var positions = p
    var velocities = v
    
    for _ in 1...steps {
      var forces = Array(repeating: CGPoint.zero, count: positions.count)
      
      for (offset, position) in positions.enumerated() {
        forces[offset] += computeRepulsion(at: position, from: positions, skipIndex: offset)
        forces[offset] += computeSpringForces(source: position, targets: linkIndices[offset].map { positions[$0] })
        forces[offset] += computeCenteringForce(at: position, center: gravityCenter)
      }
      
      // integrate the forces to get velocities
      for (index, v) in velocities.enumerated() {
        let nv = v + forces[index]
        let d = nv.distance
        velocities[index] = nv.distance > viscosity ? nv / d * viscosity : nv * friction
      }
      
      // integrate the velocities to get positions
      for index in positions.indices {
        positions[index] += velocities[index]
      }
    }
    
    return (positions, velocities)
  }
}
