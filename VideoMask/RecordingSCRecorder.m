//
//  RecordingSCRecorder.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/24/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "RecordingSCRecorder.h"
#import "SCRecorder.h"
#import "PlayerSCRecorder.h"
#import "OverlaySCRecorder.h"

@interface RecordingSCRecorder () <SCRecorderDelegate, SCAssetExportSessionDelegate>
{
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    SCAssetExportSession *_exportSession;
    
    IBOutlet UILabel *end;
    IBOutlet UIButton *rec;
    BOOL recording;
    NSTimer *timer;
    int minutes, seconds, secondsLeft;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;

@end

@implementation RecordingSCRecorder

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    recording = NO;
    secondsLeft = 20;
    [self setupCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recorder stopRunning];
    [_exportSession cancelExport];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_recorder previewViewFrameChanged];
}

- (void)setupCamera
{
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.captureSessionPreset = AVCaptureSessionPresetHigh;
    _recorder.delegate = self;
    _recorder.videoOrientation = AVCaptureVideoOrientationPortrait;
    [_recorder switchCaptureDevices];
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    _recorder.initializeSessionLazily = NO;
    _recorder.videoConfiguration.sizeAsSquare = YES;
    
    // Set filter || Create filter feature -> https://github.com/rFlex/SCRecorder/issues/182
    //_recorder.videoConfiguration.filter = [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"];
   
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
}

- (void)prepareSession
{
    if (_recorder.session == nil) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession
{
    _recordSession = recordSession;
    [self mergeVideo];
}

- (void)mergeVideo
{
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    //exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.videoConfiguration.keepInputAffineTransform = NO;
    exportSession.outputUrl = _recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    _exportSession = exportSession;
    
    // Show progress here
    
    // Overlay
    OverlaySCRecorder *overlay = [OverlaySCRecorder new];
    overlay.date = _recorder.session.date;
    exportSession.videoConfiguration.overlay = overlay;
    NSLog(@"Starting exporting");
    
    // Merge
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        if (strongSelf != nil) {
            //strongSelf.exportSession = nil;
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [self performSegueWithIdentifier:@"Preview" sender:self];
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Process failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (IBAction)startRec:(id)sender
{
    if (!rec.isSelected) {
        //NSLog(@"Start recording");
        [rec setSelected:YES];
        [self countdownTimer];
        
        [_recorder record];
        
    } else {
        //NSLog(@"Movie completed");
        [rec setSelected:NO];
        [self stopTimer];
        
        [_recorder pause:^{
            [self saveAndShowSession:_recorder.session];
        }];
    }
}

- (void)countdownTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

- (void)updateCounter:(NSTimer *)theTimer
{
    if (secondsLeft == 0) {
        [self startRec:nil];
    } else {
        secondsLeft -- ;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft %3600) % 60;
        end.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}

- (void)stopTimer
{
    [timer invalidate];
    end.text = @"";
    secondsLeft = 20;
}

- (IBAction)reverseCamera:(id)sender
{
    [_recorder switchCaptureDevices];
}

- (IBAction)switchFlash:(id)sender
{
    switch (_recorder.flashMode) {
        case SCFlashModeOff:
            _recorder.flashMode = SCFlashModeLight;
            break;
        case SCFlashModeLight:
            _recorder.flashMode = SCFlashModeOff;
            break;
        default:
            break;
    }
}


#pragma mark - SCRecorderDelegate

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession
{
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError
{
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError
{
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession
{
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error
{
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error
{
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error
{
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error
{
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession
{
    //[self updateTimeRecordedLabel];
}


#pragma mark - SCAssetExportSessionDelegate

- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        NSLog(@"%f", progress);
        
        // update progress
        //CGRect frame =  self.progressView.frame;
        //frame.size.width = self.progressView.superview.frame.size.width * progress;
        //self.progressView.frame = frame;
    });
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PlayerSCRecorder class]]) {
        PlayerSCRecorder *videoPlayer = segue.destinationViewController;
        _recorder.session = nil;
        [_recordSession removeLastSegment];
        [_recordSession addSegment:[SCRecordSessionSegment segmentWithURL:_exportSession.outputUrl info:nil]];
        videoPlayer.recordSession = _recordSession;
        videoPlayer.path = _exportSession.outputUrl.path;
    }
}


@end
