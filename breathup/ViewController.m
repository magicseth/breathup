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
        NSString *filename = @"exhale.caf";
		CFURLRef soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
													(CFStringRef) filename,
													CFSTR(""),
													NULL);

    AudioServicesCreateSystemSoundID (soundURL, &soundID);

    SystemSoundID sounda = soundID;
    filename = @"inhale.caf";
    soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
                                                (CFStringRef) filename,
                                                CFSTR(""),
                                                NULL);
    
    AudioServicesCreateSystemSoundID (soundURL, &soundID);

    SystemSoundID soundb = soundID;
    
    NSError * err = nil;
    lullaby = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"lullaby" withExtension:@"caf"] error:&err];
    [lullaby setNumberOfLoops:-1];
    [lullaby setEnableRate:YES];
    [lullaby play];
    
    // Do regular view contorller thing:
    [super viewDidLoad];
    
    
    
    // Start listening to motion updates
    self.motionManager = [[CMMotionManager alloc] init];
    static float last = 0;
    static double olddir;
#define NUMVALS 30
    static float vals[NUMVALS];
    static double lastChange = 0.0;
    
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
                
                double now = [[NSDate date] timeIntervalSince1970];
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
                
                float newdir = 0;
                
                // if the average is close to 0, don't count it as movement.
                if (avg > -0.0001 && avg <0.0001) {
                    newdir = 0;
                } else if (avg <0 ) {
                    newdir = -1;
                } else if ( avg > 0) {
                    newdir = 1;
                }
#define BREATH_LOWPASS_COUNT 5
                static double breathRates[BREATH_LOWPASS_COUNT];
                static int breathcount = 0;
                // olddir is the last direction we were going
                // new dir is the direction we are going now
                // if they are different, we will play a new sound, 
                // depending on the direction of the change
                if (newdir == 1) {
                    // set the background color every time
                    [self.view setBackgroundColor:[UIColor blueColor]];
                    if (olddir == -1 ) {
//                        AudioServicesPlaySystemSound(sounda);
                        breathRates[breathcount %BREATH_LOWPASS_COUNT] = now - lastChange;
                        breathcount++;
                        lastChange = now;
                    }
                } else if(newdir == -1){
                    [self.view setBackgroundColor:[UIColor lightGrayColor]];
                    if (olddir == 1) {
//                        AudioServicesPlaySystemSound(soundb);
                        breathRates[breathcount %BREATH_LOWPASS_COUNT] = now - lastChange;
                        breathcount++;
                        lastChange = now;
                    }   
                }
                if (newdir) {
                    olddir = newdir;
                }
                
                
                double avgbreathlength = 0.0;
                if (lastChange == now) {
                    float c = MIN(BREATH_LOWPASS_COUNT, breathcount);
                    for (int j = 0; j < c; j++) {
                        avgbreathlength += breathRates[j];
                    }
                    avgbreathlength = avgbreathlength / (float) c;
                    
#define TARGETBREATHRATE 16
                    float targetbreathlength = 60.0 / TARGETBREATHRATE /2.0;
                    double ratechange  = 2 - (avgbreathlength - (targetbreathlength-1));
                    if (ratechange < .5) {
                        ratechange = .5;
                    } else if (ratechange > 2.0) {
                        ratechange = 2.0;
                    }
                    [lullaby setRate:ratechange];
                    NSLog(@"%.02f breath equals rate %.02f", avgbreathlength, ratechange);

                }
                
                if (i%5 == 0) {
//                    NSLog(@"%.02f, %.04f, %.04f", acc.y, avg, newdir);
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
    return NO;
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
