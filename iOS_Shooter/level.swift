//
//  level1.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 24/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;
import Foundation;

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct LevelData {
    var currentLevel: Int;
    var tankTime: Double;
    var balloonTime: Double;
    var tankProjectileTime: Double;
    var balloonProjectileTime: Double;
    var tankDelayTime: Double;
    var balloonDelayTime: Double;
}

class LevelScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - iVars for Levels
    
    var currentLevel: Int;
    var levelData: LevelData;
    var player1Node : SKSpriteNode! ;
    var player2Node : SKSpriteNode! ;
    var player1ScoreLabel: SKLabelNode! ;
    var player2ScoreLabel: SKLabelNode! ;
    var levelLabel: SKLabelNode! ;
    var player1LifeLabel: SKLabelNode! ;
    var player2LifeLabel: SKLabelNode! ;
    var gameData: GameData;
    var groundNode: SKSpriteNode! ;
    var sceneManager: GameViewController;
    var topBulletCollector: SKSpriteNode!;
    var btmBulletCollector: SKSpriteNode!;
    var isTouching: Bool;
    var touchLocation: CGPoint?;
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Tank   : UInt32 = 0b1
        static let Projectile: UInt32 = 0b10
        static let PlayerProjectile: UInt32 = 0b100;
        static let Player: UInt32 = 0b1000;
        static let balloon: UInt32 = 0b10000;
        static let BulletCollector: UInt32 = 0b100000;
    }
    
    init(levelData: LevelData, gameData: GameData, size: CGSize, scaleMode: SKSceneScaleMode, sceneManager: GameViewController) {
        
        
        // MARK: - Labels Initialisation -
        player1ScoreLabel = SKLabelNode(fontNamed: gameData.fontName);
        player2ScoreLabel = SKLabelNode(fontNamed: gameData.fontName);
        levelLabel = SKLabelNode(fontNamed: gameData.fontName);
        player1LifeLabel = SKLabelNode(fontNamed: gameData.fontName);
        player2LifeLabel = SKLabelNode(fontNamed: gameData.fontName);
        self.gameData = gameData;
        self.currentLevel = levelData.currentLevel;
        self.levelData = levelData;
        self.sceneManager = sceneManager;
        
        groundNode = SKSpriteNode(imageNamed: "ground");
        player2Node = SKSpriteNode(imageNamed: "player2");
        
        btmBulletCollector = SKSpriteNode(imageNamed: "projectile");
        topBulletCollector = SKSpriteNode(imageNamed: "projectile");
        
        isTouching = false;
        touchLocation = nil;
        
        super.init(size:size);
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        
        self.physicsWorld.contactDelegate = self;
        
        initLabel(label: levelLabel, gameData: gameData, text: "Round: \(currentLevel)", pos: CGPoint(x: self.size.width/2 , y: self.size.height - 50 ) );
        initLabel(label: player1ScoreLabel, gameData: gameData, text: "Score: \(gameData.player1.score)", pos: CGPoint(x: self.size.width/4, y: self.size.height - 50 ) );
        initLabel(label: player2ScoreLabel, gameData: gameData, text: "Score: \(gameData.player1.score)", pos: CGPoint(x: 3 * self.size.width/4, y: self.size.height - 50 ) );
        initLabel(label: player1LifeLabel, gameData: gameData, text: "Lives: \(gameData.player1.lifes)", pos: CGPoint(x: self.size.width/4, y: self.size.height - 100 ) );
        initLabel(label: player2LifeLabel, gameData: gameData, text: "Lives: \(gameData.player1.lifes)", pos: CGPoint(x: 3 * self.size.width/4, y: self.size.height - 100 ) );
        
        groundNode.position = CGPoint(x: self.size.width/2, y: 10 );
        groundNode.zPosition = 2.0
        
        topBulletCollector.position = CGPoint(x: 0, y: self.size.height);
        btmBulletCollector.position = CGPoint(x: self.size.width, y: 0);
        topBulletCollector.xScale = 5;
        btmBulletCollector.zRotation = .pi/2;
        btmBulletCollector.xScale = 5;
        
        topBulletCollector.physicsBody = SKPhysicsBody(rectangleOf: topBulletCollector.size);
        topBulletCollector.physicsBody?.isDynamic = true;
        topBulletCollector.physicsBody?.categoryBitMask = PhysicsCategory.BulletCollector;
        topBulletCollector.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.PlayerProjectile;
        topBulletCollector.physicsBody?.collisionBitMask = PhysicsCategory.None;
        topBulletCollector.physicsBody?.affectedByGravity = false;
        
        btmBulletCollector.physicsBody = SKPhysicsBody(rectangleOf: btmBulletCollector.size);
        btmBulletCollector.physicsBody?.isDynamic = true;
        btmBulletCollector.physicsBody?.categoryBitMask = PhysicsCategory.BulletCollector;
        btmBulletCollector.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.PlayerProjectile;
        btmBulletCollector.physicsBody?.collisionBitMask = PhysicsCategory.None;
        btmBulletCollector.physicsBody?.affectedByGravity = false;
        
        topBulletCollector.zPosition = -1.0;
        btmBulletCollector.zPosition = -1.0;
        
        self.addChild(topBulletCollector);
        self.addChild(btmBulletCollector);
        
        // background music
        let backgroundMusic = SKAudioNode(fileNamed: "Super Power Cool Dude")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        initialisePlayers();
        
        self.addChild(player1ScoreLabel);
        //self.addChild(player2ScoreLabel);
        self.addChild(player1LifeLabel);
        //self.addChild(player2LifeLabel);
        self.addChild(levelLabel);
        self.addChild(groundNode);
        self.addChild(player1Node);
        //self.addChild(player2Node);
        
//        addTanks();
        
        /*run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addTanks),
                SKAction.wait(forDuration: levelData.tankDelayTime)
                ])
        ))*/
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: levelData.balloonDelayTime),
                SKAction.run(addballoons)
                ])
        ))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask;
