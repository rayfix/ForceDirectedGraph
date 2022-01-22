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
  
  enum Constant {
    static let nodeSize = 20.0
    static let fontSize = 12.0
    static let linkWidth = 2.0
  }
  
  var graph: Graph
  @Published var showIDs = false
  
  var canvasSize: CGSize = .zero {
    didSet {
      let minDimension = min(canvasSize.width, canvasSize.height)
      
      modelToView = CGAffineTransform.identity
        .translatedBy(x: (canvasSize.width - minDimension) * 0.5,
                      y: (canvasSize.height - minDimension) * 0.5)
        .scaledBy(x: minDimension, y: minDimension)
      viewToModel = modelToView.inverted()
      
    }
  }

  var layout = Layout.circular {
    didSet {
      layoutEngine = layout.makeEngine()
    }
  }
  private var layoutEngine: GraphLayout = CircularGraphLayout()
  
  init(_ graph: Graph) {
    self.graph = graph
  }
  
  private(set) var viewToModel: CGAffineTransform = .identity
  private(set) var modelToView: CGAffineTransform = .identity
  
  func modelRect(node: Node) -> CGRect {
    let inset = -Constant.nodeSize / (modelToView.a * 2)
    return CGRect(origin: node.position, size: .zero)
      .insetBy(dx: inset, dy: inset)
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
    layoutEngine.update(graph: &graph)
  }
}
