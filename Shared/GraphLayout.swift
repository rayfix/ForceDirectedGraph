//
//  ForceDirectedLayout.swift
//
//  Created by Ray Fix on 7/19/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import SwiftUI

/// A way to compute
protocol GraphLayout {
  func update(graph: inout Graph)
}

final class CircularGraphLayout: GraphLayout {
  var startAngle = 0.0
  
  func update(graph: inout Graph) {
    let radius = 0.4
    let center = CGPoint(0.5, 0.5)
    let delta = 2 * CGFloat.pi / CGFloat(graph.nodes.count)
    
    var angle = startAngle
    for index in graph.nodes.indices {
      defer { angle += delta }
      guard !graph.nodes[index].isInteractive else { continue }
      graph.nodes[index].position = center +
      CGPoint(cos(Double(angle)),
              sin(Double(angle))) * radius
      graph.nodes[index].velocity = .zero
      
    }
    startAngle += 0.005
  }
}

/// Implementation of Force-directed Graph Layout
struct ForceDirectedGraphLayout: GraphLayout {
  
  let friction = 0.001
  let springLength = 0.15
  let springConstant = 40.0
  let chargeConstant = 0.05875
  let gravityConstant = 0.025
  
  private func computeSpringForces(source: CGPoint, targets: [CGPoint]) -> CGPoint {
    var accum = CGPoint.zero
    
    for target in targets {
      let delta = target - source
      let length = delta.distance
      guard length > 0 else { continue }
      let unit = delta / length
      accum += unit * (length-springLength) * springConstant
    }
    
    return accum
  }
  
  private func computeRepulsion(at reference: CGPoint, from others: [CGPoint], skipIndex: Int) -> CGPoint {
    
    var accum = CGPoint.zero
    
    for (offset, other) in others.enumerated() {
      guard offset != skipIndex else { continue }
      let diff = reference - other
      guard diff.distanceSquared > 1e-8 else { continue }
      accum += diff / diff.distanceSquared * chargeConstant
    }
    return accum
  }
  
  private func computeCenteringForce(at: CGPoint, center: CGPoint) -> CGPoint {
    let diff = center-at
    let dist = diff.distanceSquared
    return diff / dist * gravityConstant
  }
  
  func update(graph: inout Graph) {
    
    var positions = graph.nodes.map { $0.position }
    var velocities = graph.nodes.map { $0.velocity }
    
    let lookup = Dictionary(uniqueKeysWithValues:
                              graph.nodes.enumerated().map { ($0.element.id, $0.offset) })
    var targets: [[CGPoint]] = Array(repeating: [], count: positions.count)
    
    for link in graph.links {
      guard let source = lookup[link.source],
            let target = lookup[link.target] else { continue }
      targets[source].append(positions[target])
      targets[target].append(positions[source])
    }
    
    var forces = Array(repeating: CGPoint.zero, count: positions.count)
    
    for (offset, position) in positions.enumerated() {
      forces[offset] += computeRepulsion(at: position, from: positions, skipIndex: offset)
      forces[offset] += computeSpringForces(source: position, targets: targets[offset])
    }
    
    // Centering force
    let centering = CGPoint(0.5, 0.5) - (positions.computeAveragePoint() ?? .zero)
    
    // integrate the forces to get velocities
    for (index, velocity) in velocities.enumerated() {
      let new = velocity + forces[index]
      velocities[index] = new * friction
    }
    
    // integrate the velocities to get positions
    for index in positions.indices {
      if graph.nodes[index].isInteractive {
        velocities[index] = .zero
        continue
      }
      positions[index] += velocities[index] + centering
    }
    
    // Copy them in
    for index in positions.indices {
      graph.nodes[index].position = positions[index]
      graph.nodes[index].velocity = velocities[index]
    }
  }
}

