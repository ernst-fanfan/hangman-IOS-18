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
    
    override func didMove(to view: SKView) {
        setupMenu()
    }
    
    private func setupMenu() {
        // Set background color
        backgroundColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        
        // Create title
        titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        if let titleLabel = titleLabel {
            titleLabel.text = "Hangman"
            titleLabel.fontSize = 50
            titleLabel.fontColor = SKColor.white
            titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 120)
            addChild(titleLabel)
        }
        
        // Create play button
        playButton = createButton(text: "Play", position: CGPoint(x: self.frame.midX, y: self.frame.midY))
        if let playButton = playButton {
            addChild(playButton)
        }
        
        // Create how to play button
        howToPlayButton = createButton(text: "How To Play", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 80))
        if let howToPlayButton = howToPlayButton {
            addChild(howToPlayButton)
        }
    }
    
    private func createButton(text: String, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0), size: CGSize(width: 200, height: 60))
        button.position = position
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = text
        label.fontSize = 22
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
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
            }
        }
    }
    
    private func showInstructions() {
        // Remove previous instruction nodes if any
        self.childNode(withName: "instructions_panel")?.removeFromParent()
        
        // Create instruction panel
        let panel = SKSpriteNode(color: SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9), 
                                 size: CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7))
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        panel.zPosition = 10
        panel.name = "instructions_panel"
        
        // Add instruction text
        let instructions = SKLabelNode(fontNamed: "Arial")
        instructions.text = "How to Play Hangman"
        instructions.fontSize = 24
        instructions.fontColor = SKColor.white
        instructions.position = CGPoint(x: 0, y: panel.size.height * 0.35)
        panel.addChild(instructions)
        
        // Add game rules
        let rules = SKLabelNode(fontNamed: "Arial")
        rules.text = "1. Guess the hidden word letter by letter\n2. Each incorrect guess adds to the hangman\n3. Solve the word before the hangman is complete"
        rules.fontSize = 18
        rules.fontColor = SKColor.white
        rules.position = CGPoint(x: 0, y: 0)
        rules.numberOfLines = 5
        rules.preferredMaxLayoutWidth = panel.size.width * 0.8
        panel.addChild(rules)
        
        // Add close button
        let closeButton = SKSpriteNode(color: SKColor.red, size: CGSize(width: 120, height: 40))
        closeButton.position = CGPoint(x: 0, y: -panel.size.height * 0.35)
        closeButton.name = "close_instructions"
        
        let closeLabel = SKLabelNode(fontNamed: "Arial")
        closeLabel.text = "Close"
        closeLabel.fontSize = 18
        closeLabel.fontColor = SKColor.white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        
        panel.addChild(closeButton)
        addChild(panel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
