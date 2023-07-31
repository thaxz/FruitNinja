//
//  BaseOverlay.swift
//  FruitNinja
//
//  Created by thaxz on 31/07/23.
//

import SpriteKit

class BaseOverlay: SKNode {

    // MARK: Properties

    var gameScene: GameScene!
    private var sizeReference: CGSize = .zero
    private var center: CGPoint {
        return CGPoint(x: sizeReference.width/2, y: sizeReference.height/2)
    }
    var bgNode: SKSpriteNode!
    
    // MARK: Initializers
    
    init(gameScene: GameScene, size: CGSize){
        super.init()
        self.gameScene = gameScene
        self.setups(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Configues

extension BaseOverlay {
    
    // setting up an overlay (popup)
    func setups(_ size: CGSize){
        sizeReference = size
        bgNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), size: sizeReference)
        bgNode.position = center
        bgNode.isHidden = true
        addChild(bgNode)
    }
    
    // fadding in popup
    internal func fadeInBG(){
        bgNode.alpha = 0.0
        bgNode.isHidden = false
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        fade.timingMode = .easeOut
        bgNode.run(fade)
    }
    
    internal func fadeIn(_ node: SKNode, delay: TimeInterval, completion: (() -> Void)? = nil ){
        var actions: [SKAction] = []
        node.alpha = 0.0
        if delay > 0.0 {
            actions.append(.wait(forDuration: delay))
        }
        
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        fade.timingMode = .easeOut
        actions.append(fade)
        node.run(.sequence(actions)) {completion?()}
    }
    
}
