//
//  Controls.swift
//
//  Created by Ray Fix on 7/19/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI

struct GraphControl: View {
  var graphView: GraphView
  var body: some View {
    VStack {
      graphView
      HStack {
        Button("Toggle Names") {
          withAnimation {
            self.graphView.model.toggleNames()
          }
        }
        Spacer()
        Button("Toggle Simulation") {
          self.graphView.model.toggleSimulation()
        }
      }.padding()
    }
  }
}

struct TopControl: View {
  var body: some View {
    
    let simple = try! Graph.load(filename: "simple")
    let miserables = try! Graph.load(filename: "miserables")
    
    return NavigationView {
      List {
        NavigationLink("Simple", destination: GraphControl(graphView: GraphView(simple)))
        NavigationLink("Miserables", destination: GraphControl(graphView: GraphView(miserables)))
      }.navigationBarTitle("Graphs")
    }
  }
}
