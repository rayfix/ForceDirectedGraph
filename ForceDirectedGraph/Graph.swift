//
//  Models.swift
//  ForceDirectedGraph
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import Foundation

/// - Pure Model Objects
struct Node: Codable, Hashable {
    var id: String
    var group: Int
    
    init(id: String, group: Int) {
        self.id = id
        self.group = group
    }
}

struct Link: Codable, Hashable {
    var source: String
    var target: String
    var value: Int
}

final class Graph: Codable {
    var nodes: [Node]
    var links: [Link]
    
    init(jsonData: Data) throws {
        let decoder = JSONDecoder()
        let g = try decoder.decode(Self.self, from: jsonData)
        (nodes, links) = (g.nodes, g.links)
    }
    
    enum Error: Swift.Error {
        case fileNotFound(String)
    }
    
    static func load(filename: String) throws -> Self {
        guard let url = Bundle.main.url(forResource: filename,
                                        withExtension: "json") else {
            throw Error.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        return try Self(jsonData: data)
    }
}
