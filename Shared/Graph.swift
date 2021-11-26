//
//  Graph.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import Foundation
import CoreGraphics

/// A node represents a vertex of the graph (a dot)
struct Node: Codable, Identifiable {
  var id: String
  var group: Int
  
  // Normalized space
  var position: CGPoint
  var velocity: CGPoint
  var isInteractive: Bool
  
  enum CodingKeys: CodingKey {
    case id, group, position, velocity
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.group = try container.decode(Int.self, forKey: .group)
    self.position = try container.decodeIfPresent(CGPoint.self, forKey: .position) ?? .zero
    self.velocity = try container.decodeIfPresent(CGPoint.self, forKey: .velocity) ?? .zero
    self.isInteractive = false
  }
}

/// A link is the edge between two nodes
struct Link: Codable {
  var source: String
  var target: String
  var value: Int
}

/// A graph is a collection of nodes and links between the nodes
struct Graph: Codable {
  var nodes: [Node]
  var links: [Link]
}

/// Loading extensions of Graph that are part of the fundamental abstraction
extension Graph {
  enum Error: Swift.Error {
    case fileNotFound(String)
  }
  
  init(jsonData: Data) throws {
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Self.self, from: jsonData)
    self.init(nodes: decoded.nodes, links: decoded.links)
  }
  
  static func load(filename: String, layout: GraphLayout? = nil, bundle: Bundle = Bundle.main) throws -> Self {
    guard let url = bundle.url(forResource: filename,
                             withExtension: "json") else {
                              throw Error.fileNotFound(filename)
    }
    let data = try Data(contentsOf: url)
    var graph = try Self(jsonData: data)
        
    layout?.update(graph: &graph)

    return graph
  }
}
