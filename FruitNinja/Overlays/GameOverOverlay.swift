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
    private var continueNode: SKShapeNode!
    
    private var playLb: SKLabelNode!
    private var playNode: SKShapeNode!
    
    var isContinue = false {
        didSet {
          updateBtn(true, event: isContinue, node: continueNode)
            updateBtn(true, event: isContinue, node: continueLb)
        }
    }
    
    var isPlay = false {
        didSet {
            updateBtn(true, event: isContinue, node: playNode)
            updateBtn(true, event: isContinue, node: playLb)
        }
    }
    
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
        guard let touch = touches.first else {return}
        let node = atPoint(touch.location(in: self))
        
        if node.name == SGOOverlaySettings.ContinueNode || node.name == SGOOverlaySettings.ContinueLb {
            gameScene.run(gameScene.buttonSound)
            if !isContinue {isContinue = true}
            
        } else if node.name == SGOOverlaySettings.PlayNode || node.name == SGOOverlaySettings.PlayLb {
            gameScene.run(gameScene.buttonSound)
            if !isPlay {isPlay = true}
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     super.touchesMoved(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isContinue {
            gameScene.presentScene()
            isContinue = false
        }
        if isPlay {
            let fade = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
            bgNode.run(fade) {self.bgNode.isHidden = true}
            playNode.run(.sequence([fade, .removeFromParent()]))
            playLb.run(.sequence([fade, .removeFromParent()]))
            
            gameScene.isGameEnded = false
            run(.wait(forDuration: 1.5)) {
                self.gameScene.tossHandler()
            }
            
        }
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
            let playX = rect.midX - continueW/2
            let playY = rect.midY - continueH/2
            let playRect = CGRect(x: playX, y: playY, width: continueW, height: continueW)
            playNode = createBGNode(playRect, corner: 16)
            playNode.name = SGOOverlaySettings.PlayNode
            
            let pF = playNode.frame
            let pPos = CGPoint(x: pF.midX, y: pF.midY)
            playLb = createLb(pPos, hori: .center, verti: .center, txt: "Play", fontS: 60.0)
            playLb.name = SGOOverlaySettings.PlayLb
            return
        }
        
        // continue bg
        let continueX = rect.midX - continueW/2
        let continueY = rect.minY+200
        let continueRect = CGRect(x: continueX, y: continueY, width: continueW, height: continueH)
        continueNode = createBGNode(continueRect, corner: 16)
        continueNode.name = SGOOverlaySettings.ContinueNode
        
        let cF = continueNode.frame
        let conPos = CGPoint(x: cF.midX, y: cF.midY)
        continueLb = createLb(conPos, hori: .center, verti: .center, txt: "Continue")
        continueLb.name = SGOOverlaySettings.ContinueLb
        
        titleLb = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLb.text = "GAME OVER"
        titleLb.fontSize = 250
        titleLb.numberOfLines = 0
        titleLb.preferredMaxLayoutWidth = rect.width
        titleLb.isHidden = true
        titleLb.position = CGPoint(x: rect.midX, y: rect.height - titleLb.frame.height/2 - 100)
        addChild(titleLb)
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
    
    private func updateBtn(_ anim: Bool, event: Bool, node: SKNode){
        var alpha: CGFloat = 1.0
        if event { alpha = 0.5 }
        if anim {
            node.run(.fadeAlpha(to: alpha, duration: 0.1))
        } else {
            node.alpha = alpha
        }
    }
    
}
