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
    
    var sequenceType: [SequenceType] = []
    var sequencePos = 0
    var delay = 3.0
    
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
        setupSequenceType()
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
        delay *= 0.99
        // creating sequence
        let sequence = sequenceType[sequencePos]
        switch sequence {
        case .OneNoBomb:
            createSprite(.Never)
        case .One:
            createSprite()
        case .TwoWithOneBomb:
            createSprite(.Never)
            createSprite(.Always)
        case .Two:
            createSprite()
            createSprite()
        case .Three:
            createSprite()
            createSprite()
            createSprite()
        case .Four:
            createSprite()
            createSprite()
            createSprite()
            createSprite()
        case .Five:
            createSprite()
            run(.wait(forDuration: delay/5)){self.createSprite()}
            run(.wait(forDuration: delay/5)){self.createSprite()}
            run(.wait(forDuration: delay/5*2)){self.createSprite()}
            run(.wait(forDuration: delay/5*3)){self.createSprite()}
        case .Six:
            createSprite()
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10*2)){self.createSprite()}
        }
        sequencePos += 1
        isNextSequenceQueued = false
    }
    
    func createSprite(_ forceBomb: ForceBomb = .Defaults){
        var sprite = SKSpriteNode()
        // creating bombs
        var bombType = Int.random(min: 1, max: 6)
        if forceBomb == .Never {
            bombType = 1
        } else if forceBomb == .Always {
            bombType = 0
        }
        
        // If the force bomb is always
        if bombType == 0 {
            sprite = SKSpriteNode()
            sprite.zPosition = 1.0
            sprite.setScale(1.5)
            sprite.name = "BombContainer"
            
            let bomb = SKSpriteNode(imageNamed: "bomb_1")
            bomb.name = "bomb"
            sprite.addChild(bomb)
        } else {
            // creating and configuring fruits
            sprite = SKSpriteNode(imageNamed: "fruit_2")
            sprite.setScale(1.5)
            sprite.name = "Fruit"
        }
        
        // Spawning at a random position
        let spriteW = sprite.frame.width
        let xRandom = CGFloat.random(min: frame.minX + spriteW, max: frame.maxX - spriteW)
        let pos = CGPoint(x: xRandom, y: frame.midY)
        let angularVelocity = CGFloat.random(min: -6.0, max: 6.0)/2
        let yVelocity = Int.random(min: 24, max: 32)
        let xVelocity: Int
        let value = frame.minX + 256
        
        if pos.x < value {
            xVelocity = Int.random(min: 8, max: 100)
        } else if pos.x < value*2 {
            xVelocity = Int.random(min: 3, max: 5)
        } else if pos.x < frame.maxX {
            xVelocity = Int.random(min: 3, max: 5)
        } else {
            xVelocity = Int.random(min: 8, max: 15)
        }
        
        sprite.position = pos
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 60.0)
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.angularVelocity = angularVelocity
        sprite.physicsBody?.velocity = CGVector(dx: CGFloat(xVelocity*40), dy: CGFloat(yVelocity*40))
        addChild(sprite)
    }
    
}

// MARK: Sequence Type

extension GameScene {
    
    func setupSequenceType(){
        // Generating a random sequence
        sequenceType = [.OneNoBomb, .One, .TwoWithOneBomb, .Two, .Three, .Four, .Five, .Six]
        for _ in 0...1000{
            let sequence = SequenceType(rawValue: Int.random(min: 2, max: 7))!
            sequenceType.append(sequence)
        }
    }
    
}
