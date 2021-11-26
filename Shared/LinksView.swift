//
//  LinksView.swift
//
//  Created by Ray Fix on 7/20/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import SwiftUI

struct LinksView: View {
  let segments: [(CGPoint, CGPoint)]
  let modelToView: CGAffineTransform
  
  var body: some View {
    return Path { path in
      for segment in segments {
        path.move(to: segment.0.applying(modelToView))
        path.addLine(to: segment.1.applying(modelToView))
      }
    }.strokedPath(.init(lineWidth: 3))
      .foregroundColor(.gray)
      .opacity(0.5)
  }
}
