import SwiftUI

struct GraphView: View {
  
  @ObservedObject var viewModel: GraphViewModel
  
  let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
  
  @State var isDragging = false
  @State var draggingIndex: Int?
  
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
    Canvas { context, size in
      viewModel.canvasSize = size
      let modelToView = viewModel.modelToView
      let scale = 1/modelToView.a
      
      context.transform = modelToView
      
      let links = Path { drawing in
        for link in viewModel.linkSegments() {
          drawing.move(to: link.0)
          drawing.addLine(to: link.1)
        }
      }

      let lineWidth = 2 * scale
      context.stroke(links, with: .color(white: 0.9), lineWidth: lineWidth)
      
      for node in viewModel.graph.nodes {
        let ellipse = viewModel.modelRect(node: node)
        context.fill(Path(ellipseIn: ellipse), with: .color(Palette.color(for: node.group)))
      }
      
      if viewModel.showIDs {
        context.transform = .identity
        let font = Font.system(size: 12, weight: .bold)
        for node in viewModel.graph.nodes {
          context.draw(Text(node.id).font(font),
                       at: node.position.applying(modelToView))
        }
      }
    }.gesture(drag)
      .onReceive(timer) { _ in
        viewModel.updateSimulation()
      }
      .onDisappear {
        timer.upstream.connect().cancel()
      }
  }
}




