//
//  SKSpriteNode+DebugDraw.m
//  CatNapTutorial
//
//  Created by Bryan Ma on 3/2/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import "SKSpriteNode+DebugDraw.h"

//disable debug drawing by setting this to NO
static BOOL kDebugDraw = YES;

@implementation SKSpriteNode (DebugDraw)

-(void)attachDebugFrameFromPath:(CGPathRef)bodyPath
{
    //1 - if debug draw is no, exit
    if (kDebugDraw == NO) return;
    //2 - create blank SKShapeNode instance
    SKShapeNode *shape = [SKShapeNode node];
    //3 - define the node's shape and other attributes
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    shape.lineWidth = 1.0;
    //4 - add the node as a child of the sprite itself
    [self addChild:shape];
}

-(void)attachDebugRectWithSize:(CGSize)s
//gets a CGSize as its sole parameter, creates a CGPath rectangle by using CGPathCreateWithRect
//use the method above to attach the rectangular shape to the sprite
{
    CGPathRef bodyPath = CGPathCreateWithRect(CGRectMake(-s.width/2, -s.height/2, s.width, s.height), nil);
    [self attachDebugFrameFromPath:bodyPath];
    CGPathRelease(bodyPath);
}

@end
