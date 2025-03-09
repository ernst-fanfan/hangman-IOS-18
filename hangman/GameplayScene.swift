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
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    private func setupGame() {
        // Set background color
        backgroundColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        
        // Create back button
        backButton = createButton(text: "Menu", position: CGPoint(x: 100, y: self.frame.height - 50), size: CGSize(width: 120, height: 40))
        if let backButton = backButton {
            backButton.name = "back_button"
            addChild(backButton)
        }
        
        // Create word display
        wordLabel = SKLabelNode(fontNamed: "Courier")
        if let wordLabel = wordLabel {
            wordLabel.fontSize = 30
            wordLabel.fontColor = SKColor.white
            wordLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
            wordLabel.horizontalAlignmentMode = .center
            addChild(wordLabel)
        }
        
        // Create guesses remaining label
        guessesRemainingLabel = SKLabelNode(fontNamed: "Arial")
        if let guessesRemainingLabel = guessesRemainingLabel {
            guessesRemainingLabel.fontSize = 20
            guessesRemainingLabel.fontColor = SKColor.white
            guessesRemainingLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 50)
            guessesRemainingLabel.horizontalAlignmentMode = .center
            addChild(guessesRemainingLabel)
        }
        
        // TODO: Add hangman sprite
        
        // TODO: Add letter buttons
        
        // Start with a placeholder word
        startNewGame()
    }
    
    private func createButton(text: String, position: CGPoint, size: CGSize) -> SKSpriteNode {
        let button = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0), size: size)
        button.position = position
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = text
        label.fontSize = size.height * 0.4
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
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
