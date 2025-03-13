//
//  GameCenterManager.swift
//  hangman
//
//  Created on 3/9/25.
//

import UIKit
import GameKit

class GameCenterManager: NSObject, GKLocalPlayerListener {
    static let shared = GameCenterManager()
    
    var isAuthenticated = false
    var lastError: Error?
    
    // Completion handler for authentication
    typealias AuthCompletion = (Bool, Error?) -> Void
    
    // MARK: - Authentication
    
    func authenticatePlayer(presentingViewController: UIViewController, completion: AuthCompletion? = nil) {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Present the Game Center login view controller
                presentingViewController.present(viewController, animated: true)
            } else if localPlayer.isAuthenticated {
                // Player authenticated
                self.isAuthenticated = true
                localPlayer.register(self)
                print("Game Center: Player authenticated as \(localPlayer.displayName)")
                
                // Setup leaderboards, achievements, etc.
                self.loadGameCenterData()
                
                // Notify completion
                completion?(true, nil)
            } else {
                // Player declined to sign in or error occurred
                self.isAuthenticated = false
                self.lastError = error
                
                if let error = error {
                    print("Game Center authentication error: \(error.localizedDescription)")
                } else {
                    print("Game Center: Player declined to sign in")
                }
                
                // Notify completion
                completion?(false, error)
            }
        }
    }
    
    // MARK: - Game Center Data
    
    private func loadGameCenterData() {
        // Load leaderboards
        loadLeaderboards()
        
        // Load achievements
        loadAchievements()
    }
    
    private var leaderboards: [GKLeaderboard] = []
    
    private func loadLeaderboards() {
        GKLeaderboard.loadLeaderboards(IDs: nil) { [weak self] leaderboards, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading leaderboards: \(error.localizedDescription)")
                return
            }
            
            if let leaderboards = leaderboards {
                self.leaderboards = leaderboards
                print("Game Center: Loaded \(leaderboards.count) leaderboards")
            }
        }
    }
    
    private var achievements: [GKAchievement] = []
    
    private func loadAchievements() {
        GKAchievement.loadAchievements { [weak self] achievements, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading achievements: \(error.localizedDescription)")
                return
            }
            
            if let achievements = achievements {
                self.achievements = achievements
                print("Game Center: Loaded \(achievements.count) achievements")
            }
        }
    }
    
    // MARK: - Leaderboards
    
    // Report score to leaderboard
    func reportScore(score: Int, leaderboardID: String, completion: ((Error?) -> Void)? = nil) {
        guard isAuthenticated else {
            completion?(NSError(domain: "GameCenterManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Player not authenticated"]))
            return
        }
        
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Game Center: Reported score \(score) to leaderboard \(leaderboardID)")
            }
            
            completion?(error)
        }
    }
    
    // MARK: - Achievements
    
    // Report achievement progress
    func reportAchievement(identifier: String, percentComplete: Double, completion: ((Error?) -> Void)? = nil) {
        guard isAuthenticated else {
            completion?(NSError(domain: "GameCenterManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Player not authenticated"]))
            return
        }
        
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        
        // Only report if the achievement isn't already completed
        if let existingAchievement = achievements.first(where: { $0.identifier == identifier }),
           existingAchievement.percentComplete >= 100 {
            print("Game Center: Achievement \(identifier) already completed")
            completion?(nil)
            return
        }
        
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement: \(error.localizedDescription)")
            } else {
                print("Game Center: Reported achievement \(identifier) progress: \(percentComplete)%")
            }
            
            completion?(error)
        }
    }
    
    // MARK: - Game Center UI
    
    // Show Game Center dashboard
    func showGameCenter(presentingViewController: UIViewController) {
        guard isAuthenticated else {
            print("Game Center: Cannot show dashboard, player not authenticated")
            return
        }
        
        let gameCenterVC = GKGameCenterViewController(state: .dashboard)
        gameCenterVC.gameCenterDelegate = self
        presentingViewController.present(gameCenterVC, animated: true)
    }
    
    // Show leaderboards
    func showLeaderboards(presentingViewController: UIViewController, leaderboardID: String? = nil) {
        guard isAuthenticated else {
            print("Game Center: Cannot show leaderboards, player not authenticated")
            return
        }
        
        // Configure the default leaderboard if one is specified
        if let leaderboardID = leaderboardID {
            GKLocalPlayer.local.setDefaultLeaderboardIdentifier(leaderboardID) { error in
                if let error = error {
                    print("Error setting default leaderboard: \(error.localizedDescription)")
                }
            }
        }
        
        let gameCenterVC = GKGameCenterViewController(state: .leaderboards)
        gameCenterVC.gameCenterDelegate = self
        presentingViewController.present(gameCenterVC, animated: true)
    }
    
    // Show achievements
    func showAchievements(presentingViewController: UIViewController) {
        guard isAuthenticated else {
            print("Game Center: Cannot show achievements, player not authenticated")
            return
        }
        
        let gameCenterVC = GKGameCenterViewController(state: .achievements)
        gameCenterVC.gameCenterDelegate = self
        presentingViewController.present(gameCenterVC, animated: true)
    }
    
    // MARK: - Multiplayer
    
    // Find match
    func findMatch(presentingViewController: UIViewController, minPlayers: Int = 2, maxPlayers: Int = 2) {
        guard isAuthenticated else {
            print("Game Center: Cannot find match, player not authenticated")
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let matchmakerVC = GKMatchmakerViewController(matchRequest: request)
        matchmakerVC?.matchmakerDelegate = self
        
        presentingViewController.present(matchmakerVC!, animated: true)
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

// MARK: - GKMatchmakerViewControllerDelegate
extension GameCenterManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        
        // Handle match found
        print("Game Center: Match found with \(match.players.count) players")
        
        // TODO: Start multiplayer game with this match
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        print("Game Center: Matchmaking was cancelled")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        print("Game Center: Matchmaking failed with error: \(error.localizedDescription)")
    }
}
