//
//  RecordingViewController.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/23/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "RecordingViewController.h"
#import "GPUImage.h"

@interface RecordingViewController ()
{
    IBOutlet UILabel *end;
    IBOutlet UIButton *rec;
    IBOutlet GPUImageView *camView;
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    GPUImagePicture *overlay;
    BOOL recording;
    NSTimer *timer;
    int minutes, seconds, secondsLeft;
}

@end

@implementation RecordingViewController

- (void)viewDidLoad {
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    // Note: I needed to stop camera capture before the view went off the screen in order to prevent a crash from the camera still sending frames
    [videoCamera stopCameraCapture];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupCamera
{
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait; //portrait
    videoCamera.audioEncodingTarget = nil; //mute microphone
    videoCamera.horizontallyMirrorFrontFacingCamera = YES; //add mirror

    
    
    filter = [[GPUImageMaskFilter alloc] init];
    [(GPUImageFilter*)filter setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    [videoCamera addTarget:filter];
    //videoCamera.runBenchmark = YES;
    
    
    GPUImageView *filterView = (GPUImageView *)camView;
    //filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    
    
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.125f, 0, 0.75f, 1.0f)];
    [videoCamera addTarget:cropFilter];
    [videoCamera forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480.0, 480.0)];
    
    
    
    UIImage *inputImage = [UIImage imageNamed:@"new"];
    overlay = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [overlay processImage];
    [overlay addTarget:filter];
    
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;

    [videoCamera addTarget:movieWriter];
    [filter addTarget:filterView];
    
    [videoCamera startCameraCapture];
}

- (IBAction)startRec:(id)sender
{
    if (!rec.isSelected) {
        NSLog(@"Start recording");
        [rec setSelected:YES];
        [self countdownTimer];
        
        [movieWriter startRecording];
        
    } else {
        NSLog(@"Movie completed");
        [rec setSelected:NO];
        [self stopTimer];
        
        [videoCamera removeTarget:movieWriter];
        [movieWriter finishRecording];
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
