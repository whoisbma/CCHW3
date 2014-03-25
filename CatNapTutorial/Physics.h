//
//  Physics.h
//  CatNapTutorial
//
//  Created by Bryan Ma on 3/25/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory) {
    CNPhysicsCategoryCat    = 1 << 0, //0001 = 1
    CNPhysicsCategoryBlock  = 1 << 1, //0010 = 2
    CNPhysicsCategoryBed    = 1 << 2, //0100 = 4
    CNPhysicsCategoryEdge   = 1 << 3, //1000 = 8
    CNPhysicsCategoryLabel  = 1 << 4, //10000 = 16
    CNPhysicsCategorySpring = 1 << 5, //100000 = 32
    CNPhysicsCategoryHook   = 1 << 6, //1000000 = 64
};