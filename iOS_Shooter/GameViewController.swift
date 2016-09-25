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

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
