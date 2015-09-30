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

const int RANGE_TIME = 20;

@interface TrimViewController () <TTRangeSliderDelegate>
{
    AVAudioPlayer *_audioPlayer;
    
    IBOutlet UIButton *play;
    
    NSTimer *timer;
    int secondsLeft;
}

@property (weak, nonatomic) IBOutlet TTRangeSlider *rangeSlider;

@end

@implementation TrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.musicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"full" ofType:@"mp3"]];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicURL error:nil];
    [_audioPlayer prepareToPlay];
    [self setupSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resetCounterAndPause];
}

- (void)setupSlider
{
    self.rangeSlider.delegate = self;
    self.rangeSlider.minValue = 0.0;
    self.rangeSlider.maxValue = _audioPlayer.duration;
    self.rangeSlider.selectedMinimum = 0;
    self.rangeSlider.selectedMaximum = 0;
    self.rangeSlider.maxDistance = _audioPlayer.duration - RANGE_TIME;
    NSNumberFormatter *initialFormatter = [[NSNumberFormatter alloc] init];
    initialFormatter.positiveSuffix = @":00 - 0:20";
    self.rangeSlider.numberFormatterOverride = initialFormatter;
}

- (IBAction)playPause:(id)sender
{
    //NSLog(@"atual: %d  duracao: %d", ((int)self.rangeSlider.selectedMaximum + RANGE_TIME) , (int)_audioPlayer.duration);
    if (![_audioPlayer isPlaying] && !play.isSelected) {
        [_audioPlayer setCurrentTime:self.rangeSlider.selectedMaximum];
        [_audioPlayer play];
        [play setSelected:YES];
        [self countdownTimer];
    } else {
        [self resetCounterAndPause];
        [play setSelected:NO];
    }
}

- (NSString *)convertValueToTime:(int)x
{
    int minutes = (x % 3600) / 60;
    int seconds = x % 60;
    
    int y = x + RANGE_TIME;
    int nextMinutes = (y % 3600) / 60;
    int nextSeconds = y % 60;
    
    return [NSString stringWithFormat:@"%d:%02d - %d:%02d", minutes, seconds, nextMinutes, nextSeconds];
}

- (void)countdownTimer
{
    secondsLeft = RANGE_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

- (void)updateCounter:(NSTimer *)theTimer
{
    //NSLog(@"timer: %d", secondsLeft);
    if (secondsLeft == 0) {
        [self playPause:nil];
    } else {
        secondsLeft -- ;
    }
}

- (void)resetCounterAndPause
{
    [_audioPlayer pause];
    [timer invalidate];
}

- (void)resetCounter
{
    [timer invalidate];
    [self countdownTimer];
}


#pragma mark TTRangeSliderViewDelegate

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    //NSLog(@"Standard slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
    self.rangeSlider.numberStringOverride = [self convertValueToTime:selectedMaximum];
    [_audioPlayer setCurrentTime:selectedMaximum];
    if (_audioPlayer.isPlaying) {
        [self resetCounter];
    }
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
