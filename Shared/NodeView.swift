//
//  NodeView.swift
//
//  Created by Ray Fix on 7/20/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import SwiftUI

struct NodeView: View {
  @Binding var node: Node
  let modelToView: CGAffineTransform
  let showID: Bool
  
  private static let size: CGFloat = 20
  private var color: Color { Palette.color(for: node.group) }
  
  private var drag: some Gesture {
    DragGesture().onChanged { value in
      node.isInteractive = true
      node.velocity = .zero
      node.position = value.location.applying(modelToView.inverted())
    }.onEnded { _ in
      node.isInteractive = false
    }
  }
  
  var body: some View {
    ZStack {
      Circle().size(width: Self.size, height: Self.size)
        .offset(node.position.applying(modelToView)
                - CGPoint(Self.size/2, Self.size/2))
        .foregroundColor(color)
      if showID {
        Text(node.id).position(node.position.applying(modelToView))
      }
    }.gesture(drag)
  }
}
