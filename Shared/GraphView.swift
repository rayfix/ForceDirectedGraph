//
//  GraphView.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import SwiftUI

struct GraphView: View {
  @ObservedObject var viewModel: GraphViewModel
  
  let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
  var body: some View {
    return ZStack {
      GeometryReader { proxy in
        let modelToView = viewModel.modelToView(size: proxy.size)
        LinksView(segments: viewModel.linkSegments(), modelToView: modelToView)
        ForEach($viewModel.graph.nodes) { node in
          NodeView(node: node,
                   modelToView: modelToView,
                   showID: viewModel.showIDs)
        }
      }
    }.drawingGroup()
      .onReceive(timer) { _ in
        viewModel.updateSimulation()
      }
  }
}


