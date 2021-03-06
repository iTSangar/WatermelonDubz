//
//  AppDelegate.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/22/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "AppDelegate.h"
#include <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
  
  dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    // Add code here to do background processing
    //
    //
    AVAudioSession *session1 = [AVAudioSession sharedInstance];
    [session1 setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    
    [session1 setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    dispatch_async( dispatch_get_main_queue(), ^{
      // Add code here to update the UI/send notifications based on the
      // results of the background processing
    });
  });
  

  
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
  if(event.type == UIEventTypeRemoteControl)
  {
    switch(event.subtype)
    {
      case UIEventSubtypeRemoteControlPause:
      case UIEventSubtypeRemoteControlStop:
        break;
      case UIEventSubtypeRemoteControlPlay:
        break;
      default:
        break;
    }
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
