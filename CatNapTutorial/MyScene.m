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
#import "SKTUtils.h" //imports library of helper methods
#import "OldTVNode.h"
#import "Physics.h"

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
    
    BOOL _isHooked;
    
    SKSpriteNode *_hookBaseNode;
    SKSpriteNode *_hookNode;
    SKSpriteNode *_ropeNode;
    
    SKSpriteNode *_seesawBaseNode;
    SKSpriteNode *_seesawNode;
    
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

- (void) addSeesawAtPosition:(CGPoint)seesawPosition
{
    //_seesawBaseNode = nil;
    //_seesawNode = nil;
    
    _seesawBaseNode = [SKSpriteNode spriteNodeWithImageNamed:@"45x45"];
    _seesawBaseNode.position = CGPointMake(seesawPosition.x, seesawPosition.y);
    _seesawBaseNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_seesawBaseNode.size];
    _seesawBaseNode.physicsBody.categoryBitMask = 0;
    _seesawBaseNode.physicsBody.collisionBitMask = 0;
    [_gameNode addChild:_seesawBaseNode];
    
    SKPhysicsJointFixed *seesawFix = [SKPhysicsJointFixed
                                      jointWithBodyA:_seesawBaseNode.physicsBody
                                      bodyB:self.physicsBody
                                      anchor:CGPointZero];
    [self.physicsWorld addJoint:seesawFix];
    
    _seesawNode = [SKSpriteNode spriteNodeWithImageNamed:@"430x30"];
    _seesawNode.position = CGPointMake(seesawPosition.x, seesawPosition.y);
    _seesawNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_seesawNode.size];
    _seesawNode.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
    _seesawNode.physicsBody.collisionBitMask = CNPhysicsCategoryCat | CNPhysicsCategoryBlock;
    
    [_gameNode addChild:_seesawNode];
    
    SKPhysicsJointPin *seesawJoint = [SKPhysicsJointPin jointWithBodyA:_seesawBaseNode.physicsBody
                                                                 bodyB:_seesawNode.physicsBody
                                                                anchor:CGPointMake(seesawPosition.x, seesawPosition.y)];
    [self.physicsWorld addJoint:seesawJoint];
}

- (void) addHookAtPosition:(CGPoint)hookPosition
{
    _hookBaseNode = nil;
    _hookNode = nil;
    _ropeNode = nil;
    _isHooked = NO;
    
    //initializes the hook struture - will pass to this method the hook key from the .plist
    //this code cleans up the instance variables and makes sure there is a hook object found in the .plist data
    
    _hookBaseNode = [SKSpriteNode spriteNodeWithImageNamed:@"hook_base"];
    _hookBaseNode.position = CGPointMake(hookPosition.x, hookPosition.y - _hookBaseNode.size.height/2);
    _hookBaseNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hookBaseNode.size];
    [_gameNode addChild:_hookBaseNode];
    
    //creates the piece attached to the ceiling along with its physics body, positions them at the top
    
    SKPhysicsJointFixed *ceilingFix = [SKPhysicsJointFixed
                                       jointWithBodyA:_hookBaseNode.physicsBody
                                       bodyB:self.physicsBody
                                       anchor:CGPointZero];
    [self.physicsWorld addJoint:ceilingFix];
    //use SKPhysicsJointFixed factory method to get an instance of a joint between the _hookBaseNode's body and the scene's own body, which is the edge loop.
    //then provide a CGPoint to tell the scene where to create the connection between the two bodies.
    
    _ropeNode = [SKSpriteNode spriteNodeWithImageNamed:@"rope"];
    _ropeNode.anchorPoint = CGPointMake(0, 0.5);
    _ropeNode.position = _hookBaseNode.position;
    [_gameNode addChild: _ropeNode];
    
    _hookNode = [SKSpriteNode spriteNodeWithImageNamed:@"hook"];
    _hookNode.position = CGPointMake(hookPosition.x, hookPosition.y-63);
    _hookNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_hookNode.size.width/2];
    _hookNode.physicsBody.categoryBitMask = CNPhysicsCategoryHook;
    _hookNode.physicsBody.contactTestBitMask = CNPhysicsCategoryCat;
    _hookNode.physicsBody.collisionBitMask = kNilOptions;
    [_gameNode addChild: _hookNode];
    //create a sprite, set position, create physics body
    //set category bitmask to CNPhysicsCategoryHook and instruct the physics world to detect contacts between the hook and the cat
    //position the hook just under the ceiling base
    
    SKPhysicsJointSpring *ropeJoint = [SKPhysicsJointSpring
                                       jointWithBodyA:_hookBaseNode.physicsBody
                                       bodyB:_hookNode.physicsBody
                                       anchorA:_hookBaseNode.position
                                       anchorB:CGPointMake(_hookNode.position.x, _hookNode.position.y+_hookNode.size.height/2)];
    
    [self.physicsWorld addJoint:ropeJoint];
}