//        print(contact.bodyA.categoryBitMask);
//        print(" ");
//        print(contact.bodyB.categoryBitMask);
//        print(contactMask);
        switch contactMask {
        case 3: break
            // Do nothing. The tank/balloon projectile hit with the tank.
        case 5:
            // You shot a Tank.
            // Remove the Tank, Remove the projectile, add the score. Add a life if score % 5 == 0.
            contact.bodyA.node?.removeFromParent();
            contact.bodyB.node?.removeFromParent();
            self.gameData.player1.score += 1;
            self.gameData.player1.hits += 1;
            if self.gameData.player1.hits % 5 == 0{
                self.gameData.player1.lifes += 1;
            }
            updateLabels();
            run(SKAction.playSoundFileNamed("Explosion1.wav", waitForCompletion: false))
            break;
        case 6:
            // You shot down a projectile coming towards you.
            // boom
            let explosionEffect = SKEmitterNode.init(fileNamed: "Pop");
            explosionEffect?.position = (contact.bodyA.node?.position)!;
            explosionEffect?.targetNode = self;
            explosionEffect?.particleSize = CGSize.init(width: 20, height: 20);
            self.addChild(explosionEffect!);
            explosionEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.removeFromParent()]))
            // remove
            contact.bodyA.node?.removeFromParent();
            contact.bodyB.node?.removeFromParent();
            run(SKAction.playSoundFileNamed("Explosion3.wav", waitForCompletion: false))
            break;
        case 10:
            // You were shot.
            self.gameData.player1.lifes += -1;
            updateLabels();
            run(SKAction.playSoundFileNamed("Hurt.wav", waitForCompletion: false))
            break;
        case 9:
            // You collided with another Tank. You die.
            self.gameData.player1.lifes -= 1;
            run(SKAction.playSoundFileNamed("Hurt.wav", waitForCompletion: false))
            updateLabels();
            self.sceneManager.loadGameOverScene();
            // TODO: - Call the End game Scene.
            break;
        case 20:
            // You shot the balloon.
            // balloon ref
            var balloon:SKSpriteNode
            if let b:SKSpriteNode = (contact.bodyA.node as? SKSpriteNode) {
                balloon = b;
            } else {
                balloon = (contact.bodyB.node as? SKSpriteNode)!;
            }
            // boom
            let explosionEffect = SKEmitterNode.init(fileNamed: "Pop");
            explosionEffect?.position = (contact.bodyA.node?.position)!;
            explosionEffect?.targetNode = self;
            self.addChild(explosionEffect!);
            explosionEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.removeFromParent()]));
            // confetti
            let confetti = SKEmitterNode.init(fileNamed: "Confetti");
            confetti?.position = (balloon.position);
            // get new color
            confetti?.particleColorSequence = nil;
            confetti?.particleColorBlendFactor = 1.0;
            confetti?.particleColor = balloon.color;
            confetti?.targetNode = self;
            self.addChild(confetti!);
            confetti?.run(SKAction.sequence([SKAction.wait(forDuration: 2),SKAction.removeFromParent()]));
            // remove
            contact.bodyA.node?.removeFromParent();
            contact.bodyB.node?.removeFromParent();
            self.gameData.player1.score += 2;
            updateLabels();
            run(SKAction.playSoundFileNamed("Explosion1.wav", waitForCompletion: false))
            
            break;
        case 36:
            // The projectile collided with the Collector.
            contact.bodyB.node?.removeFromParent();
            break;
        default:
            print(contactMask)
                    print(contact.bodyA.categoryBitMask);
                    print(" ");
                    print(contact.bodyB.categoryBitMask);
        }
        
        
    }
    
    func addTanks(){
        
        let tank = SKSpriteNode(imageNamed: "player2");
        
        // TODO: - Add the Physics for Collision here -
        
        tank.physicsBody = SKPhysicsBody(rectangleOf: tank.size);
        tank.physicsBody?.isDynamic = true;
        tank.physicsBody?.categoryBitMask = PhysicsCategory.Tank;
        tank.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Player;
        tank.physicsBody?.collisionBitMask = PhysicsCategory.None;
        tank.physicsBody?.affectedByGravity = false;
        
        //let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0));
        let tankMoveDuration = levelData.tankTime;
        
//        let tankSpawn = CGPoint(x: self.size.width , y: random(min:CGFloat(50), max:CGPoint(100)));
        let tankSpawn = CGPoint(x: self.size.width , y: 70);
        tank.position = tankSpawn;
        tank.zPosition = 3.0;
        
        let targetPoint = CGPoint(x: -tank.size.width/2, y: tank.position.y);
        
        let actionMove = SKAction.move(to: targetPoint, duration: TimeInterval(tankMoveDuration))
        let actionMoveDone = SKAction.removeFromParent() // This should Ideally be never called. Since either the tank collides with the player and he dies or the tank is destroyed before it can touch the player.
        
        self.addChild(tank);
        tank.run(SKAction.sequence([actionMove, actionMoveDone]))
        
//        while true {
            callTankProjectile(tank: tank);
//        }
        
        
        
        
    }
    
    func callTankProjectile(tank: SKSpriteNode){
        
        // MARK: - NPC projectile logic
        
        //let tankProjectile = SKSpriteNode(imageNamed: "projectile");
        let tankProjectile = SKEmitterNode(fileNamed: "SmokeTrail")!
        tankProjectile.targetNode = self;
        tankProjectile.position = CGPoint(x: tank.position.x - tank.size.width/3, y: 80);
        self.addChild(tankProjectile);
        
        // TODO: - Add the physics for projectiles.
        tankProjectile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20));
        tankProjectile.physicsBody?.isDynamic = true;
        tankProjectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile;
