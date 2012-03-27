//
//  ViewController.m
//  breathup
//
//  Created by Seth Raphael on 3/3/12.
//  Copyright (c) 2012 Bump Technologies. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation ViewController
@synthesize motionManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Create sounds:
    SystemSoundID soundID = 0;
        NSString *filename = @"receiveold.caf";
		CFURLRef soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
													(CFStringRef) filename,
													CFSTR(""),
													NULL);

    AudioServicesCreateSystemSoundID (soundURL, &soundID);

    SystemSoundID sounda = soundID;
    filename = @"sendold.caf";
    soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
                                                (CFStringRef) filename,
                                                CFSTR(""),
                                                NULL);
    
    AudioServicesCreateSystemSoundID (soundURL, &soundID);

    SystemSoundID soundb = soundID;
    
    // Do regular view contorller thing:
    [super viewDidLoad];
    
    
    
    // Start listening to motion updates
    self.motionManager = [[CMMotionManager alloc] init];
    static float last = 0;
    static float lastavg = 0;
    static double olddir;
#define NUMVALS 30
    static float vals[NUMVALS];
    
    //Gyroscope
    if([self.motionManager isGyroAvailable])
    {
        static int i = 0;
        /* Start the gyroscope if it is not active already */ 
        if([self.motionManager isGyroActive] == NO)
        {
            /* Update us 2 times a second */
            [self.motionManager setGyroUpdateInterval:1.0f / 2.0f];
            
            /* And on a handler block object */
            
            /* Receive the gyroscope data on this block */
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
                // this "block gets run everytime there is a new 
                // gyro motion update
                CMAcceleration acc = [motion gravity];
                // we are keeping a circular buffer of the CHANGES in y gravity
                
                vals[i%NUMVALS] = acc.y - last; //this is the change since last time
                last = acc.y;
                
                // now we average the change over our last little sliding window
                // to get a feeling for the overall gist of the changes
                // this is essentially smoothing low pass filter
                double avg = 0;
                for (int j = 0; j < NUMVALS; j++) {
                    avg += vals[j];
                }
                avg /= NUMVALS;
                
                
                // if the average is close to 0, don't count it as movement.
                if (avg > -0.0001 && avg <0) {
                    avg = 0;
                }
                
                float newdir = 0;
                if (avg <0 && lastavg < 0) {
                    newdir = -1;
                }
                if ( avg > 0 && lastavg > 0) {
                    newdir = 1;
                }
                
                lastavg = avg;
                // olddir is the last direction we were going
                // new dir is the direction we are going now
                // if they are different, we will play a new sound, 
                // depending on the direction of the change
                if (newdir == 1) {
                    // set the background color every time
                    [self.view setBackgroundColor:[UIColor blueColor]];
                    if (olddir == -1) {
                        AudioServicesPlaySystemSound(sounda);
                    }
                } else if(newdir == -1){
                    [self.view setBackgroundColor:[UIColor lightGrayColor]];
                    if (olddir == 1) {
                        AudioServicesPlaySystemSound(soundb);
                    }
                    
                }
                if (newdir) {
                    olddir = newdir;
                }
                
                if (i%5 == 0) {
                    NSLog(@"%.02f, %.04f, %.04f, ", acc.y, avg, newdir);
                }
                i++;
            }];
             
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
