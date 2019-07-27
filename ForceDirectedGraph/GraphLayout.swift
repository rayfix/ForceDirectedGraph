//
//  ForceDirectedLayout.swift
//
//  Created by Ray Fix on 7/19/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI


/// A way to compute
protocol GraphLayout {
  
  var isIncremental: Bool { get }
  
  func layout(canvasSize: CGSize,
              positions p: [CGPoint],
              velocities v: [CGPoint],
              linkIndices: [[Int]]) -> ([CGPoint], [CGPoint])
}


struct CircularGraphLayout: GraphLayout {
  var isIncremental: Bool { false }
  
  func layout(canvasSize: CGSize, positions p: [CGPoint], velocities v: [CGPoint],
              linkIndices: [[Int]]) -> ([CGPoint], [CGPoint]) {
    
    let radius = min(canvasSize.width, canvasSize.height) * 0.2
    let center = CGPoint(canvasSize.width * 0.5, canvasSize.height * 0.5)
    let delta = 2 * CGFloat.pi / CGFloat(p.count)
    
    var angle = CGFloat(0)
    let positions = p.map { (_: CGPoint) -> CGPoint in
      let newPos = center + CGPoint(cos(angle), sin(angle)) * radius
      angle += delta
      return newPos
    }
    let velocity = v.map { _ in CGPoint.zero }
    
    return (positions,velocity)
  }
}

/// A random layout
struct RandomGraphLayout: GraphLayout {
  var isIncremental: Bool { false }
  
  func layout(canvasSize: CGSize,
              positions p: [CGPoint],
              velocities v: [CGPoint],
              linkIndices: [[Int]]) -> ([CGPoint], [CGPoint]) {
    
    let positions = p.map { _ in
      CGPoint(CGFloat.random(in: 0..<canvasSize.width),
              CGFloat.random(in: 0..<canvasSize.height))
      
    }
    let velocity = v.map { _ in CGPoint.zero }
    return (positions, velocity)
  }
}

/// Implementation of Force-directed Graph Layout
struct ForceDirectedGraphLayout: GraphLayout {
  
  var isIncremental: Bool { true }
  
  var viscosity = CGFloat(20)
  var friction = CGFloat(0.7)
  var gravityRejectionDistanceSquared = CGFloat(25000)
  var springLength = CGFloat(55)
  var springConstant = CGFloat(0.05)
  var chargeConstant = CGFloat(50)
  var gravityConstant = CGFloat(200)
  var steps = 5
  
  private func computeSpringForces(source: CGPoint, targets: [CGPoint]) -> CGPoint {
    var accum = CGPoint.zero
    
    for target in targets {
      let delta = target - source
      let length = delta.distance
      let unit = delta / (length + 0.00001)
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
      accum += diff / (diff.distanceSquared + 0.00000001) * chargeConstant
    }
    return accum
  }
  
  private func computeCenteringForce(at: CGPoint, center: CGPoint) -> CGPoint {
    let diff = center-at
    let dist = diff.distanceSquared
    return dist > gravityRejectionDistanceSquared  ? diff / dist * gravityConstant : .zero
  }
  
  func layout(canvasSize: CGSize,
              positions p: [CGPoint],
              velocities v: [CGPoint],
              linkIndices: [[Int]]) -> ([CGPoint], [CGPoint]) {
    
    
    var positions = p
    var velocities = v
    
    for _ in 1...steps {
      var forces = Array(repeating: CGPoint.zero, count: positions.count)
      
      for (offset, position) in positions.enumerated() {
        forces[offset] += computeRepulsion(at: position, from: positions, skipIndex: offset)
        forces[offset] += computeSpringForces(source: position, targets: linkIndices[offset].map { positions[$0] })
      }
      
      // Centering force
      let center = CGPoint(canvasSize.width * 0.5, canvasSize.height * 0.5) - (positions.computeAveragePoint() ?? .zero)
        
      // integrate the forces to get velocities
      for (index, v) in velocities.enumerated() {
        let nv = v + forces[index]
        let d = nv.distance
        velocities[index] = nv.distance > viscosity ? nv / d * viscosity : nv * friction
      }
      
      // integrate the velocities to get positions
      for index in positions.indices {
        positions[index] += velocities[index] + center
      }
    }
    
    return (positions, velocities)
  }
}
