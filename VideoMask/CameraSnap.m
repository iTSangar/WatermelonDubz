//
//  CameraSnap.m
//  VideoMask
//
//  Created by Ítalo Sangar on 3/30/16.
//  Copyright © 2016 iTSangar. All rights reserved.
//

#import "CameraSnap.h"
#import "SCRecorder.h"
#import "SDRecordButton.h"
#import "SnapPreview.h"
#import "SnapOverlayMark.h"

const int MAX_TIME = 15;

@interface CameraSnap () <SCRecorderDelegate, SCAssetExportSessionDelegate>
{
  SCRecorder *_recorder;
  SCRecordSession *_recordSession;
  SCAssetExportSession *_exportSession;
  
  IBOutlet UIButton *flash;
}

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, strong) IBOutlet SDRecordButton *recordButton;
@property (nonatomic, strong)          NSTimer        *progressTimer;
@property (nonatomic)                  CGFloat        progress;

@property (nonatomic, strong) IBOutlet UIVisualEffectView *blurView;

@end

@implementation CameraSnap

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupCamera];
  [self configureButton];
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES];
  [self prepareSession];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [_recorder startRunning];
  [self.recordButton setEnabled:YES];
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
  _recorder.keepMirroringOnWrite = YES;
  _recorder.device = AVCaptureDevicePositionFront;
  _recorder.maxRecordDuration = CMTimeMake(MAX_TIME, 1);
  //_recorder.fastRecordMethodEnabled = YES; /* uncomment if performance issue */
  
  
  UIView *previewView = self.cameraPreviewView;
  _recorder.previewView = previewView;
  _recorder.initializeSessionLazily = NO;
  _recorder.videoConfiguration.sizeAsSquare = NO;
  
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

- (void)configureButton {
  
  [[self.blurView layer] setCornerRadius:50];
  [self.blurView setClipsToBounds:YES];
  
  // Add Targets
  [self.recordButton addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchDown];
  [self.recordButton addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpInside];
  [self.recordButton addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpOutside];
  
}

- (void)recording {
  NSLog(@"Started recording");
  self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
  [_recorder record];
}

- (void)pausedRecording {
  NSLog(@"Paused recording.");
  [self.progressTimer invalidate];
  [_recorder pause:^{
    [self saveAndShowSession:_recorder.session];
  }];
}

- (void)updateProgress {
  self.progress += 0.05/MAX_TIME;
  NSLog(@"progress >>>> %f", self.progress);
  [self.recordButton setProgress:self.progress];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession
{
  _recordSession = recordSession;
  [self.progressTimer invalidate];
  self.progress = 0.0;
  [self.recordButton setEnabled:NO];
  [self mergeVideo];
}

- (IBAction)reverseCamera:(id)sender
{
  if (![_recorder isRecording]) {
    [_recorder switchCaptureDevices];
  }
}

- (IBAction)switchFlash:(id)sender
{
  if (_recorder.device == AVCaptureDevicePositionFront) {
    return;
  }
  
  switch (_recorder.flashMode) {
    case SCFlashModeOff:
      _recorder.flashMode = SCFlashModeLight;
      [flash setSelected:YES];
      break;
    case SCFlashModeLight:
      _recorder.flashMode = SCFlashModeOff;
      [flash setSelected:NO];
      break;
    default:
      break;
  }
}

- (IBAction)closeCamera:(id)sender {
  [self.navigationController setNavigationBarHidden:NO];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)mergeVideo
{
  // Show progress here
  
  // Export config
  SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recordSession.assetRepresentingSegments];
  exportSession.videoConfiguration.preset = SCPresetHighestQuality;
  exportSession.videoConfiguration.maxFrameRate = 0;
  exportSession.videoConfiguration.keepInputAffineTransform = YES;
  exportSession.outputUrl = _recordSession.outputUrl;
  exportSession.outputFileType = AVFileTypeMPEG4;
  exportSession.delegate = self;
  _exportSession = exportSession;
  
  
  // Mask
  SnapOverlayMark *overlay = [SnapOverlayMark new];
  exportSession.videoConfiguration.overlay = overlay;
  
  NSLog(@"Starting exporting");
  
  
  CFTimeInterval time = CACurrentMediaTime(); // time to complete process
  
  // Merge
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
      // success
      [self performSegueWithIdentifier:@"previewSnap" sender:self];
    } else {
      if (!exportSession.cancelled) {
        [[[UIAlertView alloc] initWithTitle:@"Process failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
      }
    }
  }];
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
    // update progress here
  });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.destinationViewController isKindOfClass:[SnapPreview class]]) {
    _recorder.session = nil;
    [_recordSession removeLastSegment];
    [_recordSession addSegment:[SCRecordSessionSegment segmentWithURL:_exportSession.outputUrl info:nil]];
    
    SnapPreview *videoPlayer = segue.destinationViewController;
    videoPlayer.recordSession = _recordSession;
    videoPlayer.path = _exportSession.outputUrl.path;
  }
}


@end
