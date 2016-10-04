//
//  GameViewController.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 13/09/16.
//  Copyright (c) 2016 Sravan Karuturi. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // MARK: - iVars -
    
    var gameScene: GameScene?
    var skView: SKView!
    let showDebugData = true;
    let screenbounds: CGRect = UIScreen.main.bounds
    let scaleMode = SKSceneScaleMode.aspectFill;
    
    // MARK: - Initialising the Game Data
    
    var gameData: GameData = GameData();
    

    override func viewDidLoad() {

        super.viewDidLoad()
        skView = self.view as! SKView
        loadHomeScene();

    }
    
    // MARK: - Scene Management
    func loadHomeScene(){
        let screenSize:CGSize = CGSize(width:screenbounds.width, height: screenbounds.height);
        let scene = HomeScene(size: screenSize, scaleMode: scaleMode, sceneManager: self);
        skView.presentScene(scene);
    }
    
    func loadInstructionsScene(){
        let screenSize:CGSize = CGSize(width:screenbounds.width, height: screenbounds.height);
        let scene = InstructionsScene(size: screenSize, scaleMode: scaleMode, sceneManager: self);
        skView.presentScene(scene);
    }
    
    func loadGameScene(level: LevelData){
        let screenSize:CGSize = CGSize(width:screenbounds.width, height: screenbounds.height);
        let scene = LevelScene( levelData: level, gameData: gameData, size: screenSize,scaleMode: scaleMode, sceneManager: self)
        skView.presentScene(scene);
    }
    
    func loadGameOverScene(){
        let screenSize:CGSize = CGSize(width:screenbounds.width, height: screenbounds.height);
        let scene = GameOverScene(size: screenSize, scaleMode: scaleMode, sceneManager: self);
        skView.presentScene(scene);
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscape
        } else {
            // TODO: - Should we put this here -
            return .landscape
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func loadGameData(){
        self.gameData.fontSize = 24;
        self.gameData.fontColor = UIColor.red;
        self.gameData.fontName = "Futura-CondensedExtraBold";
        self.gameData.currentLevel = 1;
        self.gameData.player1 = Player();
        self.gameData.player2 = Player();
    }
    
 
    
}

class GameData {
    
    var fontSize: CGFloat = 24;
    var fontColor = UIColor.red;
    var fontName: String = "Futura-CondensedExtraBold";
    var currentLevel = 0;
    var player1: Player = Player();
    var player2: Player = Player();
    
}
