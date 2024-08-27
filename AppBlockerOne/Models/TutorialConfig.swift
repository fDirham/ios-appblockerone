//
//  TutorialConfig.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import Foundation

@Observable class TutorialConfig {
    var isTutorial = false
    var tutorialStage: Int = 0
    var tutorialTapCount: Int = 0
    
    init(isTutorial: Bool = false, tutorialStage: Int = 0) {
        self.isTutorial = isTutorial
        self.tutorialStage = tutorialStage
    }
    
    func triggerEndStage(forStage: Int){
        if !isTutorial {
            return
        }
        
        if tutorialStage == forStage {
           tutorialStage += 1
        }
    }
}