-(void) releaseHook
{
    _catNode.zRotation = 0;
    [self.physicsWorld removeJoint:_hookNode.physicsBody.joints.lastObject];
    //joints property is an array of all the joints that are connected to a given physics body
    _isHooked = NO;
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
    
    _catNode.physicsBody.collisionBitMask = CNPhysicsCategoryBlock|CNPhysicsCategoryEdge|CNPhysicsCategorySpring;
}

- (void) addBlocksFromArray:(NSArray*)blocks
{
    //1 take a list of blocks as defined in the .plist and loop over the list
    for (NSDictionary *block in blocks) {
        
        NSString * blockType = block[@"type"];
     
        if (!blockType) {
        
            if (block[@"tuple"]) {
                //
                CGRect rect1 = CGRectFromString([block[@"tuple"] firstObject]);
                SKSpriteNode* block1 = [self addBlockWithRect:rect1];
                block1.physicsBody.friction = 0.8;
                block1.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
                block1.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
                [_gameNode addChild: block1];
            
                //
                CGRect rect2 = CGRectFromString([block[@"tuple"] lastObject]);
                SKSpriteNode* block2 = [self addBlockWithRect: rect2];
                block2.physicsBody.friction = 0.8;
                block2.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
                block2.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
                [_gameNode addChild: block2];
            
                [self.physicsWorld addJoint:[SKPhysicsJointFixed
                                         jointWithBodyA:block1.physicsBody
                                         bodyB:block2.physicsBody
                                         anchor:CGPointZero]
                 ];
            
            } else {
        
                //2 for each block, create a CGRect from the rect key of each block object, then call another helper method which creates a block sprite for you, then add it to the scene with addChild
                SKSpriteNode *blockSprite = [self addBlockWithRect:CGRectFromString(block[@"rect"])];
        
                //set category and collision bit masks for each block
                blockSprite.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
                blockSprite.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
                //assigns each block's physics body to the block category, then set them to collide with both the cat and block categories (with bitwise OR |)
        
                [_gameNode addChild:blockSprite];
            }
        } else {
            if ([blockType isEqualToString:@"PhotoFrameBlock"]) {
                [self createPhotoFrameWithPosition:CGPointFromString(block[@"point"])];
            }
            else if ([blockType isEqualToString:@"TVBlock"]) {
                [_gameNode addChild: [[OldTVNode alloc] initWithRect:CGRectFromString(block[@"rect"])]];
            }
            else if ([blockType isEqualToString:@"WonkyBlock"]) {
                [_gameNode addChild: [self createWonkyBlockFromRect:CGRectFromString(block[@"rect"])]];
            }
        }
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

-(void) addSpringsFromArray:(NSArray *) springs
{
    for (NSDictionary *spring in springs) {
        //loop over the list coming in from the .plist file and for each object...
        SKSpriteNode *springSprite = [SKSpriteNode spriteNodeWithImageNamed:@"spring"];
        //create a new sprite...
        springSprite.position = CGPointFromString(spring[@"position"]);
        springSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:springSprite.size ];
        //and a physics body...
        springSprite.physicsBody.categoryBitMask = CNPhysicsCategorySpring;
        springSprite.physicsBody.collisionBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryBlock | CNPhysicsCategoryCat;
        [springSprite attachDebugRectWithSize:springSprite.size];
        [_gameNode addChild: springSprite];
        //and add them to the scene
    }
}

-(void)createPhotoFrameWithPosition:(CGPoint)position
{
    // don't set position of picture node because it will be a child of the crop node
    SKSpriteNode *photoFrame = [SKSpriteNode spriteNodeWithImageNamed:@"picture-frame"];
    photoFrame.name = @"PhotoFrameNode";
    photoFrame.position = position;
    
    SKSpriteNode *pictureNode = [SKSpriteNode spriteNodeWithImageNamed:@"picture"];
    pictureNode.name = @"PictureNode";
    
    //load image for mask
    SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithImageNamed:@"picture-frame-mask"];
    maskNode.name = @"Mask";
    
    //create the crop node by adding it as a child of the photo frame, so all parts of the picture frame can be positioned or moved by a single node -the photo frame.
    SKCropNode *cropNode = [SKCropNode node];
    [cropNode addChild:pictureNode];
    [cropNode setMaskNode:maskNode];
    [photoFrame addChild:cropNode];
    
    [_gameNode addChild:photoFrame];
    
    photoFrame.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:photoFrame.size.width / 2.0 - photoFrame.size.width * 0.025]; //use a radius that is slightly smaller than the sprite size for an 'easing' effect
    photoFrame.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
    photoFrame.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
}

