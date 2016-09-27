//
//  GameOver.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 26/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;

class GameOverScene: SKScene{
    
    // MARK: -iVars-
    
    let sceneManager: GameViewController;
    var gameOverLabel: SKLabelNode;
    var scoreLabel: SKLabelNode;
    var levelsLabel: SKLabelNode;
    var playAgainLabel: SKLabelNode;
    
    init(size: CGSize, scaleMode: SKSceneScaleMode, sceneManager: GameViewController){
        self.sceneManager = sceneManager;
        
        gameOverLabel = SKLabelNode(fontNamed: sceneManager.gameData.fontName);
        scoreLabel = SKLabelNode(fontNamed: sceneManager.gameData.fontName);
        levelsLabel = SKLabelNode(fontNamed: sceneManager.gameData.fontName);
        playAgainLabel = SKLabelNode(fontNamed: sceneManager.gameData.fontName);
        
        
        super.init(size:size);
        self.scaleMode = scaleMode;
    
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.yellow;
        initLabels(labelName: gameOverLabel, text: "Game Over", pos: CGPoint(x: self.size.width/2,y: 4 * self.size.height/5));
        initLabels(labelName: scoreLabel, text: "Score: \(sceneManager.gameData.player1.score)", pos: CGPoint(x: self.size.width/2,y: 3 * self.size.height/5));
        initLabels(labelName: levelsLabel, text: "You reached Level \(sceneManager.gameData.currentLevel)", pos: CGPoint(x: self.size.width/2,y: 2 * self.size.height/5));
        initLabels(labelName: playAgainLabel, text: "Play Again", pos: CGPoint(x: self.size.width/2,y: 1 * self.size.height/5));
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self);
            if playAgainLabel.contains(location){
                let levelData: LevelData = LevelData(currentLevel: 1, tankTime: 7.0, planeTime: 3.0, tankProjectileTime: 3.0, planeProjectileTime: 2.0, tankDelayTime: 3.0, planeDelayTime: 4.0 );
                self.sceneManager.gameData.player1.lifes = 3;
                self.sceneManager.gameData.player1.score = 0;
                self.sceneManager.gameData.player1.hits = 0;
                sceneManager.loadGameScene(level: levelData);
            }
        }
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
    
}
