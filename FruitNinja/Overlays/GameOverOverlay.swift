//
//  GameOverOverlay.swift
//  FruitNinja
//
//  Created by thaxz on 31/07/23.
//

import SpriteKit

struct SGOOverlaySettings {
    static let ContinueNode = "ContinueNode"
    static let ContinueLb = "ContinueLb"
    
    static let PlayNode = "PlayNode"
    static let PlayLb = "PlayLb"
}

class GameOverOverlay: BaseOverlay {
    
    // MARK: Properties
    private var titleLb: SKLabelNode!
    
    private var continueLb: SKLabelNode!
    private var continueNode: SKLabelNode!
    
    private var playLb: SKLabelNode!
    private var playNode: SKLabelNode!
    
    // MARK: Init
    
    override init(gameScene: GameScene, size: CGSize){
        super.init(gameScene: gameScene, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touches
    
    
    
}
