//
//  ContentView.swift
//  Shared
//
//  Created by Ray Fix on 11/26/21.
//

import SwiftUI

struct ContentView: View {
  
  @StateObject var simple: GraphViewModel = {
    let graph = try! Graph.load(filename: "simple",
                                layout: CircularGraphLayout())
    return GraphViewModel(graph)
  }()
  
  @StateObject var miserables: GraphViewModel = {
    let graph = try! Graph.load(filename: "miserables",
                                layout: CircularGraphLayout())
    return GraphViewModel(graph)
  }()
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink("Simple", destination: GraphControl(viewModel: simple))
        NavigationLink("Miserables", destination: GraphControl(viewModel: miserables))
      }.navigationBarTitle("Graphs")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
.previewInterfaceOrientation(.landscapeLeft)
  }
}
