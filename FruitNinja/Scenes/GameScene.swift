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
    var isNextSequenceQueued = true
    
    //MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isNextSequenceQueued {
            run(.wait(forDuration: popupTime)){self.tossHandler()}
            isNextSequenceQueued = true
        }
    }
    
   
}

// MARK: Configues

extension GameScene {
    
    func setupNodes(){
        createBg()
        setupPhysics()
        tossHandler()
    }
    
    func setupPhysics(){
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.speed = 0.85
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
        popupTime *= 0.991
        createSprite()
        isNextSequenceQueued = false
    }
    
    func createSprite(){
        // creating and configuring fruits
        let sprite = SKSpriteNode(imageNamed: "fruit_2")
        sprite.setScale(1.5)
        sprite.name = "Fruit"
        let spriteW = sprite.frame.width
        // Spawning at a random position
        let xRandom = CGFloat.random(min: frame.minX + spriteW, max: frame.maxX - spriteW)
        let pos = CGPoint(x: xRandom, y: frame.midY)
        sprite.position = pos
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 60.0)
        sprite.physicsBody?.collisionBitMask = 0
        addChild(sprite)
    }
    
}
