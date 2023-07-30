//
//  GameScene.swift
//  FruitNinja
//
//  Created by thaxz on 29/07/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    var popupTime: Double = 0.9
    
    //MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        run(.wait(forDuration: popupTime)){
            self.tossHandler()
        }
    }
    
   
}

// MARK: Configues

extension GameScene {
    
    func setupNodes(){
        createBg()
        tossHandler()
    }
    
    
}

// MARK: Background

extension GameScene {
    
    func createBg(){
        let bg = SKSpriteNode(imageNamed: "background")
        bg.position = CGPoint(x: frame.width/2, y: frame.height/2)
        bg.zPosition = -1
        addChild(bg)
    }
    
}

// MARK: Fruit

extension GameScene {
    
    func tossHandler(){
        // time to spawn fruit
        popupTime *= 0.0991
        createSprite()
    }
    
    func createSprite(){
        let sprite = SKSpriteNode(imageNamed: "fruit_2")
        sprite.setScale(1.5)
        sprite.name = "Fruit"
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
    }
    
}
