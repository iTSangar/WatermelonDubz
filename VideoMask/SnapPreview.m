//
//  SnapPreview.m
//  VideoMask
//
//  Created by Ítalo Sangar on 3/31/16.
//  Copyright © 2016 iTSangar. All rights reserved.
//

#import "SnapPreview.h"
#import "OverlaySCRecorder.h"

@interface SnapPreview ()

@property (strong, nonatomic) SCPlayer *player;
@property (strong, nonatomic) IBOutlet SCVideoPlayerView *viewPlayer;

@end

@implementation SnapPreview

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupPlayer];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_player setItemByAsset:_recordSession.assetRepresentingSegments];
  [_player play];
}

- (void)setupPlayer
{
  _player = [SCPlayer player];
  
  SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
  self.viewPlayer.contentMode = UIViewContentModeScaleAspectFill;
  //playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  playerView.frame = self.view.frame;
  //playerView.autoresizingMask = self.viewPlayer.autoresizingMask;
  [self.viewPlayer.superview insertSubview:playerView aboveSubview:self.viewPlayer];
  [self.viewPlayer removeFromSuperview];
  
  _player.loopEnabled = YES;
}

- (IBAction)closeCamera:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveToCameraRoll:(id)sender
{
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  UISaveVideoAtPathToSavedPhotosAlbum(self.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
  
  if (error == nil) {
    [[[UIAlertView alloc] initWithTitle:@"Salvo no Rolo de Câmera" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
  } else {
    [[[UIAlertView alloc] initWithTitle:@"Falha ao salvar" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
  }
}

#pragma mark - Share

- (IBAction)shareTwitter:(id)sender {
  //
}

- (IBAction)shareFacebook:(id)sender {
  //
}

- (IBAction)shareInstagram:(id)sender {
  //
}

@end
