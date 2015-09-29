//
//  TrimViewController.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/29/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "TrimViewController.h"
#import "TTRangeSlider.h"
#import <AVFoundation/AVFoundation.h>

@interface TrimViewController () <TTRangeSliderDelegate>
{
    AVAudioPlayer *_audioPlayer;
}

@property (weak, nonatomic) IBOutlet TTRangeSlider *rangeSlider;

@end

@implementation TrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.musicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"full" ofType:@"mp3"]];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicURL error:nil];
    [self setupSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupSlider
{
    self.rangeSlider.delegate = self;
    self.rangeSlider.minValue = 0.0;
    self.rangeSlider.maxValue = _audioPlayer.duration;
    self.rangeSlider.selectedMinimum = 0;
    self.rangeSlider.selectedMaximum = 0;
    self.rangeSlider.numberStringOverride = [NSString stringWithFormat:@"00:00 - 00:20"];
}


#pragma mark TTRangeSliderViewDelegate

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    NSLog(@"Standard slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
