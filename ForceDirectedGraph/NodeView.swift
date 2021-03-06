//
//  NodeView.swift
//
//  Created by Ray Fix on 7/20/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import Foundation

import SwiftUI
import Combine

final class NodeViewModel: BindableObject {
  var willChange = PassthroughSubject<Void, Never>()
  
  var id: String
  var group: Int
  var color: Color { Palette.color(for: group) }
  var interactive = false {
    willSet {
      willChange.send()
    }
  }
  var position: CGPoint {
    willSet {
      willChange.send()
    }
  }
  var showIDs = false {
    willSet {
      willChange.send()
    }
  }
  var velocity: CGPoint
  
  init(_ node: Node) {
    id = node.id
    group = node.group
    position = .zero
    velocity = .zero
  }
  
  static let size: CGFloat = 20
}

struct NodeView: View, Identifiable {
  @ObjectBinding var viewModel: NodeViewModel
  
  var id: String {
    viewModel.id
  }
  
  var body: some View {
    let drag = DragGesture().onChanged { value in
      self.viewModel.interactive = true
      self.viewModel.position = value.location
      self.viewModel.velocity = .zero
    }.onEnded { _ in
      self.viewModel.interactive = false
    }
    return ZStack {
      Circle().size(width: NodeViewModel.size, height: NodeViewModel.size)
        .offset(viewModel.position-CGPoint(NodeViewModel.size/2, NodeViewModel.size/2))
        .foregroundColor(viewModel.color)
      if viewModel.showIDs {
        Text(viewModel.id).position(viewModel.position)
      }
    }.gesture(drag)
  }
}
