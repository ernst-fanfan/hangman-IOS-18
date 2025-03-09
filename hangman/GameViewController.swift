//
//  GameViewController.swift
//  hangman
//
//  Created by Ernst Fanfan on 3/9/25.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authenticate player with Game Center
        authenticateGameCenterPlayer()
        
        if let view = self.view as! SKView? {
            // Create the menu scene directly instead of loading from .sks file
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Register for theme change notifications
            NotificationCenter.default.addObserver(self, 
                                                 selector: #selector(themeDidChange), 
                                                 name: .themeDidChange, 
                                                 object: nil)
        }
    }
    
    private func authenticateGameCenterPlayer() {
        // Authenticate the player with Game Center
        GameCenterManager.shared.authenticatePlayer(presentingViewController: self) { success, error in
            if success {
                print("Game Center authentication successful")
                
                // Post notification so scenes can update their Game Center UI
                NotificationCenter.default.post(name: .gameCenterAuthenticationChanged, object: nil)
            } else {
                if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                } else {
                    print("Game Center authentication failed: User declined")
                }
            }
        }
    }
    
    @objc func themeDidChange() {
        // Refresh the current scene with the new theme
        if let view = self.view as? SKView, let currentScene = view.scene {
            // Determine which scene type is currently presented
            if let gameScene = currentScene as? GameScene {
                gameScene.refreshTheme()
            } else if let gameplayScene = currentScene as? GameplayScene {
                gameplayScene.refreshTheme()
            }
        }
    }
    
    // Support for iOS 13+ dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                ThemeManager.shared.updateThemeForTraitCollection(traitCollection)
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
