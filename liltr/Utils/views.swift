import SwiftUI

struct BlurWindow: NSViewRepresentable {
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        //
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow

        return view
    }
}

class SizeHolder {
    private var base: Float

    var fontSize: Float {
        return base * 6
    }

    var iconSize: Float {
        return fontSize * 1.5
    }

    var radiusSize: Float {
        return fontSize / 2
    }

    var innerGapSize: Float {
        return base
    }

    var gapSize: Float {
        return base * 2
    }

    var outerGapSize: Float {
        return base * 4
    }

    init(base: Float? = nil) {
        self.base = base ?? 2
    }
}
