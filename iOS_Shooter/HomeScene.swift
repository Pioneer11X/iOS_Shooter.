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

let fontNameConst: String = "Futura-CondensedExtraBold";

class HomeScene:SKScene{
    
    // MARK: - iVars -
    let sceneManager:GameViewController
    var titleLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    var startGameLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
//    var startGameButton: 
    var instructionsLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    var creditsLabel: SKLabelNode = SKLabelNode(fontNamed: fontNameConst);
    var backgroundNode: SKSpriteNode = SKSpriteNode(imageNamed: "birthday-background-placeholder.png");
    
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
        initLabels(labelName: titleLabel, text: "PARTY POPPER", pos: CGPoint(x: self.size.width/2, y: 4*self.size.height/5), fSize: 152);
        initLabels(labelName: startGameLabel, text: "Start", pos: CGPoint(x: self.size.width/2, y: 3 * self.size.height/5), fSize: 52);
        //addChild(startGameLabel);
        initLabels(labelName: instructionsLabel, text: "Instructions", pos: CGPoint(x: self.size.width/2 , y: 2 * self.size.height/5), fSize: 52);
        initLabels(labelName: creditsLabel, text: "Credits", pos: CGPoint(x: self.size.width/2, y: self.size.height/5), fSize: 52);
        
        backgroundNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2);
        backgroundNode.zPosition = -1;
        self.addChild(backgroundNode);
        
        
        
    }
    
    private func initLabels(labelName: SKLabelNode, text:String, pos: CGPoint, fSize:CGFloat){
        labelName.text = text;
        labelName.fontSize = fSize;
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
                let levelData: LevelData = LevelData(currentLevel: 1, tankTime: 7.0, balloonTime: 3.0, tankProjectileTime: 3.0, balloonProjectileTime: 2.0, tankDelayTime: 3.0, balloonDelayTime: 0.5, shootChance: 0.05 );

                sceneManager.loadGameScene(level: levelData);
                // TODO: - Need to take them to the Game Scene.
            }else if instructionsLabel.contains(location){
                print("You need Instructions for this game?");
                //sceneManager.
                sceneManager.loadInstructionsScene();
            }else if creditsLabel.contains(location){
                sceneManager.loadCreditsScreen();
            }
        }
    }
    
}
