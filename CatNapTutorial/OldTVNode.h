//
//  OldTVNode.h
//  CatNapTutorial
//
//  Created by Bryan Ma on 3/25/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface OldTVNode : SKSpriteNode

//use an initWithRect: initializer so that you can pass the position and size of the block in from the levels plist
- (id)initWithRect:(CGRect)frame;

@end
