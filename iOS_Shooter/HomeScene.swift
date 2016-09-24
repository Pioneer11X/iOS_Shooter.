//
//  HomeScene.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 24/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;

// MARK: - Global Constant -

let fontNameConst: String = "Chalkduster";

class HomeScene:SKScene{
    
    // MARK: - iVars -
    
    var startGameLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    var instructionsLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    
    
    override func didMove(to view: SKView) {
        
        initLabels(labelName: startGameLabel, text: "Start", pos: CGPoint(x: self.size.width/2, y: self.size.height/2));
        initLabels(labelName: instructionsLabel, text: "Instructions", pos: CGPoint(x: self.size.width/2 + 50, y: self.size.height/2));
        
    }
    
    private func initLabels(labelName: SKLabelNode, text:String, pos: CGPoint){
        labelName.text = text;
        labelName.fontSize = 24;
        labelName.fontColor = SKColor.black;
        labelName.position = pos;
        
        // MARK: - zPosition for Labels -
        labelName.zPosition = 3;
        addChild(labelName);
    }
    
}
