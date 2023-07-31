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
    var sequencePos = 0
    var delay = 3.0
    var isNextSequenceQueued = true
    
    var sequenceType: [SequenceType] = []
    var activeSprites: [SKNode] = []
    
    // to form the belziers curve
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints: [CGPoint] = []
    
    //score
    var scoreLb: SKLabelNode!
    var score: Int = 0 {
        willSet {
            scoreLb.text = "\(newValue)"
            scoreLb.run(.sequence([
                .scale(to: 1.5, duration: 0.1),
                .scale(to: 1.0, duration: 0.1)
            ]))
        }
    }
    
    // lives
    var livesNodes: [SKSpriteNode] = []
    var lives = 3
    
    // the playable area
    var playableRect: CGRect {
        let ratio: CGFloat = appDl.iPhoneX ? 2.16 : 16/9
        let width = size.width
        let height = width / ratio
        let x: CGFloat = 0.0
        let y: CGFloat = (size.height - height)/2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // Sounds
    
    let buttonSound = SKAction.playSoundFileNamed(SoundType.button.rawValue, waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed(SoundType.explosion.rawValue, waitForCompletion: false)
    let launchSound = SKAction.playSoundFileNamed(SoundType.launch.rawValue, waitForCompletion: false)
    let sliceBombFuseSound = SKAction.playSoundFileNamed(SoundType.sliceBombFuse.rawValue, waitForCompletion: false)
    let swooshSounds: [SKAction] = [
        SKAction.playSoundFileNamed(SoundType.smoosh1.rawValue, waitForCompletion: false),
        SKAction.playSoundFileNamed(SoundType.smoosh2.rawValue, waitForCompletion: false),
        SKAction.playSoundFileNamed(SoundType.smoosh3.rawValue, waitForCompletion: false)
    ]
    let whackSound = SKAction.playSoundFileNamed(SoundType.whack.rawValue, waitForCompletion: false)
    let wrongSound = SKAction.playSoundFileNamed(SoundType.wrong.rawValue, waitForCompletion: false)
    
    var isSwooshSound = false
    
    //MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        activeSlicePoints.removeAll(keepingCapacity: true)
        for _ in touches {
            // verifying if theres a touch
            guard let touch = touches.first else {return}
            // and getting its location
            let location = touch.location(in: self)
            // adding to the path
            activeSlicePoints.append(location)
            redrawActiveSlice()
            
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            activeSliceBG.alpha = 1.0
            activeSliceFG.alpha = 1.0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // Fading the path
        activeSliceBG.run(.fadeAlpha(to: 0.0, duration: 0.25))
        activeSliceFG.run(.fadeAlpha(to: 0.0, duration: 0.25))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {return}
        //upadting the location
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        // playing swoosh sound everytime is slicing something
        if !isSwooshSound {playSwooshSound()}
        
        // removing the node that was sliced
        let ns = nodes(at: location)
        for node in ns {
            if node.name == "Fruit" {
                // adding slice particle
                createEmitter("SliceHitFruit", pos: node.position, node: self)
                
                node.name = nil
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.run(sequence)
                
                // increasing the score
                score += 1
                removeSprite(node, nodes: &activeSprites)
                run(whackSound)
                
            } else if node.name == "Bomb" {
                createEmitter("SliceHitBomb", pos: node.position, node: self)
                node.name = nil
                node.parent!.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.parent!.run(sequence)
                
                removeSprite(node.parent!, nodes: &activeSprites)
                // explosion sound when bomb is sliced
                run(explosionSound)
                setupGameOver(true)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // counting bombs
        var bombCount = 0
        for node in activeSprites {
            if node.name == "BombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            SKTAudio.shared.stopSoundEffect()
        }
        
        // spawing fruits
        if activeSprites.count > 0 {
            activeSprites.forEach({
                let height = $0.frame.height
                let value = frame.minY - height
                if $0.position.y < value {
                    $0.removeAllActions()
                    if $0.name == "BombContainer"{
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    } else if $0.name == "Fruit" {
                        subtrackLife()
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    }
                }
            })
        } else {
            if !isNextSequenceQueued {
                run(.wait(forDuration: popupTime)){self.tossHandler()}
                isNextSequenceQueued = true
            }
        }
    }
    
    
}

// MARK: Configues

extension GameScene {
    
    func setupNodes(){
        createBg()
        setupPhysics()
        setupSequenceType()
        createSlice()
        createScore()
        drawPlayableArea()
        createLives()
        tossHandler()
    }
    
    func drawPlayableArea(){
        let shape = SKShapeNode(rect: playableRect)
        shape.lineWidth = 5.0
        shape.strokeColor = .red
        shape.fillColor = .clear
        addChild(shape)
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
        physicsWorld.speed *= 1.02
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
            // playing music
            SKTAudio.shared.playSoundEffect(SoundType.sliceBombFuse.rawValue)
            // adding effect to the bomb as if its about to explode
            let pos = CGPoint(x: bomb.frame.midX+35, y: bomb.frame.maxY+5)
            createEmitter("SliceFuse", pos: pos, node: sprite)
        } else {
            // creating and configuring fruits
            sprite = SKSpriteNode(imageNamed: "fruit_2")
            sprite.setScale(1.5)
            sprite.name = "Fruit"
            run(launchSound)
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
        activeSprites.append(sprite)
    }
    
    func removeSprite(_ node: SKNode, nodes: inout [SKNode]){
        if let index = nodes.firstIndex(of: node){
            nodes.remove(at: index)
        }
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

// MARK: Slice

extension GameScene {
    
    // creating slice effect
    func createSlice(){
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2.0
        activeSliceBG.lineWidth = 9.0
        activeSliceBG.strokeColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1)
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2.0
        activeSliceFG.lineWidth = 5.0
        activeSliceFG.strokeColor = .white
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    // redrawing to update path
    func redrawActiveSlice(){
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        while activeSlicePoints.count > 12 {
            activeSlicePoints.remove(at: 0)
        }
        let bezierPath = UIBezierPath()
        bezierPath.move(to: activeSlicePoints[0])
        
        for i in 0..<activeSlicePoints.count {
            bezierPath.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = bezierPath.cgPath
        activeSliceFG.path = bezierPath.cgPath
    }
    
    // play sound when slicing
    func playSwooshSound(){
        isSwooshSound = true
        let soundAction = swooshSounds[Int.random(min: 0, max: 2)]
        run(soundAction){
            self.isSwooshSound = false
        }
    }
    
}

// MARK: Score

extension GameScene {
    
    func createScore(){
        
        let width: CGFloat =    250.0
        let height: CGFloat = 100.0
        let yPos = appDl.iPad ? frame.maxY - height-20 : playableRect.maxY - height-20
        let shapeRect = CGRect(x: frame.midX - width/2, y: yPos, width: width, height: height)
        let shape = SKShapeNode(rect: shapeRect, cornerRadius: 8.0)
        shape.strokeColor = .clear
        shape.fillColor = UIColor.black.withAlphaComponent(0.5)
        shape.zPosition = 5
        addChild(shape)
        
        scoreLb = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
        scoreLb.text = "0"
        scoreLb.zPosition = 5
        scoreLb.fontSize = 80.0
        scoreLb.verticalAlignmentMode = .center
        scoreLb.horizontalAlignmentMode = .center
        scoreLb.position = CGPoint(x: shape.frame.midX, y: shape.frame.midY)
        shape.addChild(scoreLb)
    }
    
}

// MARK: Life

extension GameScene {
    
    // creating life nodes
    func createLives(){
        for i in 0..<3 {
            let sprite = SKSpriteNode(imageNamed: "sliceLife")
            sprite.setScale(1.5)
            let spriteW = sprite.frame.width
            let spriteH = sprite.frame.height
            let yPos = appDl.iPad ? frame.maxY - spriteH : playableRect.maxY - spriteH
            sprite.position = CGPoint(x: CGFloat(i)*spriteW + 70, y: yPos + 30)
            addChild(sprite)
            livesNodes.append(sprite)
        }
    }
    
    // subtracting lifes
    func subtrackLife(){
        lives -= 1
        run(wrongSound)
        let sprite: SKSpriteNode
        if lives == 2{
            sprite = livesNodes[0]
        } else if lives == 1 {
            sprite = livesNodes[1]
        } else {
            sprite = livesNodes[2]
            setupGameOver(false)
        }
        sprite.texture = SKTexture(imageNamed: "sliceLifeGone")
        sprite.xScale = 1.5*1.3
        sprite.yScale = 1.5*1.3
        sprite.run(.scale(to: 1.5, duration: 0.1))
    }
    
}

// MARK: Game over

extension GameScene {
    
    func setupGameOver(_ isGameOver: Bool){
        physicsWorld.speed = 0.0
        isUserInteractionEnabled = false
        SKTAudio.shared.stopSoundEffect()
        if isGameOver {
            let texture = SKTexture(imageNamed: "sliceLifeGone")
            livesNodes[0].texture = texture
            livesNodes[1].texture = texture
            livesNodes[2].texture = texture
        }
    }
    
}

// MARK: SKEmitterNode

extension GameScene {
    
    // creating particles
    
    func createEmitter(_ fn: String, pos: CGPoint, node: SKNode){
      let emitter = SKEmitterNode(fileNamed: fn)!
        emitter.position = pos
        node.addChild(emitter)
    }
    
}
