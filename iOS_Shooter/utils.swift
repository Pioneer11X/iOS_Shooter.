//
//  utils.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 15/10/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import Foundation
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
    var balloonTime: Double;
    var tankProjectileTime: Double;
    var balloonProjectileTime: Double;
    var tankDelayTime: Double;
    var balloonDelayTime: Double;
    var shootChance: Double;
}

struct GameState{
    static var isPaused: Bool = false;
}
