//
//  level1.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 24/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;
import Foundation;




class LevelScene: SKScene, SKPhysicsContactDelegate {
    
    
    // MARK: - iVars for Levels
    
    var currentLevel: Int;
    var levelData: LevelData;
    var backgroundNode: SKSpriteNode! ;
    var player1Node : SKSpriteNode! ;
    var player1Turret : SKSpriteNode! ;
    var player1ScoreLabel: SKLabelNode! ;
    var highScoreLabel: SKLabelNode! ;
    var levelLabel: SKLabelNode! ;
    var player1LifeLabel: SKLabelNode! ;
    var bigLevelLabel: SKLabelNode! ;
    var comboLabel: SKLabelNode!;
    var newWeaponLabel: SKLabelNode!;
    var levelTimerLabel: SKLabelNode!;
    var gameData: GameData;
    var groundNode: SKSpriteNode! ;
    var sceneManager: GameViewController;
    var topBulletCollector: SKSpriteNode!;
    var btmBulletCollector: SKSpriteNode!;
    var isTouching: Bool;
    var touchLocation: CGPoint?;
    var touchCooldown: Bool;
    var weapon: String = "simpleGun";
    var combo: Int = 0;
    var comboEndTimer: Timer!;
    var comboEndInterval: Double = 1;
    var secondsLeft: Int = 30;
    
    // MARK: - Pausing Labels -
    var pauseTextLabel: SKLabelNode!;
    
    
    // MARK: - Pausing variables
    var resumeImageLabel: SKSpriteNode;
    var reloadLevelLabel: SKSpriteNode;
    var goToMainMenuLabel: SKSpriteNode;
    
    // MARK: - Pausing Logic
    var gameLoopPaused:Bool = false{
        didSet{
            print("gameLoopPaused=\(gameLoopPaused)");
            //gameLoopPaused?runPause
        }
    }
    
