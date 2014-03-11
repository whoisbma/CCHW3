//
//  MyScene.m
//  CatNapTutorial
//
//  Created by Bryan Ma on 2/27/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import "MyScene.h"
#import "SKSpriteNode+DebugDraw.h"
#import "SKTAudio.h"

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory) {
    CNPhysicsCategoryCat    = 1 << 0, //0001 = 1
    CNPhysicsCategoryBlock  = 1 << 1, //0010 = 2
    CNPhysicsCategoryBed    = 1 << 2, //0100 = 4
    CNPhysicsCategoryEdge   = 1 << 3, //1000 = 8
    CNPhysicsCategoryLabel  = 1 << 4, //10000 = 16
};
//defines three categories with bitwise shift operator, up to 32 categories max

@interface MyScene()<SKPhysicsContactDelegate>
//protocol defines two methods to implement - didBeginContact and didEndContact
@end

@implementation MyScene
{
    SKNode *_gameNode;  // will contain all objects in the current level
    SKSpriteNode *_catNode;  // cat sprite
    SKSpriteNode *_bedNode;  // bed sprite
    NSNumber *_bounceCount;
    
    int _currentLevel;
    int _bounceIntValue;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [self initializeScene];
    }
    return self;
}

- (void)initializeScene
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryEdge;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryLabel;
    //sets MyScene as the contact delegate of the scene's physics world. then assigned CNPhysicsCategoryEdge as the body's category.
    
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"]; // creates an edge loop around the screen
    bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild: bg]; // adds background to the screen
    [self addCatBed];
    _gameNode = [SKNode node];
    [self addChild:_gameNode];
    _currentLevel = 1;
    [self setupLevel: _currentLevel];
    //creates a new node, stored in _gamenode, added to scene, then set value of current level to 1 and pass it to setupLevel so that it loads level1.plist and builds the level on the scene.
}

- (void)addCatBed
{
    _bedNode = [SKSpriteNode spriteNodeWithImageNamed:@"cat_bed"];
    _bedNode.position = CGPointMake(270, 15);
    [self addChild:_bedNode];
    CGSize contactSize = CGSizeMake(40,30);
    _bedNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize]; //uses 40x30 rectangle for physics of bed
    _bedNode.physicsBody.dynamic = NO; //never apply any forces to the object
    [_bedNode attachDebugRectWithSize:contactSize];
    
    _bedNode.physicsBody.categoryBitMask = CNPhysicsCategoryBed;
    //sets bed's physics body category, leaves bit mask collider at default (collides with all)
}

- (void) addCatAtPosition:(CGPoint)pos
{
    //add the cat in the level on its starting position
    _catNode = [SKSpriteNode spriteNodeWithImageNamed:@"cat_sleepy"];
    _catNode.position = pos;
    
    [_gameNode addChild:_catNode];
    
    CGSize contactSize = CGSizeMake(_catNode.size.width-40, _catNode.size.height-10);
    _catNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
    [_catNode attachDebugRectWithSize: contactSize];
    //creates a physics body for the cat by using a size smaller than the actual texture size
    
    //assign cat's physics category
    _catNode.physicsBody.categoryBitMask = CNPhysicsCategoryCat;
    //collisionBitMask left at default - collide with all
    
    _catNode.physicsBody.contactTestBitMask = CNPhysicsCategoryBed | CNPhysicsCategoryEdge;
    
    _catNode.physicsBody.collisionBitMask = CNPhysicsCategoryBlock|CNPhysicsCategoryEdge;
}

- (void) setupLevel:(int)levelNum
{
    //load the plist file
    NSString *fileName = [NSString stringWithFormat:@"level%i", levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self addCatAtPosition: CGPointFromString(level[@"catPosition"])];
    //takes a level number, reads the property list for that level, sets up the scene
    //builds the file name then load the property list into an NSDictionary called level
    
    [self addBlocksFromArray:level[@"blocks"]];
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"bgMusic.mp3"];
    
}

- (void) addBlocksFromArray:(NSArray*)blocks
{
    //1 take a list of blocks as defined in the .plist and loop over the list
    for (NSDictionary *block in blocks) {
        //2 for each block, create a CGRect from the rect key of each block object, then call another helper method which creates a block sprite for you, then add it to the scene with addChild
        SKSpriteNode *blockSprite = [self addBlockWithRect:CGRectFromString(block[@"rect"])];
        
        //set category and collision bit masks for each block
        blockSprite.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
        blockSprite.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
        //assigns each block's physics body to the block category, then set them to collide with both the cat and block categories (with bitwise OR |)
        
        [_gameNode addChild:blockSprite];
    }
}

- (SKSpriteNode*)addBlockWithRect:(CGRect)blockRect
{
    //3  depending on the block size, need an image in the format widthxheight.png
    NSString *textureName = [NSString stringWithFormat:@"%.fx%.f.png",blockRect.size.width, blockRect.size.height];
    //4  create the sprite with the texture name you already have and place it at the proper position
    SKSpriteNode *blockSprite = [SKSpriteNode spriteNodeWithImageNamed:textureName];
    blockSprite.position = blockRect.origin;
    //5  use CGRectInset to shrink the bounding box and create a physics body with the result
    CGRect bodyRect = CGRectInset(blockRect,2,2);
    blockSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bodyRect.size];
    //6  add a debug shape for the block's body
    [blockSprite attachDebugRectWithSize:blockSprite.size];
    return blockSprite;
}