//        tankProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Player;
        tankProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        tankProjectile.physicsBody?.affectedByGravity = false;
        
        let tankProjectileAction = SKAction.move(to: CGPoint(x:player1Node.position.x,y:80), duration: levelData.tankProjectileTime)
        let tankProjectileActionDone = SKAction.removeFromParent();
        
        tankProjectile.run(SKAction.sequence([tankProjectileAction,tankProjectileActionDone]));
        
        
    }
    
    func addballoons(){
        
        let balloon = SKSpriteNode(imageNamed: "white_balloon");
        
        let balloonMoveDuration = levelData.balloonTime;
        let balloonSpawn = CGPoint(x: self.size.width , y: self.size.height/2 + CGFloat(arc4random_uniform(UInt32(self.size.height/2)) ) );
        
        balloon.xScale = 1;
        balloon.yScale = 1;
        //balloon.zRotation = .pi/4 ;
        balloon.position = balloonSpawn;
        balloon.zPosition = 3.0;
        balloon.color = UIColor.init(colorLiteralRed: (0.0..<1.0).random(), green: (0.0..<1.0).random(), blue: (0.0..<1.0).random(), alpha: Float(1));
        balloon.colorBlendFactor = 0.7;
        
        // MARK: - balloon Physics -
        balloon.physicsBody = SKPhysicsBody(rectangleOf: balloon.size);
        balloon.physicsBody?.isDynamic = true;
        balloon.physicsBody?.categoryBitMask = PhysicsCategory.balloon;
        balloon.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile;
        balloon.physicsBody?.collisionBitMask = PhysicsCategory.None;
        balloon.physicsBody?.affectedByGravity = false;
        
        let actionMove = SKAction.move(to: CGPoint(x: -balloon.size.width/2, y: balloon.position.y), duration: TimeInterval(balloonMoveDuration))
        let actionMoveDone = SKAction.removeFromParent() // This should Ideally be never called. Since either the tank collides with the player and he dies or the tank is destroyed before it can touch the player.
        
        self.addChild(balloon);
        balloon.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        // Figure out how to initiate a projectile from the balloon when the balloon actually gets to the middle of the screen dynamically instead of when it spawns.
        
//        while ( balloon.position == CGPoint(x: player1Node.position.x, y: self.size.height/2) ){
//            print("@@@@@@@@@");
//        }
        
        if randomBetween(min: 0, max: 3) > 1 {
            callballoonProjectile(balloon: balloon)
        }
    }
    
    func callballoonProjectile(balloon: SKSpriteNode){
        
        // MARK: - NPC projectile logic
        
        //let balloonProjectile = SKSpriteNode(imageNamed: "projectile");
        let balloonProjectile = SKEmitterNode(fileNamed: "SmokeTrail")!
        //balloonProjectile.xScale = 0.1;
        //balloonProjectile.yScale = 0.1;
        balloonProjectile.position = CGPoint(x: balloon.position.x - balloon.size.width/3, y: balloon.position.y);
        balloonProjectile.targetNode = self;
        self.addChild(balloonProjectile);
        
        //let direction = player1Node.position - balloon.position;
        
        // rotate projectile on shoot
        //balloonProjectile.zRotation = CGFloat.pi - atan(direction.x/direction.y)
        
        // TODO: - Add the physics for projectiles.
        balloonProjectile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20));
        balloonProjectile.physicsBody?.isDynamic = true;
        balloonProjectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile;
