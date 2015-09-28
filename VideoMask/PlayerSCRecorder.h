//
//  PlayerSCRecorder.h
//  VideoMask
//
//  Created by Ítalo Sangar on 9/24/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface PlayerSCRecorder : UIViewController

@property (strong, nonatomic) NSURL *audioUrl;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) SCRecordSession *recordSession;

@end