- (void)setPhotoTexture:(SKTexture *)texture
{
    SKSpriteNode *picture = (SKSpriteNode *)[self childNodeWithName:@"//PictureNode"];
    [picture setTexture:texture];
}

//method that takes in a CGPoint and a CGSize and returns a randomized point
CGPoint adjustedPoint(CGPoint inputPoint, CGSize inputSize)
{
    //1 - finds the maximum height and width of the deviation (15% of width or height) and stores them in variables width and height
    float width = inputSize.width * .15;
    float height = inputSize.height * .15;
    
    //2 - multiples a random number between 0 - 1 by the width or height then subtracts half the input width or height (to create a movement range that's centered between positive and negative movement. ultimate value is between -.075 and .075
    float xMove = width * RandomFloat() - width / 2.0;
    float yMove = height * RandomFloat() - height / 2.0;
    
    //3 add that random movement to the input point
    return CGPointMake(inputPoint.x + xMove, inputPoint.y + yMove);
}

- (SKShapeNode *) createWonkyBlockFromRect:(CGRect)inputRect
{
    //1 need the location for each corner of the rectangle - creates variables for each corner
    CGPoint origin = CGPointMake(inputRect.origin.x - inputRect.size.width / 2.0, inputRect.origin.y - inputRect.size.height/2.0);
    CGPoint pointlb = origin;
    CGPoint pointlt = CGPointMake(origin.x,inputRect.origin.y + inputRect.size.height);
    CGPoint pointrb = CGPointMake(origin.x + inputRect.size.width, origin.y);
    CGPoint pointrt = CGPointMake(origin.x + inputRect.size.width, origin.y + inputRect.size.height);
    
    //2 pass each of the points into the adjustedPoint helper method we created to randomly modify them
    pointlb = adjustedPoint(pointlb, inputRect.size);
    pointlt = adjustedPoint(pointlt, inputRect.size);
    pointrb = adjustedPoint(pointrb, inputRect.size);
    pointrt = adjustedPoint(pointrt, inputRect.size);
    
    //3 use the bezierPath convenience method to create a UIBezierPath
    UIBezierPath *shapeNodePath = [UIBezierPath bezierPath];
    [shapeNodePath moveToPoint:pointlb];
    [shapeNodePath addLineToPoint:pointlt];
    [shapeNodePath addLineToPoint:pointrt];
    [shapeNodePath addLineToPoint:pointrb];
    
    //4 draws a line between the very first and the very last point, closing the shape.
    [shapeNodePath closePath];
    
    //5 creates the SKShapeNode and set its shape. SKShapeNode has a CGPth property that takes a CGPathRef, and UIBezierPath has a CGPath property that returns a CGPath. (CGPatRef is a lower level, C representation of the path)
    SKShapeNode *wonkyBlock = [SKShapeNode node];
    wonkyBlock.path = shapeNodePath.CGPath;
    
    //6 adds the physics body now (does it custom, slightly smaller, rather than just passing the CGPath, using CGPointSubtract convenience method)
    UIBezierPath *physicsBodyPath = [UIBezierPath bezierPath];
    [physicsBodyPath moveToPoint:CGPointSubtract(pointlb, CGPointMake(-2, -2))];
    [physicsBodyPath addLineToPoint:CGPointSubtract(pointlt, CGPointMake(-2, 2))];
    [physicsBodyPath addLineToPoint:CGPointSubtract(pointrt, CGPointMake(2, 2))];
    [physicsBodyPath addLineToPoint:CGPointSubtract(pointrb, CGPointMake(2, -2))];
    [physicsBodyPath closePath];
    
    //7 create the physics body using bodyWithPolygonFromPath - it takes a CGPath and creates a physics body.
    wonkyBlock.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:physicsBodyPath.CGPath];
    wonkyBlock.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
    wonkyBlock.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
    
    //8
    wonkyBlock.lineWidth = 0.5;
    wonkyBlock.fillColor = [SKColor colorWithRed:0.75 green:0.75 blue:1.0 alpha:1.0];
    wonkyBlock.strokeColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.0 alpha:1.0];
    //wonkyBlock.glowWidth = 1.0;
    return wonkyBlock;
}


