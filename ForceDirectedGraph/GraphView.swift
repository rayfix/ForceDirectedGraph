//
//  GraphView.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI
import Combine

final class GraphViewModel: ObservableObject {
  
  var layoutEngine: GraphLayout = ForceDirectedGraphLayout()
  
  init(_ graph: Graph) {
    // Build NodeViews
    let nodeViewModels = graph.nodes.map { NodeViewModel($0) }
    let nodeViews = nodeViewModels.map { NodeView(viewModel: $0) }
    
    // Build Links
    let nodeViewModelLookup = Dictionary(uniqueKeysWithValues: nodeViewModels.map { ($0.id, $0) } )
    let linkViews: [LinkView] = graph.links.compactMap {
      guard let source = nodeViewModelLookup[$0.source],
        let target = nodeViewModelLookup[$0.target] else {
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
      node.viewModel.showIDs.toggle()
    }
  }
  
  private(set) var nodes: [NodeView]
  private(set) var links: [LinkView]
  private(set) var linkIndices: [[Int]]
  
  var timer: Timer?
  
  func startLayout() {
    
    guard layoutEngine.isIncremental else {
      self.layout()
      return
    }
    
    guard timer == nil else { return }
    
    // a little hack for now
    layoutEngine = RandomGraphLayout()
    layout()
    layoutEngine = ForceDirectedGraphLayout()

    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.objectWillChange.send()
      self.layout()
    }
  }
  
  func stopLayout() {
    timer?.invalidate()
    timer = nil
  }
  
  var isSimulating: Bool { timer != nil }
  
  func toggleSimulation() {
    isSimulating ? stopLayout() : startLayout()
  }
    
  func layout() {
      let positions = nodes.map { $0.viewModel.position }
      let velocities = nodes.map { $0.viewModel.velocity }

      let result = layoutEngine.layout(canvasSize: UIScreen.main.bounds.size,
        positions: positions, velocities: velocities, linkIndices: linkIndices)

      // Update the nodes without updates
      for (index, new) in zip(result.0, result.1).enumerated() {
          guard !nodes[index].viewModel.interactive else { continue }
          nodes[index].viewModel.position = new.0
          nodes[index].viewModel.velocity = new.1
      }
  }
}

struct GraphView: View {
  @ObservedObject var modelView: GraphViewModel
  
  init(_ graph: Graph) {
    self.modelView = GraphViewModel(graph)
  }
  
  var body: some View { 
    ZStack {
        ForEach(modelView.links) { $0 }
        ForEach(modelView.nodes) { $0 }
    }.drawingGroup()
  }
}


