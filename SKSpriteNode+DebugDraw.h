//
//  SKSpriteNode+DebugDraw.h
//  CatNapTutorial
//
//  Created by Bryan Ma on 3/2/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)s;
- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath;

@end