//TOUCH EVENT======================================================================------
//TOUCH EVENT======================================================================------
//TOUCH EVENT======================================================================------
//TOUCH EVENT======================================================================------
//TOUCH EVENT======================================================================------

- (void) touchesBegan: (NSSet *) touches withEvent:(UIEvent *) event
{
    [super touchesBegan:touches withEvent:event];
    
    //1 get the position of the touch in the scene
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //2 enumerate over all the bodies in the physics world of the current scene by passing the touch location and a block (takes in two parameters - a body and a boolean parameter called stop
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:
     ^(SKPhysicsBody *body, BOOL *stop) {
         
         if ([body.node.name isEqualToString:@"PhotoFrameNode"]) {
             [self.delegate requestImagePicker];  //calls the delegate method to request the image picker when the user taps the photo frame
             *stop = YES;
             return;
         }
         
         
         // 3  since all destructible bodies are CNPhysicsCategoryBlock, easy to determine whether to destroy the current body. use the body's node property to access the SKNode represented by the physics body and call removeFromParent on it
         if (body.categoryBitMask == CNPhysicsCategoryBlock) {
             for (SKPhysicsJoint* joint in body.joints) {
                 [self.physicsWorld removeJoint: joint];
                 [joint.bodyA.node removeFromParent];
                 [joint.bodyB.node removeFromParent];
             }
             [body.node removeFromParent];
             *stop = YES; //4   set stop to YES so that the enumerator won't loop over the rest unneccessarily.
             
             //5  make the blocks pop with a sound
             [self runAction:[SKAction playSoundFileNamed:@"pop.mp3"waitForCompletion:NO]];
         }
         if (body.categoryBitMask == CNPhysicsCategorySpring) {
             // if spring is tapped
             SKSpriteNode *spring = (SKSpriteNode*)body.node;
             // fetch the SKSpriteNode instance and store it in the spring variable
             [body applyImpulse:CGVectorMake(0,12) atPoint:CGPointMake(spring.size.width/2, spring.size.height)];
             //apply an impulse to the body by using applyImpulse:atPoint:
             [body.node runAction: [SKAction sequence:@[[SKAction waitForDuration:1],
                                                        [SKAction removeFromParent]]]];
             //remove the catapult after delay of one second
             *stop = YES;
         }
         if (body.categoryBitMask == CNPhysicsCategoryCat && _isHooked) {
             [self releaseHook];
         }
     }];
}


