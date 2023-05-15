import Jinx
import UIKit

private final class BindableGesture: UITapGestureRecognizer {
    private var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        action()
    }
}

struct StatusBarHook: Hook {
    typealias T = @convention(c) (UIView, Selector) -> Void
    
    let cls: AnyClass? = objc_getClass("_UIStatusBar") as? AnyClass
    let sel: Selector = #selector(UIView.layoutSubviews)
    let replace: T = { obj, sel in
        orig(obj, sel)
        
        // Add ghost view
        
        if obj.subviews.count > 1 { obj.subviews.first?.removeFromSuperview() }
        
        let ghostView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        ghostView.frame = obj.frame
        
        obj.insertSubview(ghostView, at: 0)
        obj.subviews.first?.isHidden = false
        obj.subviews.first?.alpha = 0.02
        
        if Preferences.isPerma {
            obj.subviews.last?.alpha = 0
            return
        }
        
        // Add gesture recogniser
        
        if (obj.gestureRecognizers?.count ?? 0) > 3 { obj.removeGestureRecognizer(obj.gestureRecognizers![3]) }
        
        let gesture = BindableGesture {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut,
                animations: { obj.subviews.last?.alpha = CGFloat(Int(obj.subviews.last!.alpha) ^ 1) }
            )
        }
        
        gesture.numberOfTapsRequired = Preferences.tapCount
        obj.addGestureRecognizer(gesture)
    }
}
