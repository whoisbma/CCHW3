//
//  ViewController.m
//  CatNapTutorial
//
//  Created by Bryan Ma on 2/27/14.
//  Copyright (c) 2014 Bryan Ma. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@interface ViewController() <
    ImageCaptureDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate>
@end
//implements the listed delegate protocols (for immage selection)



@implementation ViewController

#pragma mark ImageCaptureDelegate methods
- (void)requestImagePicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated: YES
                     completion:nil];
}
//creates the UIImagePickerController object
//sets the ViewController class as the delegate and call presentViewController
//setting the delegate allows you to handle the callback when the user has chosen an image from their album (next method)

#pragma mark UIImagePickerControllerDelegate methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // this delegate method receives an NSDictionary in which one of the keys is UIImagePickerControllerOriginalImage.
    //the value for this key is a UIImage object containing the chosen photo
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // the UIImagePickerController has to be told to dismiss itself and takes a block callback
    [picker dismissViewControllerAnimated:YES completion:^{
        //Here you create a texture from a UIImage. textureWithImage: works with UIImage objects in iOS and NSImage objects in OSX. You can also initialize an SKTexture using its textureWithCGImage: method, passing a CGImageRef from a UIImage's CGImage property.
        SKTexture *imageTexture = [SKTexture textureWithImage:image];
        //the next 3 lines get a reference to the MyScene object and then call setPhotoTexture, passing the texture created from the chosen photo.
        SKView *view = (SKView *)self.view;
        MyScene *currentScene = (MyScene *) [view scene];
        //place core image code here
        [currentScene setPhotoTexture:imageTexture];
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
    
        // Create and configure the scene.
        MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.delegate = self;
        scene.scaleMode = SKSceneScaleModeAspectFill;
    
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;  // simple fix for resize/readjust during reorientation - the image picker is presented in portrait, but the game view won't rotate to portrait
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    } else {
//        return UIInterfaceOrientationMaskAll;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
