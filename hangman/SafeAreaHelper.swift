//
//  SafeAreaHelper.swift
//  hangman
//
//  Created on 3/10/25.
//

import UIKit
import SpriteKit

/// A helper class to manage safe area insets for proper positioning of UI elements
/// to avoid the Dynamic Island and other system UI elements
class SafeAreaHelper {
    static let shared = SafeAreaHelper()
    
    // Safe area insets from the view controller
    private(set) var topInset: CGFloat = 0
    private(set) var bottomInset: CGFloat = 0
    private(set) var leftInset: CGFloat = 0
    private(set) var rightInset: CGFloat = 0
    
    // Additional padding beyond the safe area for better visual spacing
    let additionalPadding: CGFloat = 10
    
    // Update safe area insets from the view controller's safe area
    func updateSafeAreaInsets(from viewController: UIViewController) {
        // Get the safe area insets from the view controller
        let safeArea = viewController.view.safeAreaInsets
        
        topInset = safeArea.top + additionalPadding
        bottomInset = safeArea.bottom + additionalPadding
        leftInset = safeArea.left + additionalPadding
        rightInset = safeArea.right + additionalPadding
        
        // Ensure minimum safe area even on devices without notches
        if topInset < 20 {
            topInset = 20 // Minimum top safe area
        }
        
        // Print safe area information for debugging
        print("Safe area insets: top=\(topInset), bottom=\(bottomInset), left=\(leftInset), right=\(rightInset)")
    }
    
    // Calculate a safe Y position from the top of the screen
    func safeTopPosition(in scene: SKScene, offset: CGFloat = 0) -> CGFloat {
        return scene.frame.height - topInset - offset
    }
    
    // Calculate a safe Y position from the bottom of the screen
    func safeBottomPosition(in scene: SKScene, offset: CGFloat = 0) -> CGFloat {
        return bottomInset + offset
    }
    
    // Calculate a safe X position from the left edge of the screen
    func safeLeftPosition(in scene: SKScene, offset: CGFloat = 0) -> CGFloat {
        return leftInset + offset
    }
    
    // Calculate a safe X position from the right edge of the screen
    func safeRightPosition(in scene: SKScene, offset: CGFloat = 0) -> CGFloat {
        return scene.frame.width - rightInset - offset
    }
    
    // Get the safe area frame within the provided scene
    func safeAreaFrame(in scene: SKScene) -> CGRect {
        return CGRect(
            x: leftInset,
            y: bottomInset,
            width: scene.frame.width - leftInset - rightInset,
            height: scene.frame.height - topInset - bottomInset
        )
    }
    
    // Adjust an existing point to respect safe areas if needed
    func adjustPointForSafeArea(point: CGPoint, in scene: SKScene) -> CGPoint {
        var newPoint = point
        
        // Check if the point is too close to the top edge
        if point.y > scene.frame.height - topInset {
            newPoint.y = scene.frame.height - topInset
        }
        
        // Check if the point is too close to the bottom edge
        if point.y < bottomInset {
            newPoint.y = bottomInset
        }
        
        // Check if the point is too close to the left edge
        if point.x < leftInset {
            newPoint.x = leftInset
        }
        
        // Check if the point is too close to the right edge
        if point.x > scene.frame.width - rightInset {
            newPoint.x = scene.frame.width - rightInset
        }
        
        return newPoint
    }
}

// Notification for when safe area insets change
extension Notification.Name {
    static let safeAreaInsetsDidChange = Notification.Name("SafeAreaInsetsDidChange")
}
