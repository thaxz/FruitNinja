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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
}

// MARK: Setups

extension GameOverOverlay {
    
    func setups(_ isPlay: Bool = false){
        isUserInteractionEnabled = true
        let rect = gameScene.playableRect
        let continueW: CGFloat = appDl.iPad ? 600.0 : rect.width*0.6
        let continueH: CGFloat = appDl.iPhoneX ? 150.0 : 180.0
        
        guard !isPlay else {
            return
        }
    }
    
    private func createBGNode(_ rect: CGRect, corner: CGFloat = 0.0) -> SKShapeNode {
        let bgColor = UIColor(red: 206/255, green: 142/255, blue: 96/255, alpha: 0.5)
        let shapeNode = SKShapeNode(rect: rect, cornerRadius: corner)
        shapeNode.strokeColor = bgColor
        shapeNode.fillColor = bgColor
        shapeNode.isHidden = true
        addChild(shapeNode)
        return shapeNode
    }
    
    private func createLb(_ pos: CGPoint, hori: SKLabelHorizontalAlignmentMode, verti: SKLabelVerticalAlignmentMode, txt: String, fontC: UIColor = .white, fontS: CGFloat = 45) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        lbl.fontColor = fontC
        lbl.fontSize = fontS
        lbl.text = txt
        lbl.horizontalAlignmentMode = hori
        lbl.verticalAlignmentMode = verti
        lbl.position = pos
        lbl.isHidden = true
        addChild(lbl)
        return lbl
    }
    
    
}
