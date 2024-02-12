import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct MidBarView: View {
    var showButton: Bool
    var isLoading: Bool
    var onSwap: () -> Void
    var onDrag: (_ height: CGFloat) -> Void = { _ in }

    private let height = CGFloat(25)

    var body: some View {
        ZStack {
            Divider()

            Rectangle()
                .fill(.clear)
                .cursor(.resizeUpDown)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            onDrag(value.translation.height)
                        }
                )

            if showButton {
                if isLoading {
                    ProgressView()
                        .scaleEffect(CGSize(width: 0.5, height: 0.5))
                } else {
                    Button {
                        onSwap()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .background(Color.backgroundColor)
                }
            }
        }.frame(height: height)
    }

}

#Preview("MidBar isLoading", traits: .fixedLayout(width: 300, height: 200)) {
    MidBarView(showButton: true, isLoading: true, onSwap: {})
}

#Preview("MidBar", traits: .fixedLayout(width: 300, height: 200)) {
    MidBarView(showButton: true, isLoading: false, onSwap: {})
}
