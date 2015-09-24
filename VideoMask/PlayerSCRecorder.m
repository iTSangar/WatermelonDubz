//
//  PlayerSCRecorder.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/24/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "PlayerSCRecorder.h"

@interface PlayerSCRecorder () <SCPlayerDelegate, SCAssetExportSessionDelegate>

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *cinema;

@end

@implementation PlayerSCRecorder

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_player pause];
}

- (void)setupPlayer
{
    _player = [SCPlayer player];
    
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    //playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerView.frame = self.cinema.frame;
    //playerView.autoresizingMask = self.cinema.autoresizingMask;
    [self.cinema.superview insertSubview:playerView aboveSubview:self.cinema];
    [self.cinema removeFromSuperview];

    _player.loopEnabled = YES;
}

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)saveToCameraRoll:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //SCFilter *currentFilter = [self.filterSwitcherView.selectedFilter copy];
    [_player pause];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    //exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    self.exportSession = exportSession;
    
//    self.exportView.hidden = NO;
//    self.exportView.alpha = 0;
//    CGRect frame =  self.progressView.frame;
//    frame.size.width = 0;
//    self.progressView.frame = frame;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.exportView.alpha = 1;
//    }];
    
//    SCWatermarkOverlayView *overlay = [SCWatermarkOverlayView new];
//    overlay.date = self.recordSession.date;
//    exportSession.videoConfiguration.overlay = overlay;
//    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        if (strongSelf != nil) {
            [strongSelf.player play];
            strongSelf.exportSession = nil;
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
            
//            [UIView animateWithDuration:0.3 animations:^{
//                strongSelf.exportView.alpha = 0;
//            }];
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            UISaveVideoAtPathToSavedPhotosAlbum(exportSession.outputUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - SCAssetExportSessionDelegate

- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        NSLog(@"%f", progress);
        
        // show progress
        //CGRect frame =  self.progressView.frame;
        //frame.size.width = self.progressView.superview.frame.size.width * progress;
        //self.progressView.frame = frame;
    });
}



#pragma mark - SCPlayerDelegate


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
