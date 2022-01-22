import SwiftUI

struct GraphView: View {
  
  @ObservedObject var viewModel: GraphViewModel
  
  enum Constant {
    static let fontSize = 12.0
  }
  
  @State var isDragging = false
  @State var draggingIndex: Int?
  @State var previous: Date?
  
  var drag: some Gesture {
    let tap = DragGesture(minimumDistance: 0, coordinateSpace: .local)
      .onChanged { drag in
        if isDragging, let index = draggingIndex {
          viewModel.dragNode(at: index, location: drag.location)
        } else {
          draggingIndex = viewModel.hitTest(point: drag.location)
        }
        isDragging = true
      }
      .onEnded { _ in
        if let index = draggingIndex {
          viewModel.stopDraggingNode(at: index)
        }
        isDragging = false
        draggingIndex = nil
      }
    return tap
  }
  
  var body: some View {
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        viewModel.canvasSize = size
        let _ = viewModel.updateSimulation()

        context.transform = viewModel.modelToView
        
        let links = Path { drawing in
          for link in viewModel.linkSegments() {
            drawing.move(to: link.0)
            drawing.addLine(to: link.1)
          }
        }
        
        context.stroke(links, with: .color(white: 0.9),
                       lineWidth: viewModel.linkWidthModel)
        
        for node in viewModel.graph.nodes {
          let ellipse = viewModel.modelRect(node: node)
          context.fill(Path(ellipseIn: ellipse), with: .color(Palette.color(for: node.group)))
        }
        
        if viewModel.showIDs {
          context.transform = .identity
          let font = Font.system(size: Constant.fontSize, weight: .bold)
          for node in viewModel.graph.nodes {
            context.draw(Text(node.id).font(font),
                         at: node.position.applying(viewModel.modelToView))
          }
        }
      }.gesture(drag) // Comment either this line or the line below out and it works.
    }
  }
}




