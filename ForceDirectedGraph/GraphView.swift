//
//  GraphView.swift
//  ForceDirectedGraph
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI
import Combine

final class NodeViewModel: BindableObject {
  var willChange = PassthroughSubject<NodeViewModel, Never>()
  
  var id: String
  var group: Int
  var color: Color { Palette.color(for: group) }
  var interactive = false {
    willSet {
      willChange.send(self)
    }
  }
  var position: CGPoint {
    willSet {
      willChange.send(self)
    }
  }
  var showIDs = false {
    willSet {
      willChange.send(self)
    }
  }
  var velocity: CGPoint
  
  init(_ node: Node) {
    id = node.id
    group = node.group
    position = randomScreenPoint()
    velocity = .zero
  }
  
  static let size: CGFloat = 20
}

struct NodeView: View, Identifiable {
  @ObjectBinding var node: NodeViewModel
  
  var id: String {
    node.id
  }
  
  var body: some View {
    let drag = DragGesture().onChanged { value in
      self.node.interactive = true
      self.node.position = value.location
      self.node.velocity = .zero
    }.onEnded { _ in
      self.node.interactive = false
    }
    return ZStack {
      Circle().size(width: NodeViewModel.size, height: NodeViewModel.size)
        .offset(node.position-CGPoint(NodeViewModel.size/2, NodeViewModel.size/2))
        .foregroundColor(node.color)
      if node.showIDs {
        Text(node.id).position(node.position)
      }
    }.gesture(drag)
  }
}

struct LinkView: View, Identifiable {
  @ObjectBinding var source: NodeViewModel
  @ObjectBinding var target: NodeViewModel
  
  var id: String { "\(source.id)-\(target.id)" }
  
  var body: some View {
    return Path { path in
      path.move(to: source.position)
      path.addLine(to: target.position)
    }.strokedPath(.init(lineWidth: 4))
      .foregroundColor(.gray)
      .opacity(0.5)
  }
}

final class GraphModel: BindableObject {
  
  var willChange = PassthroughSubject<GraphModel,Never>()
  
  init(_ graph: Graph) {
    // Build NodeViews
    let nodeModels = graph.nodes.map { NodeViewModel($0) }
    let nodeViews = nodeModels.map { NodeView(node: $0) }
    
    // Build Links
    let nodeLookup = Dictionary(uniqueKeysWithValues: nodeViews.map { ($0.node.id, $0.node) } )
    let linkViews: [LinkView] = graph.links.compactMap {
      guard let source = nodeLookup[$0.source], let target = nodeLookup[$0.target] else {
        return nil
      }
      return LinkView(source: source, target: target)
    }
    
    // Now some data structure for quicker simulation
    let nodeIndexLookup = Dictionary(uniqueKeysWithValues: graph.nodes.enumerated().map { ($0.1.id, $0.0) })
    
    var linkIndices = Array(repeating: [Int](), count: graph.nodes.count)
    
    for link in graph.links {
      guard let a = nodeIndexLookup[link.source],
        let b = nodeIndexLookup[link.target] else {
          continue
      }
      linkIndices[a].append(b)
      linkIndices[b].append(a)
    }
    
    self.nodes = nodeViews
    self.links = linkViews
    self.linkIndices = linkIndices
  }
  
  func toggleNames() {
    for node in nodes {
      node.node.showIDs.toggle()
    }
  }
  
  private(set) var nodes: [NodeView]
  private(set) var links: [LinkView]
  private(set) var linkIndices: [[Int]]
  
  var timer: Timer?
  
  func startSimulation() {
    
    guard timer == nil else { return }
    
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      //withAnimation(.linear) {
      self.simulation(steps: 5)
      self.willChange.send(self)
      //}
    }
  }
  
  func stopSimulation() {
    timer?.invalidate()
    timer = nil
  }
  
  var isSimulating: Bool { timer != nil }
  
  func toggleSimulation() {
    isSimulating ? stopSimulation() : startSimulation()
  }
    
  func simulation(steps: Int) {
      let positions = nodes.map { $0.node.position }
      let velocities = nodes.map { $0.node.velocity }

      let sim = ForceDirectedGraph()
      let result = sim.compute(positions: positions, velocities: velocities,
                               gravityCenter: screenCenter, linkIndices: linkIndices,
                               steps: steps)

      // Update the nodes without updates
      for (index, new) in zip(result.0, result.1).enumerated() {
          guard !nodes[index].node.interactive else { continue }
          nodes[index].node.position = new.0
          nodes[index].node.velocity = new.1
      }
  }
}

struct GraphView: View {
  @ObjectBinding var model: GraphModel
  
  init(_ graph: Graph) {
    self.model = GraphModel(graph)
  }
  
  var body: some View {
    let graph = ZStack {
      ForEach(model.links) { $0 }
      ForEach(model.nodes) { $0 }
    }
    return graph.drawingGroup()
  }
}


