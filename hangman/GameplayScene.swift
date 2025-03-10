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
    private var score = 0
    private var gameStartTime: Date?
    
    // Game Center constants
    private let leaderboardID = "com.hangman.bestscores"  // You'll need to create this in App Store Connect
    private let achievementFastSolve = "com.hangman.fastsolve"  // Complete a word in under 30 seconds
    private let achievementPerfectSolve = "com.hangman.perfectsolve"  // Complete a word with no mistakes
    
    // Theme
    private let theme = ThemeManager.shared
    
    override func didMove(to view: SKView) {
        setupGame()
        
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
        // Reposition buttons and labels
        if let backButton = self.backButton {
            backButton.removeFromParent()
            
            // Create new back button with safe area-aware positioning
            self.backButton = createStyledButton(
                text: "Menu", 
                position: CGPoint(
                    x: SafeAreaHelper.shared.safeLeftPosition(in: self, offset: 60),
                    y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
                ), 
                size: CGSize(width: 120, height: 40)
            )
            if let newBackButton = self.backButton {
                newBackButton.name = "back_button"
                addChild(newBackButton)
            }
        }
        
        // Update guesses remaining label position
        if let guessesRemainingLabel = self.guessesRemainingLabel {
            guessesRemainingLabel.position = CGPoint(
                x: self.frame.midX,
                y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
            )
        }
        
        // Update word label position - keep centered but adjust if needed
        if let wordLabel = self.wordLabel {
            wordLabel.position = CGPoint(
                x: self.frame.midX,
                y: self.frame.midY + SafeAreaHelper.shared.bottomInset * 0.5
            )
        }
        
        // Reposition test button if exists
        if let testButton = self.childNode(withName: "test_complete") as? SKSpriteNode {
            testButton.removeFromParent()
            
            let newTestButton = createStyledButton(
                text: "Test Complete",
                position: CGPoint(
                    x: SafeAreaHelper.shared.safeRightPosition(in: self, offset: 75),
                    y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
                ),
                size: CGSize(width: 150, height: 40)
            )
            newTestButton.name = "test_complete"
            addChild(newTestButton)
        }
        
        // Update any active completion panel
        if let panel = self.childNode(withName: "completion_panel") {
            panel.removeFromParent()
            showCompletionMessage()
        }
    }
    
    // Called when the theme changes
    func refreshTheme() {
        // Update background
        backgroundColor = theme.backgroundColor
        
        // Update UI elements - position them with safe area awareness
        if let backButton = self.backButton {
            backButton.removeFromParent()
            self.backButton = createStyledButton(
                text: "Menu", 
                position: CGPoint(
                    x: SafeAreaHelper.shared.safeLeftPosition(in: self, offset: 60),
                    y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
                ),
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
        
        // Create back button with modern styling - positioned to respect safe areas
        backButton = createStyledButton(
            text: "Menu", 
            position: CGPoint(
                x: SafeAreaHelper.shared.safeLeftPosition(in: self, offset: 60),
                y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
            ), 
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
            // Center with slight adjustment for bottom safe area
            wordLabel.position = CGPoint(
                x: self.frame.midX,
                y: self.frame.midY + SafeAreaHelper.shared.bottomInset * 0.5
            )
            wordLabel.horizontalAlignmentMode = .center
            addChild(wordLabel)
        }
        
        // Create guesses remaining label with themed font and color
        guessesRemainingLabel = SKLabelNode(fontNamed: theme.bodyFont())
        if let guessesRemainingLabel = guessesRemainingLabel {
            guessesRemainingLabel.fontSize = 20
            guessesRemainingLabel.fontColor = theme.textColor
            // Position at top, respecting safe area
            guessesRemainingLabel.position = CGPoint(
                x: self.frame.midX,
                y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
            )
            guessesRemainingLabel.horizontalAlignmentMode = .center
            addChild(guessesRemainingLabel)
        }
        
        // TODO: Add hangman sprite
        
        // TODO: Add letter buttons
        
        // For testing: Add a test complete button
        if GameCenterManager.shared.isAuthenticated {
            let testButton = createStyledButton(
                text: "Test Complete", 
                position: CGPoint(
                    x: SafeAreaHelper.shared.safeRightPosition(in: self, offset: 75),
                    y: SafeAreaHelper.shared.safeTopPosition(in: self, offset: 30)
                ), 
                size: CGSize(width: 150, height: 40)
            )
            testButton.name = "test_complete"
            addChild(testButton)
        }
        
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
        score = 0
        gameStartTime = Date()
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
            } else if node.name == "test_complete" {
                // For testing: Simulate word completion
                handleWordSolved()
            } else if node.name == "play_again" {
                // Start a new game
                self.childNode(withName: "completion_panel")?.removeFromParent()
                startNewGame()
            } else if node.name == "menu" {
                // Return to menu
                if let view = self.view {
                    let menuScene = GameScene(size: view.bounds.size)
                    menuScene.scaleMode = .aspectFill
                    view.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
                }
            } else if node.name == "leaderboard" {
                // Show Game Center leaderboard
                if let viewController = self.view?.window?.rootViewController {
                    GameCenterManager.shared.showLeaderboards(
                        presentingViewController: viewController,
                        leaderboardID: leaderboardID
                    )
                }
            }
            // TODO: Handle letter button touches
        }
    }
    
    // Calculate score based on word length, speed, and errors
    private func calculateScore() -> Int {
        guard let startTime = gameStartTime else { return 0 }
        
        // Base score is 100 points per character in the word
        let baseScore = currentWord.count * 100
        
        // Time bonus: faster completion gets more points
        let timeTaken = Date().timeIntervalSince(startTime)
        let timeBonus = max(0, 1000 - Int(timeTaken * 10)) // Decrease bonus as time increases
        
        // Error penalty: subtract points for each incorrect guess
        let errorPenalty = incorrectGuesses * 200
        
        // Calculate final score (minimum 0)
        return max(0, baseScore + timeBonus - errorPenalty)
    }
    
    // Handle when player successfully solves the word
    private func handleWordSolved() {
        // Calculate score
        score = calculateScore()
        
        // Report score to Game Center if authenticated
        if GameCenterManager.shared.isAuthenticated {
            GameCenterManager.shared.reportScore(score: score, leaderboardID: leaderboardID)
            
            // Check for achievements
            checkAchievements()
        }
        
        // Show completion message
        showCompletionMessage()
    }
    
    private func checkAchievements() {
        guard let startTime = gameStartTime else { return }
        
        // Fast solve achievement - complete in under 30 seconds
        let timeTaken = Date().timeIntervalSince(startTime)
        if timeTaken < 30 {
            GameCenterManager.shared.reportAchievement(identifier: achievementFastSolve, percentComplete: 100)
        }
        
        // Perfect solve achievement - no incorrect guesses
        if incorrectGuesses == 0 {
            GameCenterManager.shared.reportAchievement(identifier: achievementPerfectSolve, percentComplete: 100)
        }
    }
    
    private func showCompletionMessage() {
        // Get safe area frame to size and position the panel properly
        let safeFrame = SafeAreaHelper.shared.safeAreaFrame(in: self)
        
        // Create a completion message panel - sized to fit within safe area
        let panelSize = CGSize(
            width: safeFrame.width * 0.9,
            height: safeFrame.height * 0.7
        )
        
        // Position panel in the center of the safe area
        let panelY = safeFrame.midY + (SafeAreaHelper.shared.bottomInset - SafeAreaHelper.shared.topInset) / 2
        let panel = SKSpriteNode(color: theme.backgroundColor.withAlphaComponent(0.9), size: panelSize)
        panel.position = CGPoint(x: safeFrame.midX, y: panelY)
        panel.zPosition = 100
        panel.name = "completion_panel"
        
        // Create panel border
        let border = SKShapeNode(rectOf: panelSize, cornerRadius: 15)
        border.strokeColor = theme.primaryColor
        border.lineWidth = 4
        border.fillColor = .clear
        panel.addChild(border)
        
        // Create congratulations text
        let congratsLabel = SKLabelNode(fontNamed: theme.titleFont())
        congratsLabel.text = "Word Solved!"
        congratsLabel.fontSize = 32
        congratsLabel.fontColor = theme.primaryColor
        congratsLabel.position = CGPoint(x: 0, y: panel.size.height * 0.25)
        panel.addChild(congratsLabel)
        
        // Create score text
        let scoreLabel = SKLabelNode(fontNamed: theme.bodyFont())
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = theme.textColor
        scoreLabel.position = CGPoint(x: 0, y: 0)
        panel.addChild(scoreLabel)
        
        // Create buttons container
        let buttonsContainer = SKNode()
        buttonsContainer.position = CGPoint(x: 0, y: -panel.size.height * 0.25)
        panel.addChild(buttonsContainer)
        
        // Create play again button
        let playAgainButton = createStyledButton(
            text: "Play Again",
            position: CGPoint(x: -70, y: 0),
            size: CGSize(width: 120, height: 50)
        )
        playAgainButton.name = "play_again"
        buttonsContainer.addChild(playAgainButton)
        
        // Create menu button
        let menuButton = createStyledButton(
            text: "Menu",
            position: CGPoint(x: 70, y: 0),
            size: CGSize(width: 120, height: 50)
        )
        menuButton.name = "menu"
        buttonsContainer.addChild(menuButton)
        
        // Create leaderboard button if authenticated with Game Center
        if GameCenterManager.shared.isAuthenticated {
            let leaderboardButton = createStyledButton(
                text: "Leaderboard",
                position: CGPoint(x: 0, y: -60),
                size: CGSize(width: 160, height: 50)
            )
            leaderboardButton.name = "leaderboard"
            buttonsContainer.addChild(leaderboardButton)
        }
        
        addChild(panel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Game logic updates
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
