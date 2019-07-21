//
//  Graph.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import Foundation

/// - Pure Model Objects

/// A node represents a vertex of the graph (a dot)
struct Node: Codable, Hashable {
  var id: String
  var group: Int
}

/// A link is the edge between two nodes
struct Link: Codable, Hashable {
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
  
  static func load(filename: String, bundle: Bundle = Bundle.main) throws -> Self {
    guard let url = bundle.url(forResource: filename,
                             withExtension: "json") else {
                              throw Error.fileNotFound(filename)
    }
    let data = try Data(contentsOf: url)
    return try Self(jsonData: data)
  }
}
