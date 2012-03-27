//
//  ViewController.h
//  breathup
//
//  Created by Seth Raphael on 3/3/12.
//  Copyright (c) 2012 Bump Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController : UIViewController
{
    AVAudioPlayer * lullaby;
}
@property (nonatomic, retain) CMMotionManager *motionManager ;
@end
