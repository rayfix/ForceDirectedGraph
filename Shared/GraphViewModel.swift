//
//  GraphViewModel.swift
//  ForceDirectedGraph (iOS)
//
//  Created by Ray Fix on 11/26/21.
//

import Combine
import CoreGraphics.CGAffineTransform

enum Layout: Int, Hashable {
  case circular, forceDirected
    
  func makeEngine() -> GraphLayout {
    switch self {
    case .circular:
      return CircularGraphLayout()
    case .forceDirected:
      return ForceDirectedGraphLayout()
    }
  }
}


final class GraphViewModel: ObservableObject {
  
  @Published var graph: Graph
  @Published var isSimulating = true
  @Published var showIDs = false
  @Published var layout = Layout.circular {
    didSet {
      layoutEngine = layout.makeEngine()
    }
  }
  private var layoutEngine: GraphLayout = CircularGraphLayout()
  
  init(_ graph: Graph) {
    self.graph = graph
  }
  
  func modelToView(size: CGSize) -> CGAffineTransform {
    let minDimension = min(size.width, size.height)
    
    return CGAffineTransform.identity
      .translatedBy(x: (size.width - minDimension) * 0.5,
                    y: (size.height - minDimension) * 0.5)
      .scaledBy(x: minDimension, y: minDimension)
    
  }
  
  func linkSegments() -> [(CGPoint, CGPoint)] {
    let lookup = Dictionary(uniqueKeysWithValues:
                              graph.nodes.map { ($0.id, $0.position) })
    return graph.links.compactMap { link in
      guard let source = lookup[link.source],
            let target = lookup[link.target] else {
              return nil
            }
      return (source, target)
    }
  }
  
  func updateSimulation() {
    guard isSimulating else { return }
    layoutEngine.update(graph: &graph)
  }
}
