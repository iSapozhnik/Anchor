import Cocoa

final class SelectedShapeShapeLayer: CAShapeLayer {
    convenience init(frame _: NSRect) {
        self.init()
        fillColor = NSColor.white.cgColor
        shadowOffset = .init(width: 0, height: -1)
        shadowColor = NSColor.black.cgColor
        shadowOpacity = 0.2
        shadowRadius = 0
    }
    
    override var frame: CGRect {
        didSet {
            let bounds = NSRect(origin: .zero, size: frame.size)
            path = CGPath(ellipseIn: bounds, transform: nil)
            shadowPath = path
        }
    }
}

final class AnchorView: NSView, AnchorContent {
    private enum Constants {
        static let lineWidth: CGFloat = 4
        static let animationDuration: CFTimeInterval = 0.15
    }
    
    private var isHighliting = false {
        didSet {
            guard oldValue != isHighliting else { return }
            if isHighliting {
                hoverIn()
            } else {
                hoverOut()
            }
        }
    }

    private lazy var selectedMarkerLayer = SelectedShapeShapeLayer(frame: .zero)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonSetup()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let outerRect = NSRect(origin: .zero, size: dirtyRect.size)
        
        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalIn: outerRect)
        NSColor.controlAccentColor.setFill()
        ovalPath.fill()
    }
    
    private func commonSetup() {
        wantsLayer = true
        layer?.masksToBounds = true

        let innerRect = frame.insetBy(dx: Constants.lineWidth, dy: Constants.lineWidth)
        selectedMarkerLayer.frame = innerRect

        layer?.addSublayer(selectedMarkerLayer)
        selectedMarkerLayer.transform = CATransform3DMakeScale(0, 0, 1)
    }
    
    func highlight(_ isHighliting: Bool) {
        self.isHighliting = isHighliting
    }
    
    private func hoverIn() {
        selectedMarkerLayer.removeAllAnimations()

        let scale = CASpringAnimation.scale(from: 0, to: 1)
        CATransition.makeWithoutAnimation {
            selectedMarkerLayer.transform = CATransform3DIdentity
        }
        selectedMarkerLayer.add(scale, forKey: "in_scale")
    }
    
    private func hoverOut() {
        selectedMarkerLayer.removeAllAnimations()

        let scale = CABasicAnimation.scale(from: 1, to: 0, duration: Constants.animationDuration)
        CATransition.makeWithoutAnimation {
            selectedMarkerLayer.transform = CATransform3DMakeScale(0, 0, 1)
        }
        selectedMarkerLayer.add(scale, forKey: "out_scale")
    }
}
