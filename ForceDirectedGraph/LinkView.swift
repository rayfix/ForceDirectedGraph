//
//  LinkView.swift
//
//  Created by Ray Fix on 7/20/19.
//  Copyright © 2019 Ray Fix. All rights reserved.
//

import SwiftUI
import Combine

struct LinkView: View, Identifiable {
  @ObservedObject var source: NodeViewModel
  @ObservedObject var target: NodeViewModel
  
  var id: String { "\(source.id)-\(target.id)" }
  
  var body: some View {
    return Path { path in
      path.move(to: source.position)
      path.addLine(to: target.position)
    }.strokedPath(.init(lineWidth: 4))
      .foregroundColor(.gray)
      .opacity(0.5)
  }
}
