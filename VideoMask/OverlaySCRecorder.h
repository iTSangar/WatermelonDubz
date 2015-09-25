//
//  OverlaySCRecorder.h
//  VideoMask
//
//  Created by Ítalo Sangar on 9/25/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoConfiguration.h"

@interface OverlaySCRecorder : UIView <SCVideoOverlay>

@property (strong, nonatomic) NSDate *date;

@end
