//
//  GameScene.swift
//  hangman
//
//  Created by Ernst Fanfan on 3/9/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Menu elements
    private var titleLabel: SKLabelNode?
    private var playButton: SKSpriteNode?
    private var howToPlayButton: SKSpriteNode?
    private var gameCenterButton: SKSpriteNode?
    
    // Theme
    private let theme = ThemeManager.shared
    
    override func didMove(to view: SKView) {
        setupMenu()
        
        // Register for Game Center authentication notifications
        NotificationCenter.default.addObserver(self, 
                                             selector: #selector(gameCenterAuthenticationChanged), 
                                             name: .gameCenterAuthenticationChanged, 
                                             object: nil)
        
        // Register for safe area changes
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(safeAreaInsetsDidChange),
                                             name: .safeAreaInsetsDidChange,
                                             object: nil)
    }
    
    @objc func safeAreaInsetsDidChange() {
        // Refresh the UI when safe area insets change
        repositionElements()
    }
    
    private func repositionElements() {
        // Reposition title
        if let titleLabel = self.titleLabel {
            let safeY = SafeAreaHelper.shared.safeTopPosition(in: self, offset: self.frame.height * 0.25)
            titleLabel.position = CGPoint(x: self.frame.midX, y: safeY)
        }
        
        // Remove and recreate buttons with updated positions
        if let playButton = self.playButton {
            playButton.removeFromParent()
        }
        
        if let howToPlayButton = self.howToPlayButton {
            howToPlayButton.removeFromParent()
        }
        
        if let gameCenterButton = self.gameCenterButton {
            gameCenterButton.removeFromParent()
        }
        
        // Recreate buttons
        setupButtons()
        
        // Update instruction panel if visible
        if let panel = self.childNode(withName: "instructions_panel") as? SKSpriteNode {
            panel.removeFromParent()
            showInstructions()
        }
    }
    
    @objc func gameCenterAuthenticationChanged() {
        // Update Game Center button based on authentication status
        if GameCenterManager.shared.isAuthenticated {
            // Show Game Center button if authenticated
            if gameCenterButton == nil {
                setupGameCenterButton()
            }
        } else {
            // Hide Game Center button if not authenticated
            gameCenterButton?.removeFromParent()
            gameCenterButton = nil
        }
    }
    
    // Called when the theme changes
    func refreshTheme() {
        // Update background
        backgroundColor = theme.backgroundColor
        
        // Update title
        titleLabel?.fontName = theme.titleFont()
        titleLabel?.fontColor = theme.primaryColor
        
        // Update buttons - recreate them with new theme
        if let playButton = self.playButton {
            playButton.removeFromParent()
        }
        
        if let howToPlayButton = self.howToPlayButton {
            howToPlayButton.removeFromParent()
        }
        
        if let gameCenterButton = self.gameCenterButton {
            gameCenterButton.removeFromParent()
        }
        
        // Recreate buttons with new theme
        setupButtons()
        
        // Update instruction panel if visible
        if let panel = self.childNode(withName: "instructions_panel") as? SKSpriteNode {
            panel.removeFromParent()
            showInstructions()
        }
    }
    
    private func setupMenu() {
        // Set background color from theme
        backgroundColor = theme.backgroundColor
        
        // Create title
        titleLabel = SKLabelNode(fontNamed: theme.titleFont())
        if let titleLabel = titleLabel {
            titleLabel.text = "Hangman"
            titleLabel.fontSize = 50
            titleLabel.fontColor = theme.primaryColor
            
            // Position respecting the top safe area (Dynamic Island)
            let safeY = SafeAreaHelper.shared.safeTopPosition(in: self, offset: self.frame.height * 0.25)
            titleLabel.position = CGPoint(x: self.frame.midX, y: safeY)
            
            addChild(titleLabel)
        }
        
        // Set up buttons
        setupButtons()
    }
    
    private func setupButtons() {
        // Calculate safe center Y position, slightly higher than center to account for bottom safe area
        let safeYCenter = self.frame.midY + SafeAreaHelper.shared.bottomInset * 0.5
        
        // Create play button with modern styling
        let playButtonSize = CGSize(width: 200, height: 60)
        playButton = createStyledButton(
            text: "Play",
            position: CGPoint(x: self.frame.midX, y: safeYCenter),
            size: playButtonSize
        )
        if let playButton = playButton {
            addChild(playButton)
        }
        
        // Create how to play button with modern styling
        let howToPlayButtonSize = CGSize(width: 200, height: 60)
        howToPlayButton = createStyledButton(
            text: "How To Play",
            position: CGPoint(x: self.frame.midX, y: safeYCenter - 80),
            size: howToPlayButtonSize
        )
        if let howToPlayButton = howToPlayButton {
            addChild(howToPlayButton)
        }
        
        // Add Game Center button if authenticated
        if GameCenterManager.shared.isAuthenticated {
            setupGameCenterButton()
        }
    }
    
    private func setupGameCenterButton() {
        // Calculate safe center Y position, slightly higher than center
        let safeYCenter = self.frame.midY + SafeAreaHelper.shared.bottomInset * 0.5
        
        // Create Game Center button with modern styling
        let gameCenterButtonSize = CGSize(width: 200, height: 60)
        gameCenterButton = createStyledButton(
            text: "Game Center",
            position: CGPoint(x: self.frame.midX, y: safeYCenter - 160),
            size: gameCenterButtonSize
        )
        if let gameCenterButton = gameCenterButton {
            gameCenterButton.name = "game_center"
            addChild(gameCenterButton)
        }
    }
    
    private func createStyledButton(text: String, position: CGPoint, size: CGSize) -> SKSpriteNode {
        let cornerRadius: CGFloat = 12
        
        // Create the button container
        let button = SKSpriteNode(color: .clear, size: size)
        button.position = position
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        // Create the rounded background
        let background = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        background.fillColor = theme.secondaryColor
        background.strokeColor = .clear
        background.zPosition = 0
        button.addChild(background)
        
        // Create the label
        let label = SKLabelNode(fontNamed: theme.buttonFont())
        label.text = text
        label.fontSize = 20
        label.fontColor = theme.textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "play" {
                // Transition to gameplay scene
                if let view = self.view {
                    let gameplayScene = GameplayScene(size: view.bounds.size)
                    gameplayScene.scaleMode = .aspectFill
                    view.presentScene(gameplayScene, transition: SKTransition.fade(withDuration: 0.5))
                }
            } else if node.name == "how_to_play" {
                // Show instructions (for now just display text)
                showInstructions()
            } else if node.name == "close_instructions" {
                // Close the instructions panel
                self.childNode(withName: "instructions_panel")?.removeFromParent()
            } else if node.name == "game_center" {
                // Show Game Center dashboard
                if let viewController = self.view?.window?.rootViewController {
                    GameCenterManager.shared.showGameCenter(presentingViewController: viewController)
                }
            }
        }
    }
    
    private func showInstructions() {
        // Remove previous instruction nodes if any
        self.childNode(withName: "instructions_panel")?.removeFromParent()
        
        // Get safe area frame to size and position the panel properly
        let safeFrame = SafeAreaHelper.shared.safeAreaFrame(in: self)
        
        // Create the panel background with rounded corners - size it to fit within safe area
        let panelSize = CGSize(
            width: safeFrame.width * 0.9,
            height: safeFrame.height * 0.8
        )
        let cornerRadius: CGFloat = 20
        
        // Position panel in the center of the safe area
        let panelY = safeFrame.midY + (SafeAreaHelper.shared.bottomInset - SafeAreaHelper.shared.topInset) / 2
        
        // Panel container
        let panel = SKSpriteNode(color: .clear, size: panelSize)
        panel.position = CGPoint(x: safeFrame.midX, y: panelY)
        panel.zPosition = 10
        panel.name = "instructions_panel"
        
        // Panel background with rounded corners
        let background = SKShapeNode(rectOf: panelSize, cornerRadius: cornerRadius)
        background.fillColor = theme.backgroundColor.withAlphaComponent(0.95)
        background.strokeColor = theme.secondaryColor
        background.lineWidth = 2
        background.zPosition = -1
        panel.addChild(background)
        
        // Add a subtle shadow
        if let shadowPath = background.path {
            let shadow = SKShapeNode(path: shadowPath)
            shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
            shadow.strokeColor = .clear
            shadow.position = CGPoint(x: 4, y: -4)
            shadow.zPosition = -2
            panel.addChild(shadow)
        }
        
        // Add instruction title
        let instructions = SKLabelNode(fontNamed: theme.titleFont())
        instructions.text = "How to Play Hangman"
        instructions.fontSize = 28
        instructions.fontColor = theme.textColor
        instructions.position = CGPoint(x: 0, y: panel.size.height * 0.35)
        panel.addChild(instructions)
        
        // Add game rules with proper formatting
        let rules = SKLabelNode(fontNamed: theme.bodyFont())
        rules.text = "1. Guess the hidden word letter by letter\n2. Each incorrect guess adds to the hangman\n3. Solve the word before the hangman is complete"
        rules.fontSize = 18
        rules.fontColor = theme.textColor
        rules.position = CGPoint(x: 0, y: 0)
        rules.numberOfLines = 5
        rules.preferredMaxLayoutWidth = panel.size.width * 0.8
        panel.addChild(rules)
        
        // Add close button with modern styling
        let closeButtonSize = CGSize(width: 120, height: 45)
        let closeButton = SKShapeNode(rectOf: closeButtonSize, cornerRadius: 12)
        closeButton.fillColor = theme.primaryColor
        closeButton.strokeColor = .clear
        closeButton.position = CGPoint(x: 0, y: -panel.size.height * 0.35)
        closeButton.name = "close_instructions"
        panel.addChild(closeButton)
        
        let closeLabel = SKLabelNode(fontNamed: theme.buttonFont())
        closeLabel.text = "Close"
        closeLabel.fontSize = 18
        closeLabel.fontColor = SKColor.white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        
        addChild(panel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
