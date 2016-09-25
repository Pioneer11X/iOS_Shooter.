//
//  HomeScene.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 24/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;

// MARK: - Global Constant -
// TODO: - Make a Global constant containing these trivial data somewhere else.

let fontNameConst: String = "Chalkduster";

class HomeScene:SKScene{
    
    // MARK: - iVars -
    let sceneManager:GameViewController
    var startGameLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
//    var startGameButton: 
    var instructionsLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    
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
        initLabels(labelName: startGameLabel, text: "Start", pos: CGPoint(x: self.size.width/2, y: 2 * self.size.height/3));
        //addChild(startGameLabel);
        initLabels(labelName: instructionsLabel, text: "Instructions", pos: CGPoint(x: self.size.width/2 , y: self.size.height/3));
        
        
    }
    
    private func initLabels(labelName: SKLabelNode, text:String, pos: CGPoint){
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
            
            if startGameLabel.contains(location){
                print("Label Pressed");
                // TODO: - Need to take them to the Game Scene.
            }else if instructionsLabel.contains(location){
                print("You need Instruction for this game?");
                //sceneManager.
                sceneManager.loadInstructionsScene();
            }
        }
    }
    
}
