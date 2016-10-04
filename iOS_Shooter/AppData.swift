//
//  AppData.swift
//  iOS_Shooter
//
//  Created by Sravan Karuturi on 03/10/16.
//  Copyright © 2016 Sravan Karuturi. All rights reserved.
//

import Foundation

class AppData{
    
    static let staticData = AppData();
    
    var highScoreKey: String = "highscore";
    
    var highScore: Int = 0{
        didSet{
            let defaults = UserDefaults.standard;
            defaults.set(highScore, forKey: highScoreKey)
        }
    };
    
    private init(){
        readDefaultData();
        print("Can't initialise out of the class");
    }
    
    private func readDefaultData(){
        let defaults = UserDefaults.standard;
        highScore = defaults.integer(forKey: highScoreKey);
    }
    
}
