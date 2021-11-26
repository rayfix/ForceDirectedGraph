//
//  GraphControl.swift
//
//  Created by Ray Fix on 7/19/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import SwiftUI

struct GraphControl: View {
  @ObservedObject var viewModel: GraphViewModel
  var body: some View {
    VStack {
      GraphView(viewModel: viewModel)
      HStack {
        Picker("Type", selection: $viewModel.layout) {
          Text("Circular").tag(Layout.circular)
          Text("Force Directed").tag(Layout.forceDirected)
        }.pickerStyle(.segmented)
        Toggle(isOn: $viewModel.showIDs) {
          Text("Names")
        }
      }.padding()
    }
  }
}
