import Cocoa

public enum AnchorLocation {
    case topLeft(CGRect = .zero, CGPoint = .zero)
    case topRight(CGRect = .zero, CGPoint = .zero)
    case bottomRight(CGRect = .zero, CGPoint = .zero)
    case bottomLeft(CGRect = .zero, CGPoint = .zero)
    case middleLeft(CGRect = .zero, CGPoint = .zero)
    case middleRight(CGRect = .zero, CGPoint = .zero)
    case middleTop(CGRect = .zero, CGPoint = .zero)
    case middleBottom(CGRect = .zero, CGPoint = .zero)

    public static var locations: [Self] = [.topLeft()] {
        didSet {
            let storedRawLocation = UserDefaults.standard.integer(forKey: "anchorLocation")
            guard let firstLocation = locations.first(where: { $0.rawValue == storedRawLocation }) else { return }
            currentLocation = firstLocation
        }
    }

    private(set) static var currentLocation: AnchorLocation = .topLeft() {
        didSet {
            guard oldValue.rawValue != currentLocation.rawValue else { return }
            UserDefaults.standard.set(currentLocation.rawValue, forKey: "anchorLocation")
        }
    }

    private static var anchorsMap: [AnchorLocation: AnchorWindow] = [:]
    
    private init(rawValue: Int, frame: CGRect, offset: CGPoint) {
        switch rawValue {
        case 0:
            self = .topLeft(frame, offset)
        case 1:
            self = .topRight(frame, offset)
        case 2:
            self = .bottomRight(frame, offset)
        case 3:
            self = .bottomLeft(frame, offset)
        case 4:
            self = .middleLeft(frame, offset)
        case 5:
            self = .middleRight(frame, offset)
        case 6:
            self = .middleTop(frame, offset)
        case 7:
            self = .middleBottom(frame, offset)
        default:
            self = .topLeft(frame, offset)
        }
    }
    
    @discardableResult
    public static func updateCurrentAnchor(withFrame frame: CGRect) -> Self {
        currentLocation = AnchorLocation(rawValue: currentLocation.rawValue, frame: frame, offset: currentLocation.offset)
        return currentLocation
    }
    
    public static func showAnchors(withinScreenFrame screenFrame: CGRect) {
        locations.compactMap {
            AnchorLocation(rawValue: $0.rawValue, frame: currentLocation.windowFrame, offset: $0.offset)
        }.forEach {
            anchorsMap[$0] = AnchorWindow(location: $0, relativeToScreenFrame: screenFrame)
        }
        anchorsMap.values.forEach {
            $0.orderFront(nil)
        }
    }
    
    public static func hideAnchors(storeAnchor: AnchorLocation) {
        anchorsMap.forEach { mapItem in
            mapItem.value.close()
            anchorsMap[mapItem.key] = nil
        }
        currentLocation = storeAnchor
    }
    
    public static func highlightClosestAnchor(
        toPoint: CGPoint,
        size: CGFloat,
        relativeToScreenFrame: CGRect
    ) {
        let location = closestLocation(
            toPoint: toPoint,
            size: size,
            relativeToScreenFrame: relativeToScreenFrame
        )
        anchorsMap.forEach { marker in
            marker.value.highlight(marker.key == location)
        }
    }
    
    public static func closestLocation(
        toPoint: CGPoint,
        size: CGFloat,
        relativeToScreenFrame: CGRect
    ) -> Self {
        let allLocations = locations.map {
            AnchorLocation(rawValue: $0.rawValue, frame: currentLocation.windowFrame, offset: $0.offset)
        }
        let map = allLocations
            .map { location in
                let origin = location.origin(
                    size: size,
                    relativeToScreenFrame: relativeToScreenFrame
                )
                let distance = CGPointDistanceSquared(
                    from: toPoint,
                    to: origin
                )
                return (location: location, distance: distance)
            }
        let sortedPoints = map
            .sorted { (a: (AnchorLocation, CGFloat), b: (AnchorLocation, CGFloat)) in
                a.1 < b.1
            }
        return sortedPoints.first?.0 ?? currentLocation
    }
    
    public func origin(
        size: CGFloat,
        relativeToScreenFrame screenFrame: CGRect
    ) -> CGPoint {
        CGPoint(
            x: round(x(size: size, relativeToScreenFrame: screenFrame)),
            y: round(y(size: size, relativeToScreenFrame: screenFrame))
        )
    }
    
