//
//  OverlaySCRecorder.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/25/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "OverlaySCRecorder.h"

@interface OverlaySCRecorder() 
{
    //UILabel *_watermarkLabel;
    //UILabel *_timeLabel;
    UIImageView *_mymixWatermark;
}

@end

@implementation OverlaySCRecorder

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _mymixWatermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brand"]];
        
        //_watermarkLabel = [UILabel new];
        //_watermarkLabel.textColor = [UIColor whiteColor];
        //_watermarkLabel.font = [UIFont boldSystemFontOfSize:40];
        //_watermarkLabel.text = @"SCRecorder ©";
        
        //_timeLabel = [UILabel new];
        //_timeLabel.textColor = [UIColor yellowColor];
        //_timeLabel.font = [UIFont boldSystemFontOfSize:40];
        
        //[self addSubview:_watermarkLabel];
        //[self addSubview:_timeLabel];
        [self addSubview:_mymixWatermark];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static const CGFloat inset = 8;
    
    CGSize size = self.bounds.size;
    
    //[_watermarkLabel sizeToFit];
    //CGRect watermarkFrame = _watermarkLabel.frame;
    //watermarkFrame.origin.x = size.width - watermarkFrame.size.width - inset;
    //watermarkFrame.origin.y = size.height - watermarkFrame.size.height - inset;
    //_watermarkLabel.frame = watermarkFrame;
    
    //[_timeLabel sizeToFit];
    //CGRect timeLabelFrame = _timeLabel.frame;
    //timeLabelFrame.origin.y = inset;
    //timeLabelFrame.origin.x = inset;
    //_timeLabel.frame = timeLabelFrame;
    
    [_mymixWatermark sizeToFit];
    CGRect watermarkFrame = _mymixWatermark.frame;
    watermarkFrame.size.width = watermarkFrame.size.width * 3;
    watermarkFrame.size.height = watermarkFrame.size.height * 3;
    watermarkFrame.origin.x = size.width - watermarkFrame.size.width - inset;
    watermarkFrame.origin.y = size.height - watermarkFrame.size.height - inset;
    _mymixWatermark.frame = watermarkFrame;
}

- (void)updateWithVideoTime:(NSTimeInterval)time
{
    //NSDate *currentDate = [self.date dateByAddingTimeInterval:time];
    //_timeLabel.text = [NSString stringWithFormat:@"%@", currentDate];
}


@end