//        balloonProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Player;
        balloonProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        balloonProjectile.physicsBody?.affectedByGravity = false;
        
        let balloonProjectileAction = SKAction.move(to: CGPoint(x:player1Node.position.x,y:80), duration: levelData.balloonProjectileTime)
        let balloonProjectileActionDone = SKAction.removeFromParent();
        
        balloonProjectile.run(SKAction.sequence([balloonProjectileAction,balloonProjectileActionDone]));
        
        
    }
    
    func initialisePlayers(){
        
        player1Node = SKSpriteNode(imageNamed: "player1");
        player1Node.position = CGPoint(x: self.size.width/6, y: 70);
        player1Node.zPosition = 3.0
        
        // TODO: - Physics for the Player -
        
        player1Node.physicsBody = SKPhysicsBody(rectangleOf: player1Node.size);
        player1Node.physicsBody?.isDynamic = true;
        player1Node.physicsBody?.categoryBitMask = PhysicsCategory.Player;
        player1Node.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Tank;
        player1Node.physicsBody?.collisionBitMask = PhysicsCategory.None;
        player1Node.physicsBody?.affectedByGravity = false;
        
        
        player2Node = SKSpriteNode(imageNamed: "player2");
//        player2Node.xScale = 0.1;
//        player2Node.yScale = 0.1;
        player2Node.position = CGPoint(x: 5 * self.size.width/6, y: 70 );
        player2Node.zPosition = 3.0
    }
    
    func initLabel(label: SKLabelNode, gameData: GameData, text: String, pos: CGPoint){
        label.text = text;
        label.fontSize = gameData.fontSize;
        label.fontColor = gameData.fontColor;
        label.position = pos;
        label.zPosition = 3
    }
    
    var shootNSTimer = Timer();
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.location(in: self)
        
        // play shoot sound
        run(SKAction.playSoundFileNamed("Explosion2.wav", waitForCompletion: false))
        
        //        shootProjectile(touchLocation: touchLocation);
        
        // We need to shoot continously. We need to start creating a lot of projectiles. So, we need a function that creates a projectil and call that infinitely.
        isTouching = true;
        shootNSTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(LevelScene.shootProjectile), userInfo: nil, repeats: true)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil;
        isTouching = false;
        shootNSTimer.invalidate();
    }

    
    func shootProjectile(){
        
        guard touchLocation != nil else {
            print("Called shootProjectile with no valid position.");
            return;
        }
        
        // We need to shoot. So, we start with creating a new projectile.
        print("Projectile Launched");
        
        //let projectile = SKSpriteNode(imageNamed: "projectile");
        let projectile = SKEmitterNode(fileNamed: "SmokeTrail")!
        projectile.position = CGPoint(x: player1Node.position.x + player1Node.size.width/3, y: 80 );
        projectile.targetNode = self;
        //projectile.xScale = 0.1;
        //projectile.yScale = 0.3;
        
        self.addChild(projectile);
        
        var offset = (touchLocation! - projectile.position)
        if ( offset.y < 0 ){
            offset.y = 0;
        }
        if ( offset.x < 0 ){
            offset.x = 0;
        }
        let direction = offset.normalized();
        let projectileDest = direction * 2000 + projectile.position;
        
        // rotate projectile on shoot
        projectile.zRotation = 0 - atan(direction.x/direction.y)
        
        // MARK: - Physics for the projectile shot by the player.
        projectile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20,height: 20));
        projectile.physicsBody?.isDynamic = true;
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile;
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Tank;
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        projectile.physicsBody?.affectedByGravity = false;
        
        //        let projectileMove = SKAction.move(to: CGPoint(x:self.size.width,y:80), duration: 3.0);
        let projectileMove = SKAction.move(to: projectileDest, duration: 3.0);
        let projectileMoveDone = SKAction.removeFromParent();
        //        projectile.run(
        //            SKAction.repeatForever(
        //                SKAction.sequence(
        //                    [
        //                    SKAction.sequence(
        //                        [
        //                        projectileMove,
        //                        projectileMoveDone,
        //                        ]
        //                    ),
        //                    // TODO: -- The control never reaches this point since, the bullet never ends.
        //                    SKAction.wait(forDuration: 2)
        //                    ]
        //                )
        //            )
        //        );
        projectile.run(
            SKAction.repeatForever(
                SKAction.sequence(
                    [
                        projectileMove,
                        SKAction.wait(forDuration: 2),
                        projectileMoveDone,
                    ]
                )
            )
        );
    }
    
    func updateLabels(){
        self.gameData.currentLevel = currentLevel;
        if self.gameData.player1.lifes < 1 {
            self.sceneManager.loadGameOverScene();
        }
        if self.gameData.player1.score > ( 25 * currentLevel ) {
            // we move on to level 2
            
            let nextLevel = currentLevel + 1;
            var nextTankTime = levelData.tankTime - 1;
            var nextballoonDelayTime = levelData.balloonDelayTime - 1;
            var nextballoonProjectileTime = levelData.balloonProjectileTime - 0.1;
            var nextballoonTime = levelData.balloonTime - 0.1;
            var nextTankDelayTime = levelData.tankDelayTime - 1;
            var nextTankProjectileTime = levelData.tankProjectileTime - 1;
            
//            guard nextTankTime > 0 else {
//                nextTankTime = 1
//                return
//            }
//            guard nextballoonDelayTime > 0 else {
//                nextballoonDelayTime = 1
//                return
//            }
//            guard nextballoonProjectileTime > 0 else {
//                nextballoonProjectileTime = 1
//                return
//            }
//            guard nextballoonTime > 0 else {
//                nextballoonTime = 1
//                return
//            }
//            guard nextTankDelayTime > 0 else {
//                nextTankDelayTime = 1
//                return
//            }
//            guard nextTankProjectileTime > 0 else {
//                nextTankProjectileTime = 1
//                return
//            }
            
            // We will have to return from the function if we use guard. So we use if.
            
            check(value: &nextTankTime);
            check(value: &nextballoonDelayTime);
            check(value: &nextTankDelayTime);
            check(value: &nextballoonTime);
            check(value: &nextballoonProjectileTime);
            check(value: &nextTankProjectileTime);
            
            
            let nextLevelData: LevelData = LevelData(currentLevel: nextLevel, tankTime: nextTankTime, balloonTime: nextballoonTime, tankProjectileTime: nextTankProjectileTime, balloonProjectileTime: nextballoonProjectileTime, tankDelayTime: nextTankDelayTime, balloonDelayTime: nextballoonDelayTime );
            
            sceneManager.loadGameScene(level: nextLevelData);
        }
        player1LifeLabel.text = "Lives: \(self.gameData.player1.lifes)";
        player1ScoreLabel.text = "Score: \(self.gameData.player1.score)";
    }
    
    func check( value: inout Double){
        if value <= 1 {
            if value > 0 {
            value = value/2;
            }
            else{
                value = 1;
            }
        }
    }
    
    func randomBetween(min: Int, max: Int)->Int {
        return Int(UInt32(min) + arc4random_uniform(UInt32(max)));
    }
}

// http://stackoverflow.com/questions/25050309/swift-random-float-between-0-and-1
extension Range {
    public func random() -> Bound {
        let range = (self.lowerBound as! Float) - (self.upperBound as! Float)
        let randomValue = (Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * range + (self.upperBound as! Float)
        return randomValue as! Bound
    }
}