- (void) touchesBegan: (NSSet *) touches withEvent:(UIEvent *) event
{
    [super touchesBegan:touches withEvent:event];
    
    //1 get the position of the touch in the scene
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //2 enumerate over all the bodies in the physics world of the current scene by passing the touch location and a block (takes in two parameters - a body and a boolean parameter called stop
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:
     ^(SKPhysicsBody *body, BOOL *stop) {
         // 3  since all destructible bodies are CNPhysicsCategoryBlock, easy to determine whether to destroy the current body. use the body's node property to access the SKNode represented by the physics body and call removeFromParent on it
         if (body.categoryBitMask == CNPhysicsCategoryBlock) {
             [body.node removeFromParent];
             *stop = YES; //4   set stop to YES so that the enumerator won't loop over the rest unneccessarily.
             
             //5  make the blocks pop with a sound
             [self runAction:[SKAction playSoundFileNamed:@"pop.mp3"waitForCompletion:NO]];
         }
     }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    //first add the categories of the two bodies that collided and store the result in collision. the two if statements check collision for the combinations of bodies.
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (CNPhysicsCategoryCat|CNPhysicsCategoryBed))
    {
        NSLog(@"SUCCESS");
        [self win];
    }
    if (collision == (CNPhysicsCategoryCat|CNPhysicsCategoryEdge))
    {
        NSLog(@"FAIL");
        [self lose];
    }
    if (collision == ((CNPhysicsCategoryLabel|CNPhysicsCategoryEdge) | (CNPhysicsCategoryEdge|CNPhysicsCategoryLabel)))  ///THE EXERCISE SAYS - "use the category bit mask to figure out which body is the label's body, and get a reference to that physics body's node (i.e. the label)
    {
        NSLog(@"Label impact");
        //_bounceCount = [NSNumber numberWithInt:1];
        //NSLog (@"Value = %f", _bounceIntValue);
    }
}

- (void)inGameMessage:(NSString*)text
{
    //1 - create a Sprite Kit label node
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
    label.text = text;
    label.fontSize = 64.0;
    label.color = [SKColor whiteColor];
    
    //2 set the physics body for the label and set it to collide with the edge of the screen. and make it bouncy.
    label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 10);
    label.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    label.physicsBody.collisionBitMask = CNPhysicsCategoryEdge;
    label.physicsBody.categoryBitMask = CNPhysicsCategoryLabel;
    label.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge;
    label.physicsBody.restitution = 0.7;
    
    //3 add the label to the scene
    [_gameNode addChild:label];
    
    //4 run a sequence action --waits for a bit, then removes the label from the screen
    //[label runAction: [SKAction sequence:@[
    //                                       [SKAction waitForDuration:3.0],
    //                                       [SKAction removeFromParent]]]];
}

-(void)newGame
{
    [_gameNode removeAllChildren];  //remove all sprites from _gameNode
    [self setupLevel: _currentLevel];   //load the level configuration and build everything anew
    [self inGameMessage:[NSString stringWithFormat:@"Level %i", _currentLevel]];
    //show a message to the player
}

-(void)lose
{
    //1 - disable further contact detection by setting _catNode's contact TestBitMask to 0 - disables the problem of receiving multiple contact messages.
    _catNode.physicsBody.contactTestBitMask = 0;
    [_catNode setTexture: [SKTexture textureWithImageNamed:@"cat_awake"]];
    
    //2 - play sound effect
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [self runAction:[SKAction playSoundFileNamed:@"lose.mp3"
                               waitForCompletion:NO]];
    [self inGameMessage:@"Try again ..."];
    
    //3 tell the user they lost and restart the level
    [self runAction: [SKAction sequence:
                      @[[SKAction waitForDuration:5.0],
                        [SKAction performSelector:@selector(newGame) onTarget:self]]]];
}

-(void)win
{
    //1 - make physics simulation no longer affect cat
    _catNode.physicsBody = nil;
    
    //2 - want to animate the cat onto the bed, so calculate the proper y-coord for the cat to settle down on, and use that with _bedNode's x-coord as the target
    CGFloat curlY = _bedNode.position.y + _catNode.size.height/2;
    CGPoint curlPoint = CGPointMake(_bedNode.position.x, curlY);
    
    //3 - run an action on _catNode to move the cat to target position while rotating zero degrees to ensure straightness
    [_catNode runAction:
     [SKAction group:
      @[[SKAction moveTo:curlPoint duration:0.66],
        [SKAction rotateToAngle:0 duration:0.5]]]];
    [self inGameMessage:@"Good job!"];
    
    //4 - show a success message and restart level.
    [self runAction:
     [SKAction sequence:
      @[[SKAction waitForDuration:5.0],
        [SKAction performSelector:@selector(newGame) onTarget:self]]]];
    
    //5 - animate teh cat
    [_catNode runAction:
     [SKAction animateWithTextures:
      @[[SKTexture textureWithImageNamed:@"cat_curlup1"],
        [SKTexture textureWithImageNamed:@"cat_curlup2"],
        [SKTexture textureWithImageNamed:@"cat_curlup3"]]
                      timePerFrame:0.25]];
    
    //6 - play win sound
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [self runAction:[SKAction playSoundFileNamed:@"win.mp3" waitForCompletion:NO]];
}

@end
