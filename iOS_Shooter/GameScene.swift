//
//  GameScene.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 13/09/16.
//  Copyright (c) 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var playerShip:SKSpriteNode!
    
    let rocketSpeed:Double = 1000
    
    var numFingersTouching = 0
    
    var shooting = false
    
    var prevTimeInterval:TimeInterval?
    
    var prevShotTime:TimeInterval = 0
    
    let rateOfFire:Double = 2
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        let scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 100, y: 100)
        
        self.addChild(scoreLabel)
        
        playerShip = SKSpriteNode(imageNamed:"Spaceship")
        
        playerShip.xScale = 0.1
        playerShip.yScale = 0.1
        playerShip.position = CGPoint(x: self.frame.midX, y: 100)
        
        self.addChild(playerShip)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        numFingersTouching += touches.count
        
        // shoot while touching
        shooting = true
        
        for touch in touches {
            let location = touch.location(in: self)
            
            playerShip.position = CGPoint(x: location.x, y: playerShip.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        numFingersTouching -= touches.count
        if (numFingersTouching == 0) {
            // do not shoot
            shooting = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            playerShip.position = CGPoint(x: location.x, y: playerShip.position.y)
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        // get delta time
        var delta:Double = 0;
        if let prev = prevTimeInterval {
            delta = prev - currentTime;
            prevTimeInterval = currentTime;
        } else {
            delta = 0.017;
            prevTimeInterval = currentTime;
        }
        
        // uses a very stupid frame-counting method to decide when to create shots
        if (shooting) {
            if (currentTime - prevShotTime > 1/rateOfFire) {
                prevShotTime = currentTime
                let shot = SKEmitterNode(fileNamed: "LaserParticle")!
                shot.position.x = playerShip.position.x
                shot.position.y = playerShip.position.y
                let shootUp = SKAction.move(to: CGPoint(x:playerShip.position.x, y: playerShip.position.y + 1000), duration: 1)
                

                shot.run(shootUp)
                self.addChild(shot)
            }
        }
    }
    
    func distBetweenPoints(A:CGPoint, B:CGPoint)->Double {
        let hypotenuse = Double((A.x - B.x) * (A.x - B.x) + (A.y - B.y) * (A.y - B.y))
        return sqrt(hypotenuse)
    }
}