//COLLISION STUFF=======================================================================
//COLLISION STUFF=======================================================================
//COLLISION STUFF=======================================================================
//COLLISION STUFF=======================================================================
//COLLISION STUFF=======================================================================

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
        
        
        SKLabelNode* label = (contact.bodyA.categoryBitMask==CNPhysicsCategoryLabel)?(SKLabelNode*)contact.bodyA.node:(SKLabelNode*)contact.bodyB.node;
        
        if (label.userData==nil) {
            label.userData = [@{@"bounceCount":@0} mutableCopy];
        }
        
        int newBounceCount = [label.userData[@"bounceCount"] intValue]+1;
        NSLog(@"bounce: %i", newBounceCount);
        if (newBounceCount==4) {
            [label removeFromParent];
        } else {
            label.userData = [@{@"bounceCount":@(newBounceCount)} mutableCopy];
        }
    }
    
    if (collision == (CNPhysicsCategoryHook | CNPhysicsCategoryCat)) {
        //1 force zero velocity and angular velocity
        _catNode.physicsBody.velocity = CGVectorMake(0,0);
        _catNode.physicsBody.angularVelocity = 0;
        
        //2 create a new joint from from the SKPhysicsContact object - the two bodies and the point where they touched
        SKPhysicsJointFixed *hookJoint =
        [SKPhysicsJointFixed jointWithBodyA:_hookNode.physicsBody
                                      bodyB:_catNode.physicsBody
                                     anchor:CGPointMake(_hookNode.position.x, _hookNode.position.y + _hookNode.size.height/2)];
        [self.physicsWorld addJoint:hookJoint];
        
        //3
        //so the cat doesn't wake up while it hangs around
        _isHooked = YES;
    }
}


//PHYSICS STEP IN LOOP=======================================================================
//PHYSICS STEP IN LOOP=======================================================================
//PHYSICS STEP IN LOOP=======================================================================
//PHYSICS STEP IN LOOP=======================================================================
//PHYSICS STEP IN LOOP=======================================================================

- (void)didSimulatePhysics
{
    CGFloat angle = CGPointToAngle(CGPointSubtract(_hookBaseNode.position, _hookNode.position));
    _ropeNode.zRotation = M_PI + angle;
    //position the rope
    
    if (_catNode.physicsBody.contactTestBitMask && fabs(_catNode.zRotation) > DegreesToRadians(25)) {
        if (_isHooked == NO)[self lose];
    }
    //performs 2 tests - is the cat still active? check whether its contactTestBitMask is set (remember that it is disabled when the player completes the level.
    // - is the cat tilted too much? is the absolute value of the zrotation property more than the radian equivalent of 25 degrees
    // when both of these conditions are true, then call lose self right away
}



//LEVEL STUFF=======================================================================
//LEVEL STUFF=======================================================================
//LEVEL STUFF=======================================================================
//LEVEL STUFF=======================================================================
//LEVEL STUFF=======================================================================

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
    
    [self addSpringsFromArray:level[@"springs"]];
    
    if (level[@"hookPosition"]) {
        [self addHookAtPosition:CGPointFromString(level[@"hookPosition"])];
    }  //checks if there's a hookPosition key defined in the level .plist file then converts it to a CGPoint and passes it to addHookAtPosition
    
    if (level[@"seesawPosition"]) {
        [self addSeesawAtPosition:CGPointFromString(level[@"seesawPosition"])];
    }
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
    
    SKSpriteNode* bg2 = [SKSpriteNode spriteNodeWithImageNamed:@"background-desat"];
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Zapfino"];
    label.text = @"Cat Nap";
    label.fontSize = 96;
    
    SKCropNode *cropNode = [SKCropNode node];
    [cropNode addChild:bg2];
    [cropNode setMaskNode:label];
    cropNode.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:cropNode];
    //for neat title label that uses the desaturated background as it child and the font as its mask
    
    [self addCatBed];
    _gameNode = [SKNode node];
    [self addChild:_gameNode];
    _currentLevel = 1;
    [self setupLevel: _currentLevel];
    //creates a new node, stored in _gamenode, added to scene, then set value of current level to 1 and pass it to setupLevel so that it loads level1.plist and builds the level on the scene.
    
    //photoframe test
    //[self createPhotoFrameWithPosition:CGPointMake(120, 220)];

    //tv test
//    OldTVNode *tvNode = [[OldTVNode alloc] initWithRect:CGRectMake(100, 250, 100, 100)];
//    [self addChild:tvNode];
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
//    if (_currentLevel > 1 ) {
//        _currentLevel--;
//    }
    
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
    //progress levels
    if (_currentLevel < 7) {
        _currentLevel ++;
    }
    
    
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
