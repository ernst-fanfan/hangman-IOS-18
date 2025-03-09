//
//  GameplayScene.swift
//  hangman
//
//  Created on 3/9/25.
//

import SpriteKit
import GameplayKit

class GameplayScene: SKScene {
    
    // Game elements
    private var wordLabel: SKLabelNode?
    private var hangmanNode: SKSpriteNode?
    private var letterButtons: [SKSpriteNode] = []
    private var guessesRemainingLabel: SKLabelNode?
    private var backButton: SKSpriteNode?
    
    // Game state
    private var currentWord = ""
    private var hiddenWord = ""
    private var guessedLetters: Set<Character> = []
    private var incorrectGuesses = 0
    private let maxIncorrectGuesses = 6
    
    // Theme
    private let theme = ThemeManager.shared
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    // Called when the theme changes
    func refreshTheme() {
        // Update background
        backgroundColor = theme.backgroundColor
        
        // Update UI elements
        if let backButton = self.backButton {
            backButton.removeFromParent()
            self.backButton = createStyledButton(
                text: "Menu", 
                position: CGPoint(x: 100, y: self.frame.height - 50), 
                size: CGSize(width: 120, height: 40)
            )
            if let newBackButton = self.backButton {
                newBackButton.name = "back_button"
                addChild(newBackButton)
            }
        }
        
        // Update word display
        if let wordLabel = self.wordLabel {
            wordLabel.fontName = theme.bodyFont()
            wordLabel.fontColor = theme.textColor
        }
        
        // Update guesses remaining label
        if let guessesRemainingLabel = self.guessesRemainingLabel {
            guessesRemainingLabel.fontName = theme.bodyFont()
            guessesRemainingLabel.fontColor = theme.textColor
        }
        
        // Update letter buttons if any
        for button in letterButtons {
            button.removeFromParent()
        }
        letterButtons.removeAll()
        
        // TODO: Recreate letter buttons with new theme
        
        // Update game state display
        updateUI()
    }
    
    private func setupGame() {
        // Set background color from theme
        backgroundColor = theme.backgroundColor
        
        // Create back button with modern styling
        backButton = createStyledButton(
            text: "Menu", 
            position: CGPoint(x: 100, y: self.frame.height - 50), 
            size: CGSize(width: 120, height: 40)
        )
        if let backButton = backButton {
            backButton.name = "back_button"
            addChild(backButton)
        }
        
        // Create word display with themed font and color
        wordLabel = SKLabelNode(fontNamed: theme.bodyFont())
        if let wordLabel = wordLabel {
            wordLabel.fontSize = 30
            wordLabel.fontColor = theme.textColor
            wordLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
            wordLabel.horizontalAlignmentMode = .center
            addChild(wordLabel)
        }
        
        // Create guesses remaining label with themed font and color
        guessesRemainingLabel = SKLabelNode(fontNamed: theme.bodyFont())
        if let guessesRemainingLabel = guessesRemainingLabel {
            guessesRemainingLabel.fontSize = 20
            guessesRemainingLabel.fontColor = theme.textColor
            guessesRemainingLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 50)
            guessesRemainingLabel.horizontalAlignmentMode = .center
            addChild(guessesRemainingLabel)
        }
        
        // TODO: Add hangman sprite
        
        // TODO: Add letter buttons
        
        // Start with a placeholder word
        startNewGame()
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
        label.fontSize = size.height * 0.4
        label.fontColor = theme.textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
        
        return button
    }
    
    private func startNewGame() {
        // For now, use a simple word. Later, this could be from a word list
        currentWord = "HANGMAN"
        guessedLetters = []
        incorrectGuesses = 0
        updateUI()
    }
    
    private func updateUI() {
        // Update hidden word display
        hiddenWord = ""
        for letter in currentWord {
            if guessedLetters.contains(letter) {
                hiddenWord.append(letter)
            } else {
                hiddenWord.append("_")
            }
            hiddenWord.append(" ")
        }
        wordLabel?.text = hiddenWord
        
        // Update guesses remaining
        guessesRemainingLabel?.text = "Guesses remaining: \(maxIncorrectGuesses - incorrectGuesses)"
        
        // TODO: Update hangman sprite based on incorrect guesses
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "back_button" {
                // Return to menu
                if let view = self.view {
                    let menuScene = GameScene(size: view.bounds.size)
                    menuScene.scaleMode = .aspectFill
                    view.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
                }
            }
            // TODO: Handle letter button touches
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Game logic updates
    }
}
