import QuartzCore

extension CASpringAnimation {
    static func scale(from: Any?, to: Any?) -> CASpringAnimation {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.stiffness = 300
        animation.damping = 14
        animation.mass = 0.9
        animation.initialVelocity = 0.0
        animation.beginTime = CACurrentMediaTime() + 0
        animation.fromValue = from
        animation.toValue = to
        animation.isRemovedOnCompletion = true
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return animation
    }
}

extension CABasicAnimation {
    static func scale(from: Any?, to: Any?, duration: CFTimeInterval? = nil) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.beginTime = CACurrentMediaTime() + 0
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration ?? 0.3
        animation.isRemovedOnCompletion = true
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return animation
    }
}

extension CATransition {
    static func makeWithoutAnimation(_ action: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        action()
        CATransaction.commit()
    }
}
