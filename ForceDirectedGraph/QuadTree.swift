//
//  QuadTree.swift
//
//  Created by Ray Fix on 7/24/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import Foundation
import CoreGraphics

enum QuadTree<Accumulation> {
  case leaf(CGPoint,Accumulation)
  indirect case node(QuadTree,QuadTree,QuadTree,QuadTree,Accumulation)
}
