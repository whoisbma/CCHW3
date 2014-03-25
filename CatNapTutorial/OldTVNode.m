//
//  OldTVNode.m
//  CatNapTutorial
//
//  Created by Bryan Ma on 3/25/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import "OldTVNode.h"
#import <AVFoundation/AVFoundation.h>
#import "Physics.h"

@implementation OldTVNode
{
    AVPlayer *_player;
    SKVideoNode *_videoNode;
}

-(id)initWithRect:(CGRect)frame
{
    //1 initialize the SKSpriteNode superclass with the initWithImageNamed method, passing in a string @"tv", to load tv.png
    // as this is the parent node, all the child nodes that you add will be drawn on top of this node
    
    if (self = [super initWithImageNamed:@"tv"]) {
        self.name = @"TVNode"; //set the name of the node in order to look it up later
        
        //2 set up an SKCropNode to crop another node so it fits within the TV screen image
        //tv-mask is the same size and shape as the screen in tv.png
        //set the mask's size and position with the frame parameter
        
        SKSpriteNode *tvMaskNode = [SKSpriteNode spriteNodeWithImageNamed:@"tv-mask"];
        tvMaskNode.size = frame.size;
        SKCropNode *cropNode = [SKCropNode node];
        cropNode.maskNode = tvMaskNode;
        
        //3 set up the AVPlayer to play a local movie file
        NSURL *fileURL = [NSURL fileURLWithPath:
                          [[NSBundle mainBundle] pathForResource:@"loop"
                                                          ofType:@"mov"]];
        _player = [AVPlayer playerWithURL:fileURL];
        
        //4 create an SKVideoNode passing in the AVPlayer, and set the size and position of the video node
        
        _videoNode = [[SKVideoNode alloc] initWithAVPlayer:_player];
        _videoNode.size = CGRectInset(frame, frame.size.width * 0.15, frame.size.height * 0.27).size;
        _videoNode.position = CGPointMake(-frame.size.width * 0.1, -frame.size.height * 0.06);
        
        //using CGRectInset function to easily shrink the video's height and width by some percentage of the width and height of the input rectangle
        
        //5 adding the SKVideoNode as a child of the SKCropNode so it will crop to the inside of the TV screen
        // then add the crop node as a child of the main node
        
        [cropNode addChild:_videoNode];
        [self addChild:cropNode];
        
        //6 set the position and size of self based on the input frame
        self.position = frame.origin;
        self.size = frame.size;
        
        _player.volume = 0.0;
        
        CGRect bodyRect = CGRectInset(frame, 2, 2);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: bodyRect.size];
        self.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
        self.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
        
        [_videoNode play];
        
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter]
         addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
             [_player seekToTime:kCMTimeZero];
         }];
        
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
    
@end
