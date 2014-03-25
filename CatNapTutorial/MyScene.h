//
//  MyScene.h
//  CatNapTutorial
//

//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// creates a delegate protocol on the MyScene class that has a method to request a UIImagePickerController
// the view controller class will implement this delegate protocol
// when the user chooses an image, the viewController will call then a method on MyScene
@protocol ImageCaptureDelegate
-(void) requestImagePicker;
@end

@interface MyScene : SKScene


//sets the delegate, and declares the method that will set the texture after the user has chosen a photo
@property (nonatomic, assign)
id <ImageCaptureDelegate> delegate;
//setPhotoTexture will replace the texture for the existing SKSpriteNode that contains the image in the photo frame node. Replacing the texture instead of replacing the entire node so that you can keep the same rectangle and positioning in place
-(void) setPhotoTexture:(SKTexture *) texture;

@end
