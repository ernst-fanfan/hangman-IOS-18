//
//  ThemeManager.swift
//  hangman
//
//  Created on 3/9/25.
//

import UIKit
import SpriteKit

enum AppTheme {
    case light
    case dark
}

class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: AppTheme {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        } else {
            return .light
        }
    }
    
    // MARK: - Colors
    
    // Background colors
    var backgroundColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Light gray
        case .dark:
            return SKColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark gray
        }
    }
    
    // Primary colors - used for main UI elements
    var primaryColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.0, green: 0.75, blue: 0.75, alpha: 1.0) // Teal #00BFBF
        case .dark:
            return SKColor(red: 0.0, green: 0.65, blue: 0.65, alpha: 1.0) // Darker Teal #00A5A5
        }
    }
    
    // Secondary colors - used for secondary UI elements
    var secondaryColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0) // Light gray #E5E5EA
        case .dark:
            return SKColor(red: 0.28, green: 0.28, blue: 0.29, alpha: 1.0) // Dark gray #48484A
        }
    }
    
    // Text colors
    var textColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark gray #1C1C1E
        case .dark:
            return SKColor.white
        }
    }
    
    // Accent colors - used for highlighting and important elements
    var accentColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0) // Brighter Teal #00D9D9
        case .dark:
            return SKColor(red: 0.0, green: 0.75, blue: 0.75, alpha: 1.0) // Bright Teal #00BFBF
        }
    }
    
    // Success color
    var successColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 0.30, green: 0.85, blue: 0.39, alpha: 1.0) // iOS Green #4CD964
        case .dark:
            return SKColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0) // iOS Green #34C759
        }
    }
    
    // Error color
    var errorColor: SKColor {
        switch currentTheme {
        case .light:
            return SKColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) // iOS Red #FF3B30
        case .dark:
            return SKColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0) // iOS Red #FF453A
        }
    }
    
    // MARK: - Fonts
    
    // Title font - large text for headers
    func titleFont(size: CGFloat = 34) -> String {
        return "SFProDisplay-Bold"
    }
    
    // Body font - regular text
    func bodyFont(size: CGFloat = 17) -> String {
        return "SFProText-Regular"
    }
    
    // Button font - used for buttons
    func buttonFont(size: CGFloat = 17) -> String {
        return "SFProText-Semibold"
    }
    
    // MARK: - UI Elements
    
    // Creates a modern button with rounded corners
    func createButton(text: String, size: CGSize) -> SKSpriteNode {
        let cornerRadius: CGFloat = 12
        
        // Create the button background with rounded corners
        let button = SKSpriteNode(color: secondaryColor, size: size)
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        // Create a shape node for the rounded rectangle
        let roundedRect = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        roundedRect.fillColor = secondaryColor
        roundedRect.strokeColor = SKColor.clear
        button.addChild(roundedRect)
        
        // Create the label for the button
        let label = SKLabelNode(fontNamed: buttonFont())
        label.text = text
        label.fontSize = size.height * 0.4
        label.fontColor = textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    // Updates the theme based on the system appearance
    func updateThemeForTraitCollection(_ traitCollection: UITraitCollection) {
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeManagerThemeDidChange")
    static let gameCenterAuthenticationChanged = Notification.Name("GameCenterAuthenticationChanged")
}
