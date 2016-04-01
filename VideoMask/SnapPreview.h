//
//  SnapPreview.h
//  VideoMask
//
//  Created by Ítalo Sangar on 3/31/16.
//  Copyright © 2016 iTSangar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface SnapPreview : UIViewController

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) SCRecordSession *recordSession;

@end