    private func x(
        size: CGFloat,
        relativeToScreenFrame screenFrame: CGRect
    ) -> CGFloat {
        let result: CGFloat
        switch self {
        case let .topLeft(_, offset), let .middleLeft(_, offset):
            result = max(normalizedFrame.minX - size + offset.x, screenFrame.minX)
        case let .topRight(_, offset), let .middleRight(_, offset):
            result = min(normalizedFrame.maxX - size + offset.x, screenFrame.maxX - size)
        case let .bottomRight(_, offset):
            result = min(normalizedFrame.maxX - size + offset.x, screenFrame.maxX - size)
        case let .bottomLeft(_, offset):
            result = max(normalizedFrame.minX - size + offset.x, screenFrame.minX)
        case let .middleTop(_, offset), let .middleBottom(_, offset):
            result = normalizedFrame.midX - size + offset.x
        }
        return result
    }

    private func y(
        size: CGFloat,
        relativeToScreenFrame screenFrame: CGRect
    ) -> CGFloat {
        let result: CGFloat
        switch self {
        case let .topLeft(_, offset), let .topRight(_, offset), let .middleTop(_, offset):
            result = normalizedFrame.maxY - size + offset.y
        case let .bottomRight(_, offset), let .bottomLeft(_, offset), let .middleBottom(_, offset):
            result = max(normalizedFrame.minY - size + offset.y, screenFrame.minY)
        case let .middleLeft(_, offset), let .middleRight(_, offset):
            result = normalizedFrame.midY - size + offset.y
        }
        return result
    }
}

extension AnchorLocation {
    var windowFrame: CGRect {
        switch self {
        case
            let .topLeft(originalFrame, _),
            let .topRight(originalFrame, _),
            let .bottomRight(originalFrame, _),
            let .bottomLeft(originalFrame, _),
            let .middleLeft(originalFrame, _),
            let .middleRight(originalFrame, _),
            let .middleTop(originalFrame, _),
            let .middleBottom(originalFrame, _):
            return originalFrame
        }
    }
}

// MARK: Private

extension AnchorLocation {
    private var rawValue: Int {
        switch self {
        case .topLeft: 0
        case .topRight: 1
        case .bottomRight: 2
        case .bottomLeft: 3
        case .middleLeft: 4
        case .middleRight: 5
        case .middleTop: 6
        case .middleBottom: 7
        }
    }
    
    private var offset: CGPoint {
        switch self {
        case let .topLeft(_, offset):
            return offset
        case let .topRight(_, offset):
            return offset
        case let .bottomRight(_, offset):
            return offset
        case let .bottomLeft(_, offset):
            return offset
        case let .middleLeft(_, offset):
            return offset
        case let .middleRight(_, offset):
            return offset
        case let .middleTop(_, offset):
            return offset
        case let .middleBottom(_, offset):
            return offset
        }
    }
    
    private var normalizedFrame: CGRect {
        var normalizedRect = windowFrame
        let frameOfScreenWithMenuBar = NSScreen.screens[0].frame as CGRect
        normalizedRect.origin.y = frameOfScreenWithMenuBar.height - windowFrame.maxY
        return normalizedRect
    }
}

// MARK: - Hash

extension AnchorLocation: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .topLeft(frame, offset):
            hasher.combine("topLeft")
            hash(frame, offset: offset, into: &hasher)

        case let .topRight(frame, offset):
            hasher.combine("topRight")
            hash(frame, offset: offset, into: &hasher)

        case let .bottomRight(frame, offset):
            hasher.combine("bottomRight")
            hash(frame, offset: offset, into: &hasher)
            
        case let .bottomLeft(frame, offset):
            hasher.combine("bottomLeft")
            hash(frame, offset: offset, into: &hasher)
            
        case let .middleLeft(frame, offset):
            hasher.combine("middleLeft")
            hash(frame, offset: offset, into: &hasher)

        case let .middleRight(frame, offset):
            hasher.combine("middleRight")
            hash(frame, offset: offset, into: &hasher)
            
        case let .middleTop(frame, offset):
            hasher.combine("middleTop")
            hash(frame, offset: offset, into: &hasher)

        case let .middleBottom(frame, offset):
            hasher.combine("middleBottom")
            hash(frame, offset: offset, into: &hasher)
        }
    }
    
    private func hash(_ frame: CGRect, offset: CGPoint, into hasher: inout Hasher) {
        hasher.combine(frame.origin.x)
        hasher.combine(frame.origin.y)
        hasher.combine(frame.size.width)
        hasher.combine(frame.size.height)
        hasher.combine(offset.x)
        hasher.combine(offset.y)
    }
}

private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

private func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    sqrt(CGPointDistanceSquared(from: from, to: to))
}

public extension CGPoint {
    init(x: CGFloat) {
        self.init(x: x, y: 0)
    }
    
    init(y: CGFloat) {
        self.init(x: 0, y: y)
    }
}
