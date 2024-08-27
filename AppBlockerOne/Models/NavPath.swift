//
//  NavPath.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/27/24.
//

import Foundation

@Observable class NavManager {
    var pathStack: [NavPath] = []
    
    func navTo(_ navPath: NavPath){
        pathStack.append(navPath)
    }
    
    func navTo(_ pathId: String){
        pathStack.append(NavPath(pathId: pathId))
    }
    
    func goBack(){
        var _ = pathStack.popLast()
    }
}

struct NavPath: Hashable, Equatable {
    var pathId: String
    var appGroup: AppGroup? = nil
    
    init(pathId: String, appGroup: AppGroup? = nil) {
        self.pathId = pathId
        self.appGroup = appGroup
    }
    
    static func == (lhs: NavPath, rhs: NavPath) -> Bool {
        return lhs.pathId == rhs.pathId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pathId)
    }
}
