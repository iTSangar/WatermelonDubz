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
  
}

@end
