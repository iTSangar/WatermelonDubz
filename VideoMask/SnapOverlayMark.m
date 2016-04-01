//
//  SnapOverlayMark.m
//  VideoMask
//
//  Created by Ítalo Sangar on 4/1/16.
//  Copyright © 2016 iTSangar. All rights reserved.
//

#import "SnapOverlayMark.h"

@interface SnapOverlayMark()
{
  UIImageView *_sertanejoWatermark;
}

@end

@implementation SnapOverlayMark

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    _sertanejoWatermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snap_mark"]];
    [self addSubview:_sertanejoWatermark];
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
  
  [_sertanejoWatermark sizeToFit];
  CGRect watermarkFrame = _sertanejoWatermark.frame;
  watermarkFrame.size.width = size.width;
  watermarkFrame.size.height = size.height / 2.2;
  watermarkFrame.origin.x = 0;
  watermarkFrame.origin.y = (size.height - watermarkFrame.size.height - inset) + 10;
  _sertanejoWatermark.frame = watermarkFrame;
}

- (void)updateWithVideoTime:(NSTimeInterval)time
{
  //NSDate *currentDate = [self.date dateByAddingTimeInterval:time];
  //_timeLabel.text = [NSString stringWithFormat:@"%@", currentDate];
}

@end
