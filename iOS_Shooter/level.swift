//
//  level1.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 24/09/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import SpriteKit;

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
    var planeTime: Double;
    var tankProjectileTime: Double;
    var planeProjectileTime: Double;
    var tankDelayTime: Double;
    var planeDelayTime: Double;
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
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Tank   : UInt32 = 0b1
        static let Projectile: UInt32 = 0b10
        static let PlayerProjectile: UInt32 = 0b100;
        static let Player: UInt32 = 0b1000;
        static let Plane: UInt32 = 0b10000;
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
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addTanks),
                SKAction.wait(forDuration: levelData.tankDelayTime)
                ])
        ))
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: levelData.planeDelayTime),
                SKAction.run(addPlanes)
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
            // Do nothing. The tank/plane projectile hit with the tank.
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
            self.gameData.player1.lifes = 0;
            run(SKAction.playSoundFileNamed("Hurt.wav", waitForCompletion: false))
            updateLabels();
            self.sceneManager.loadGameOverScene();
            // TODO: - Call the End game Scene.
            break;
        case 20:
            // You shot the Plane.
            contact.bodyA.node?.removeFromParent();
            contact.bodyB.node?.removeFromParent();
            self.gameData.player1.score += 2;
            updateLabels();
            run(SKAction.playSoundFileNamed("Explosion1.wav", waitForCompletion: false))
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
        
//        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0));
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
        
        let tankProjectile = SKSpriteNode(imageNamed: "projectile");
        tankProjectile.xScale = 0.1;
        tankProjectile.yScale = 0.3;
        tankProjectile.position = CGPoint(x: tank.position.x - tank.size.width/3, y: 80);
        self.addChild(tankProjectile);
        
        // TODO: - Add the physics for projectiles.
        tankProjectile.physicsBody = SKPhysicsBody(rectangleOf: tankProjectile.size);
        tankProjectile.physicsBody?.isDynamic = true;
        tankProjectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile;
//        tankProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Player;
        tankProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        tankProjectile.physicsBody?.affectedByGravity = false;
        
        let tankProjectileAction = SKAction.move(to: CGPoint(x:player1Node.position.x,y:80), duration: levelData.tankProjectileTime)
        let tankProjectileActionDone = SKAction.removeFromParent();
        
        tankProjectile.run(SKAction.sequence([tankProjectileAction,tankProjectileActionDone]));
        
        
    }
    
    func addPlanes(){
        
        let plane = SKSpriteNode(imageNamed: "Spaceship");
        
        let planeMoveDuration = levelData.planeTime;
        let planeSpawn = CGPoint(x: self.size.width , y: self.size.height/2);
        
        plane.xScale = 0.2;
        plane.yScale = 0.2;
        plane.zRotation = .pi/2 ;
        plane.position = planeSpawn;
        plane.zPosition = 3.0;
        
        // MARK: - Plane Physics -
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size);
        plane.physicsBody?.isDynamic = true;
        plane.physicsBody?.categoryBitMask = PhysicsCategory.Plane;
        plane.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile;
        plane.physicsBody?.collisionBitMask = PhysicsCategory.None;
        plane.physicsBody?.affectedByGravity = false;
        
        let actionMove = SKAction.move(to: CGPoint(x: -plane.size.width/2, y: plane.position.y), duration: TimeInterval(planeMoveDuration))
        let actionMoveDone = SKAction.removeFromParent() // This should Ideally be never called. Since either the tank collides with the player and he dies or the tank is destroyed before it can touch the player.
        
        self.addChild(plane);
        plane.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        // Figure out how to initiate a projectile from the plane when the plane actually gets to the middle of the screen dynamically instead of when it spawns.
        
//        while ( plane.position == CGPoint(x: player1Node.position.x, y: self.size.height/2) ){
//            print("@@@@@@@@@");
//        }
        callPlaneProjectile(plane: plane)
        
    }
    
    func callPlaneProjectile(plane: SKSpriteNode){
        
        // MARK: - NPC projectile logic
        
        let planeProjectile = SKSpriteNode(imageNamed: "projectile");
        planeProjectile.xScale = 0.1;
        planeProjectile.yScale = 0.1;
        planeProjectile.position = CGPoint(x: plane.position.x - plane.size.width/3, y: self.size.height/2);
        self.addChild(planeProjectile);
        
        // TODO: - Add the physics for projectiles.
        planeProjectile.physicsBody = SKPhysicsBody(rectangleOf: planeProjectile.size);
        planeProjectile.physicsBody?.isDynamic = true;
        planeProjectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile;
//        planeProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Player;
        planeProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        planeProjectile.physicsBody?.affectedByGravity = false;
        
        let planeProjectileAction = SKAction.move(to: CGPoint(x:player1Node.position.x,y:80), duration: levelData.planeProjectileTime)
        let planeProjectileActionDone = SKAction.removeFromParent();
        
        planeProjectile.run(SKAction.sequence([planeProjectileAction,planeProjectileActionDone]));
        
        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // play shoot sound
        run(SKAction.playSoundFileNamed("Explosion2.wav", waitForCompletion: false))
        
        // We need to shoot. So, we start with creating a new projectile.
        
        let projectile = SKSpriteNode(imageNamed: "projectile");
        projectile.position = CGPoint(x: player1Node.position.x + player1Node.size.width/3, y: 80 );
        projectile.xScale = 0.1;
        projectile.yScale = 0.3;
        self.addChild(projectile);
        
        var offset = (touchLocation - projectile.position)
        if ( offset.y < 0 ){
            offset.y = 0;
        }
        let direction = offset.normalized();
        let projectileDest = direction * 2000 + projectile.position;
        
        // MARK: - Physics for the projectile shot by the player.
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size);
        projectile.physicsBody?.isDynamic = true;
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile;
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile + PhysicsCategory.Tank;
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None;
        projectile.physicsBody?.affectedByGravity = false;
        
//        let projectileMove = SKAction.move(to: CGPoint(x:self.size.width,y:80), duration: 3.0);
        let projectileMove = SKAction.move(to: projectileDest, duration: 3.0);
        let projectileMoveDone = SKAction.removeFromParent();
        projectile.run(SKAction.sequence([
            projectileMove,
            projectileMoveDone
            ]));
    }
    
    func updateLabels(){
        if self.gameData.player1.lifes < 1 {
            self.sceneManager.loadGameOverScene();
        }
        player1LifeLabel.text = "Lives: \(self.gameData.player1.lifes)";
        player1ScoreLabel.text = "Score: \(self.gameData.player1.score)";
    }
}