    private func runPauseAction(){
        print(#function);
        
        self.pauseTextLabel.text = "Resume";
        self.addChild(resumeImageLabel);
        self.addChild(reloadLevelLabel);
        self.addChild(goToMainMenuLabel);
        
//        pauseTextLabel.removeFromParent();
//        self.addChild(pauseTextLabel);
        let waitAction = SKAction.wait(forDuration: 0.1);
        run(SKAction.sequence([
            waitAction,
            SKAction.run {
                self.view?.isPaused = true;
                self.physicsWorld.speed = 0.0;
            }
            ]))
        
        
    }
    
    private func runUnpauseAction(){
        print(#function);
        print(gameLoopPaused);
        
        self.view?.isPaused = false;
        self.physicsWorld.speed = 1.0;
        pauseTextLabel.text = "Pause";
        resumeImageLabel.removeFromParent();
        reloadLevelLabel.removeFromParent();
        goToMainMenuLabel.removeFromParent();
        

    }
    
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
        bigLevelLabel = SKLabelNode(fontNamed: gameData.fontName);
        levelLabel = SKLabelNode(fontNamed: gameData.fontName);
        player1LifeLabel = SKLabelNode(fontNamed: gameData.fontName);
        highScoreLabel = SKLabelNode(fontNamed: gameData.fontName);
        comboLabel = SKLabelNode(fontNamed: gameData.fontName);
        newWeaponLabel = SKLabelNode(fontNamed: gameData.fontName);
        levelTimerLabel = SKLabelNode(fontNamed: gameData.fontName);
        pauseTextLabel = SKLabelNode(fontNamed: gameData.fontName);
        
        self.gameData = gameData;
        self.currentLevel = levelData.currentLevel;
        self.levelData = levelData;
        self.sceneManager = sceneManager;
        
        backgroundNode = SKSpriteNode(imageNamed: "birthday-background-placeholder");
        groundNode = SKSpriteNode(imageNamed: "ground");
        
        btmBulletCollector = SKSpriteNode(imageNamed: "projectile");
        topBulletCollector = SKSpriteNode(imageNamed: "projectile");
        
        resumeImageLabel = SKSpriteNode(imageNamed: "play-button.png");
        reloadLevelLabel = SKSpriteNode(imageNamed: "play-button.png");
        goToMainMenuLabel = SKSpriteNode(imageNamed: "play-button.png");
        
        
        isTouching = false;
        touchLocation = nil;
        
        touchCooldown = false;
        
        super.init(size:size);
        
        resumeImageLabel.alpha = 0.7;
        resumeImageLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2);
        resumeImageLabel.xScale = 0.5;
        resumeImageLabel.yScale = 0.5;
        resumeImageLabel.zPosition = 5.0;
        
        reloadLevelLabel.alpha = 0.7;
        reloadLevelLabel.position = CGPoint(x: 3 * self.size.width/4, y: self.size.height/2);
        reloadLevelLabel.xScale = 0.3;
        reloadLevelLabel.yScale = 0.3;
        reloadLevelLabel.zPosition = 5.0;
        
        goToMainMenuLabel.alpha = 0.7;
        goToMainMenuLabel.position = CGPoint(x: self.size.width/4, y: self.size.height/2);
        goToMainMenuLabel.xScale = 0.3;
        goToMainMenuLabel.yScale = 0.3;
        goToMainMenuLabel.zPosition = 5.0;
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        
        GameState.isPaused = false;
        
        self.physicsWorld.contactDelegate = self;
        
        initLabel(label: levelLabel, gameData: gameData, text: "Round: \(currentLevel)", pos: CGPoint(x: self.size.width/2 , y: self.size.height - 50 ) );
        initLabel(label: player1ScoreLabel, gameData: gameData, text: "Score: \(gameData.player1.score)", pos: CGPoint(x: self.size.width/4, y: self.size.height - 50 ) );
        initLabel(label: player1LifeLabel, gameData: gameData, text: "Lives: \(gameData.player1.lifes)", pos: CGPoint(x: self.size.width/4, y: self.size.height - 100 ) );
        initLabel(label: bigLevelLabel, gameData: gameData, text: "LEVEL UP!", pos: CGPoint(x: self.size.width/2, y: self.size.height/2 ) );
        initLabel(label: newWeaponLabel, gameData: gameData, text: "Basic Gun", pos: CGPoint(x: self.size.width/2 , y: self.size.height/2 ) );
        initLabel(label: highScoreLabel, gameData: gameData, text: "Highscore: \(AppData.staticData.highScore)", pos: CGPoint(x: 3 * self.size.width/4, y: self.size.height - 100 ) );
        initLabel(label: levelTimerLabel, gameData: gameData, text: "30", pos: CGPoint(x: self.size.width/2 , y: self.size.height/4 ) );
        initLabel(label: pauseTextLabel, gameData: gameData, text: "Pause", pos: CGPoint(x: 3 * self.size.width/4 , y: self.size.height - 50 ) );
        
        
        levelTimerLabel.fontColor = UIColor.black;
        levelTimerLabel.fontSize = gameData.fontSize * 30;
        levelTimerLabel.zPosition = 0;
        levelTimerLabel.alpha = 0.2;
        newWeaponLabel.fontColor = UIColor.black;
        newWeaponLabel.fontSize = gameData.fontSize * 2;
        newWeaponLabel.run(SKAction.sequence(
            [SKAction.fadeAlpha(to: 1, duration: 0.1),
             SKAction.fadeAlpha(to: 0, duration: 1)]
        ));
        // combo label
        comboLabel.text = "";
        comboLabel.fontSize = gameData.fontSize * 10;
        comboLabel.fontColor = UIColor.red;
        comboLabel.zPosition = 3
        bigLevelLabel.fontSize = 100;
        
        groundNode.position = CGPoint(x: self.size.width/2, y: 10 );
        groundNode.zPosition = 2.0
        
        backgroundNode.zPosition = -1;
        backgroundNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2);
        
        topBulletCollector.position = CGPoint(x: 0, y: self.size.height);
        btmBulletCollector.position = CGPoint(x: self.size.width, y: 0);
        topBulletCollector.xScale = 5;
        btmBulletCollector.zRotation = .pi/2;
        btmBulletCollector.xScale = 5;
        
        
        initPhysics(bulletCollector: topBulletCollector);
        initPhysics(bulletCollector: btmBulletCollector);
        
        
        
        self.addChild(topBulletCollector);
        self.addChild(btmBulletCollector);
        self.addChild(highScoreLabel);
        self.addChild(comboLabel);
        self.addChild(backgroundNode);
        
        // background music
        let backgroundMusic = SKAudioNode(fileNamed: "Super Power Cool Dude")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        initialisePlayers();
        
        self.addChild(player1ScoreLabel);
        self.addChild(bigLevelLabel);
        self.addChild(player1LifeLabel);
        self.addChild(levelLabel);
        self.addChild(newWeaponLabel);
        self.addChild(groundNode);
        self.addChild(player1Node);
        self.addChild(player1Turret);
        self.addChild(levelTimerLabel);
        self.addChild(pauseTextLabel);
        
