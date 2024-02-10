import Cocoa

final class AnchorWindow: NSPanel {
    typealias CustomAnchorView = (NSView & AnchorContent)
    
    enum Constants {
        static let size: CGFloat = 16
    }
    
    private lazy var markerView: AnchorView = {
        let frame = CGRect(
            origin: .zero,
            size: .init(
                width: Constants.size,
                height: Constants.size
            )
        )
        return AnchorView(frame: frame)
    }()
    
    private var customAnchorContent: CustomAnchorView?
    
    init(
        location: AnchorLocation,
        customAnchorContent: CustomAnchorView? = nil,
        relativeToScreenFrame screenFrame: CGRect
    ) {
        let size = customAnchorContent?.frame.size.width ?? Constants.size
        super.init(
            contentRect: CGRect(
                origin: location.origin(
                    size: size / 2,
                    relativeToScreenFrame: screenFrame
                ),
                size: .init(width: size, height: size)
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        collectionBehavior = [.ignoresCycle, .canJoinAllSpaces]
        
        isMovableByWindowBackground = false
        hasShadow = false
        level = .floating
        hidesOnDeactivate = false
        isOpaque = true
        backgroundColor = .clear
        isReleasedWhenClosed = false
        contentView = customAnchorContent ?? markerView
    }
    
    func highlight(_ isHighliting: Bool) {
        if let customAnchorContent {
            customAnchorContent.highlight(isHighliting)
        } else {
            markerView.highlight(isHighliting)
        }
    }
}
