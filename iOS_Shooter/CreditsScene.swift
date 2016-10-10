//
//  CreditsScene.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 09/10/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import Foundation
import SpriteKit

class CreditsScene: SKScene{
    
    // MARK: - iVars
    let sceneManager: GameViewController;
    var creditsLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    var goBackLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    
    init(size: CGSize, scaleMode: SKSceneScaleMode, sceneManager: GameViewController) {
        self.sceneManager = sceneManager;
        super.init(size:size);
        self.scaleMode = scaleMode;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.yellow;
        initLabels(labelName: creditsLabel, text: "Developers:\nSravan.\nBenjamin.", pos: CGPoint( x: self.size.width/2, y: self.size.height/4), fontSize: 36 );
        initLabels(labelName: goBackLabel, text: "Back", pos: CGPoint( x: self.size.width/2, y: 3 * self.size.height/4 ) , fontSize: 52);
        
    }
    
    private func initLabels(labelName: SKLabelNode, text:String, pos: CGPoint, fontSize: CGFloat ){
        labelName.text = text;
        labelName.fontSize = 52;
        labelName.fontColor = SKColor.red;
        labelName.position = pos;
        
        // MARK: - zPosition for Labels -
        labelName.zPosition = 3;
        
        addChild(labelName);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self);
            
            if goBackLabel.contains(location){
                sceneManager.loadHomeScene();
            }
        }
    }
}