        self.run(SKAction.repeatForever( SKAction.sequence(
            [
                SKAction.run({
                    self.secondsLeft -= 1;
                    self.levelTimerLabel.text = "\(self.secondsLeft)";
                }),
                SKAction.wait(forDuration: 1)
            ])));
        
        
        // show level up if new level
        if (currentLevel > 1) {
            bigLevelLabel.run(
                SKAction.sequence([
                SKAction.repeat(
                    SKAction.sequence( [
                        SKAction.scale(by: 0.5, duration: 0.3),
                        SKAction.scale(by: 2, duration: 0.3)
                        ]), count: 5),
                SKAction.removeFromParent()]))

        } else {
            bigLevelLabel.removeFromParent()
        }
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: levelData.balloonDelayTime),
                SKAction.run(addballoons)
                ])
        ))
        
    }
    
    // MARK: - Begin Contact -
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask;
        
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
        // MARK: - Projectile Shot -
        case 6:
            // You shot down a projectile coming towards you.
            // boom
            let explosionEffect = SKEmitterNode.init(fileNamed: "Pop");
            var validNode:SKNode!;
            if let aNode = contact.bodyA.node {
                validNode = aNode;
                
            } else {
                if let bNode = contact.bodyB.node {
                    validNode = bNode;
                }
            }
            // get a new weapon
            getRandomWeapon();
            // show the new weapon
            showNewWeaponText(origin: validNode!.position);
            
            // explosion!
            explosionEffect?.position = validNode!.position;
            explosionEffect?.targetNode = self;
            explosionEffect?.particleSize = CGSize.init(width: 20, height: 20);
            self.addChild(explosionEffect!);
            explosionEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.removeFromParent()]))
            if (weapon == "tunnelGun") {
                // remove enemy projectile
                if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                    contact.bodyA.node?.removeFromParent();
                } else {
                    contact.bodyB.node?.removeFromParent();
                }
                
                break;
            }
            else {
                // remove
                contact.bodyA.node?.removeFromParent();
                contact.bodyB.node?.removeFromParent();
            }
            
            run(SKAction.playSoundFileNamed("Explosion3.wav", waitForCompletion: false))
            break;
        // MARK: - Player Shot -
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
        // MARK: - Balloon Shot -
        case 20:
            // You shot the balloon.
            // balloon ref
            var balloon:SKSpriteNode?;
            var shot:SKEmitterNode?;
            if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                balloon = contact.bodyB.node as? SKSpriteNode
                shot = contact.bodyA.node as? SKEmitterNode
            } else {
                balloon = contact.bodyA.node as? SKSpriteNode
                shot = contact.bodyB.node as? SKEmitterNode
            }
            if let b:SKSpriteNode = balloon {
                // boom
                let explosionEffect = SKEmitterNode.init(fileNamed: "Pop");
                explosionEffect?.position = b.position;
                explosionEffect?.targetNode = self;
                self.addChild(explosionEffect!);
                explosionEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.removeFromParent()]));
                // confetti
                let confetti = SKEmitterNode.init(fileNamed: "Confetti");
                confetti?.position = b.position;
                
                // get new color
                confetti?.particleColorSequence = nil;
                confetti?.particleColorBlendFactor = 1.0;
                confetti?.particleColor = b.color;
                confetti?.targetNode = self;
                self.addChild(confetti!);
                confetti?.run(SKAction.sequence([SKAction.wait(forDuration: 2),SKAction.removeFromParent()]));
                
                switch (weapon) {
                case "simpleGun":
                    b.removeFromParent();
                    shot?.removeFromParent();
                        break;
                case "chainReactionGun":
                    // chain reaction
                    for _ in (0..<3) {
                        makeExplosionProjectile(origin: b.position,
                                                direction: CGPoint.init(x: Double((Float(-1)..<Float(1)).random()),
                                                                        y: Double((Float(-1)..<Float(1)).random())));
                    }
                    b.removeFromParent();
                    shot?.removeFromParent();
                    break;
                    
                case "tunnelGun":
                    b.removeFromParent();
                    break;
                    
                default:
                    b.removeFromParent();
                    shot?.removeFromParent();
                    break;
                }
                // clear timer
                comboEndTimer?.invalidate();
                // start next timer
                comboEndTimer = Timer.scheduledTimer(timeInterval: comboEndInterval, target: self, selector: #selector(LevelScene.endCombo), userInfo: nil, repeats: false);
                // combo up!
                combo += 1;
                // show the combo ui
                showCombo(origin: b.position);
            }
            
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
    
    func showCombo(origin:CGPoint) {
        comboLabel.text = "X\(combo)";
        comboLabel.removeAllActions();
        comboLabel.alpha = 1;
        comboLabel.xScale = 0.1;
        comboLabel.yScale = 0.1;
        comboLabel.position = origin;
        comboLabel.run(SKAction.fadeAlpha(to: 0, duration: comboEndInterval));
        comboLabel.run(SKAction.scale(by: 20, duration: comboEndInterval));
    }
    
    func endCombo() {
        combo = 0;
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
        let balloonSpawn = CGPoint(x: self.size.width , y: self.size.height * 0.1 + CGFloat(arc4random_uniform(UInt32(self.size.height * 0.8)) ) );
        
        balloon.alpha = 0.8;
        balloon.xScale = 1;
        balloon.yScale = 1;
        //balloon.zRotation = .pi/4 ;
        balloon.position = balloonSpawn;
        balloon.zPosition = 3.0;
        balloon.color = UIColor.init(colorLiteralRed: (0.0..<1.0).random(), green: (0.0..<1.0).random(), blue: (0.0..<1.0).random(), alpha: Float(1));
        balloon.colorBlendFactor = 0.7;
        
        // bob effect
        let rot:SKAction = SKAction.repeatForever(SKAction.sequence(
            [SKAction.rotate(byAngle: .pi/4.0, duration: 1),
             SKAction.rotate(byAngle: -.pi/4.0, duration: 1)]));
        balloon.run(SKAction.repeatForever(rot));
        
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
        
        let balloonProjectile = SKSpriteNode(imageNamed: "Birthday-Present-Transparent");
        balloonProjectile.zPosition = 4;
        let balloonProjEffect = SKEmitterNode(fileNamed: "SmokeTrail")!
        balloonProjectile.xScale = 0.05;
        balloonProjectile.yScale = 0.05;
        balloonProjEffect.particleSize = CGSize(width: 100, height: 100);
        balloonProjectile.position = CGPoint(x: balloon.position.x - balloon.size.width/3, y: balloon.position.y);
        //balloonProjEffect.position = CGPoint(x: balloon.position.x - balloon.size.width/3, y: balloon.position.y);
        balloonProjEffect.targetNode = self;
        self.addChild(balloonProjectile);
        balloonProjectile.addChild(balloonProjEffect);
        balloonProjEffect.position = CGPoint(x: 0, y: 0);
        // bob effect
        let rot:SKAction = SKAction.repeatForever(SKAction.sequence(
            [SKAction.rotate(byAngle: .pi/4.0, duration: 0.1),
             SKAction.rotate(byAngle: -.pi/4.0, duration: 0.1)]));
        balloonProjectile.run(SKAction.repeatForever(rot));
        
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
        //balloonProjEffect.run(SKAction.sequence([balloonProjectileAction,balloonProjectileActionDone]));
        
        
    }
    
    func initialisePlayers(){
        
        player1Node = SKSpriteNode(imageNamed: "pixel-tank_party");
        player1Node.position = CGPoint(x: self.size.width/6, y: 70);
        player1Node.zPosition = 3.0
        
        player1Turret = SKSpriteNode(imageNamed: "pixel-tank_turret")
        player1Turret.position = CGPoint(x: self.size.width/6 - 1, y: 60);
        player1Turret.zPosition = 2.0
        
        // TODO: - Physics for the Player -
        
        player1Node.physicsBody = SKPhysicsBody(rectangleOf: player1Node.size);
        player1Node.physicsBody?.isDynamic = true;
        player1Node.physicsBody?.categoryBitMask = PhysicsCategory.Player;
        player1Node.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Tank;
        player1Node.physicsBody?.collisionBitMask = PhysicsCategory.None;
        player1Node.physicsBody?.affectedByGravity = false;
        
    }
    
    func initLabel(label: SKLabelNode, gameData: GameData, text: String, pos: CGPoint){
        label.text = text;
        label.fontSize = gameData.fontSize;
        label.fontColor = gameData.fontColor;
        label.position = pos;
        label.zPosition = 3
    }
    
    func initPhysics(bulletCollector: SKSpriteNode){
        bulletCollector.physicsBody = SKPhysicsBody(rectangleOf: bulletCollector.size);
        bulletCollector.physicsBody?.isDynamic = true;
        bulletCollector.physicsBody?.categoryBitMask = PhysicsCategory.BulletCollector;
        bulletCollector.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.PlayerProjectile;
        bulletCollector.physicsBody?.collisionBitMask = PhysicsCategory.None;
        bulletCollector.physicsBody?.affectedByGravity = false;
        bulletCollector.zPosition = -1.0;
    }
    
    var shootNSTimer = Timer();
    
    // MARK: - Interactivity Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.location(in: self)
        isTouching = true;
        
        // Check if the scene is paused, and the user would like to resume.
        if gameLoopPaused{
            if self.resumeImageLabel.contains(touchLocation!){
                runUnpauseAction();
                gameLoopPaused = !gameLoopPaused;
                return;
            }else if self.reloadLevelLabel.contains(touchLocation!){
                reloadLevel();
                return;
            }else if self.goToMainMenuLabel.contains(touchLocation!){
                sceneManager.loadHomeScene();
                return;
            }
        }
        
        // touched tank
        if (touchLocation! - player1Node.position).length() < 50 {
            // do nothing
            return;
        }
        
        if ( pauseTextLabel.contains(touchLocation!) && !gameLoopPaused ){
            
            if ( !gameLoopPaused ){
                pauseTextLabel.text = "Unpause";
                runPauseAction();
//                self.sceneManager.loadPauseScene();
            } else {
                runUnpauseAction();
//                pauseTextLabel.text = "Pause";
            }
            gameLoopPaused = !gameLoopPaused;
            print(gameLoopPaused);
            return;
        }
        
        // get direction
        var offset = (touchLocation! - player1Node.position)
        if ( offset.y < 0 ){
            offset.y = 0;
        }
        if ( offset.x < 0 ){
            offset.x = 0;
        }
        let direction = offset.normalized();
        
        // rotate gun
        player1Turret.zRotation = .pi/2 - atan(direction.x/direction.y)
        
        // fire rate
        var fireRate:Double = 0.3;
        switch(weapon) {
            case "tunnelGun":
                fireRate = 0.5;
                break;
            default:
                break;
        }
        
        shootNSTimer = Timer.scheduledTimer(timeInterval: fireRate, target: self, selector: #selector(LevelScene.shootProjectile), userInfo: nil, repeats: true)
        if (self.touchCooldown == false) {
            shootProjectile();
            self.touchCooldown = true;
            run(SKAction.sequence([
                SKAction.wait(forDuration: fireRate),
                SKAction.run ({ self.touchCooldown = false })
                ]))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.location(in: self)
        
        // get direction
        var offset = (touchLocation! - player1Node.position)
        if ( offset.y < 0 ){
            offset.y = 0;
        }
        if ( offset.x < 0 ){
            offset.x = 0;
        }
        let direction = offset.normalized();
        
        // rotate gun
        player1Turret.zRotation = .pi/2 - atan(direction.x/direction.y)

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
        
        // play shoot sound
        run(SKAction.playSoundFileNamed("Explosion2.wav", waitForCompletion: false))
        
        // We need to shoot. So, we start with creating a new projectile.
        //print("Projectile Launched");
        
        //let projectile = SKSpriteNode(imageNamed: "projectile");
        var projectile:SKEmitterNode!
        // switch based on weapon
        if (weapon == "chainReactionGun") {
           projectile = SKEmitterNode(fileNamed: "ChainParticle")!
        } else {
           projectile = SKEmitterNode(fileNamed: "BigShot")!
        }
        projectile.position = CGPoint(x: player1Node.position.x + player1Node.size.width/3, y: 80 );
        projectile.targetNode = self;
        if (weapon == "tunnelGun") {
            projectile.particleSize = CGSize(width: 100, height: 100);
        }
        
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
        //projectile.zRotation = 0 - atan(direction.x/direction.y)
        
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
        
        // reset weapon
    }
    
    func makeExplosionProjectile(origin:CGPoint, direction:CGPoint) {
        let projectile = SKEmitterNode(fileNamed: "ChainParticle")!
        projectile.position = origin;
        projectile.targetNode = self;
        self.addChild(projectile);
        let projectileDest = direction * 2000 + projectile.position;
        
        // MARK: - Physics for the projectile shot by the player.
        projectile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20,height: 20));
        projectile.physicsBody?.isDynamic = true;
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile;
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Tank;
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        projectile.physicsBody?.affectedByGravity = false;
        
        //        let projectileMove = SKAction.move(to: CGPoint(x:self.size.width,y:80), duration: 3.0);
        let projectileMove = SKAction.move(to: projectileDest, duration: 1.0);
        let projectileMoveDone = SKAction.removeFromParent();

        projectile.run(
            SKAction.repeatForever(
                SKAction.sequence(
                    [
                        projectileMove,
                        SKAction.wait(forDuration: 1),
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
        if self.gameData.player1.score > ( 50 * currentLevel + 5 * currentLevel * currentLevel ) {
            // we move on to level 2
            
            self.gameData.player1.lifesAtLastLevel = self.gameData.player1.lifes;
            let nextLevel = currentLevel + 1;
            var nextTankTime = levelData.tankTime - 1;
            var nextballoonDelayTime = levelData.balloonDelayTime * 0.9;
            var nextballoonProjectileTime = levelData.balloonProjectileTime * 0.9;
            var nextballoonTime = levelData.balloonTime * 0.8;
            var nextTankDelayTime = levelData.tankDelayTime - 1;
            var nextTankProjectileTime = levelData.tankProjectileTime - 1;
            var nextShootChance = 0.05 + 0.1 * Double(currentLevel);
            
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
            check(value: &nextShootChance);
            
            
            let nextLevelData: LevelData = LevelData(currentLevel: nextLevel, tankTime: nextTankTime, balloonTime: nextballoonTime, tankProjectileTime: nextTankProjectileTime, balloonProjectileTime: nextballoonProjectileTime, tankDelayTime: nextTankDelayTime, balloonDelayTime: nextballoonDelayTime, shootChance: nextShootChance );
            
            sceneManager.loadGameScene(level: nextLevelData);
        }
        player1LifeLabel.text = "Lives: \(self.gameData.player1.lifes)";
        player1ScoreLabel.text = "Score: \(self.gameData.player1.score)";
        highScoreLabel.text = "Highscore: \(AppData.staticData.highScore)";
        if ( AppData.staticData.highScore < gameData.player1.score ){
            AppData.staticData.highScore = gameData.player1.score;
        }
    }
    
    func check( value: inout Double){
        if value <= 1 {
            if value > 0 {
            //value = value/2;
            }
            else{
                value = 1;
            }
        }
    }
    
    func randomBetween(min: Int, max: Int)->Int {
        return Int(UInt32(min) + arc4random_uniform(UInt32(max)));
    }
    
    func getRandomWeapon() {
        // sound
        run(SKAction.playSoundFileNamed("ChangeWeapon.wav", waitForCompletion: false))
        // Change weapon
        if (randomBetween(min: 0, max: 2) > 0) {
            weapon = "chainReactionGun";
        } else {
            weapon = "tunnelGun";
        }
    }
    
    func showNewWeaponText(origin:CGPoint) {
        if (randomBetween(min: 0, max: 2) > 0)
        {
            newWeaponLabel.text = "GOT: Sparkle Shot"
            weapon = "chainReactionGun";
        } else {
            newWeaponLabel.text = "GOT: Power Shot"
            weapon = "tunnelGun";
        }
        newWeaponLabel.removeAllActions();
        //newWeaponLabel.alpha = 0;
        newWeaponLabel.zPosition = 10; // move to front
        let emitter = SKEmitterNode(fileNamed: "SpecialParticle")!;
        self.addChild(emitter);
        emitter.zPosition = 9;
        emitter.xScale = 0.75;
        emitter.yScale = 0.75;
        emitter.position = origin;
        emitter.run(SKAction.move(to: CGPoint(x: 200, y: 150), duration: 0.1));
        newWeaponLabel.position = CGPoint(x: 200, y: 140);
        newWeaponLabel.alpha = 0;
        newWeaponLabel.run(SKAction.sequence(
            [SKAction.fadeAlpha(to: 1, duration: 0.5),
             SKAction.fadeAlpha(to: 0, duration: 0.1)]
        ));
    }
    
    private func reloadLevel(){
        // We need to reload the level. It means, we need to use the initialiser with the data we already passed it last time.
        self.gameData.player1.score = currentLevel * 50 + 5 * currentLevel * currentLevel;
        self.gameData.player1.lifes = self.gameData.player1.lifesAtLastLevel;
        sceneManager.loadGameScene(level: self.levelData);
        
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
