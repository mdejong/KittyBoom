//
//  ViewController.m
//  KittyBoom
//
//  Created by Moses DeJong on 12/31/12.
//

#import "ViewController.h"

#import "AVFileUtil.h"

#import "AVAssetJoinAlphaResourceLoader.h"

#import "AVAnimatorMedia.h"

#import "AVAnimatorLayer.h"

#import "AVMvidFrameDecoder.h"

#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, retain) AVAnimatorMedia *media;

@property (nonatomic, retain) AVAnimatorLayer *animatorLayer;

@end

@implementation ViewController

- (void) dealloc
{
  self.media = nil;
  self.animatorLayer = nil;
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Create resource loader that will combine RGB and Alpha values back
  // into one Maxvid file.

  CGRect iPhoneExplosionRect = CGRectMake(0, 0, 640, 480);
  CGRect iPadExplosionRect = CGRectMake(0, 0, 826, 620);
 
  NSString *rgbResourceName = @"ExplosionAdjusted_rgb_CRF_30_24BPP.m4v";
  NSString *alphaResourceName = @"ExplosionAdjusted_alpha_CRF_30_24BPP.m4v";
  
  // Output filename
  
  NSString *tmpFilename;
  NSString *tmpPath;
  tmpFilename = @"Explosion.mvid";
  tmpPath = [AVFileUtil getTmpDirPath:tmpFilename];
  
  // Set to TRUE to always decode from H.264
  
  BOOL alwaysDecode = FALSE;
  
  if (alwaysDecode && [AVFileUtil fileExists:tmpPath]) {
    BOOL worked = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    NSAssert(worked, @"could not remove file %@", tmpPath);
  }
  
  // This loader will join 2 H.264 videos together into a single 32BPP .mvid
  
  AVAssetJoinAlphaResourceLoader *resLoader = [AVAssetJoinAlphaResourceLoader aVAssetJoinAlphaResourceLoader];
  
  resLoader.movieRGBFilename = rgbResourceName;
  resLoader.movieAlphaFilename = alphaResourceName;
  resLoader.outPath = tmpPath;
  //resLoader.alwaysGenerateAdler = TRUE;
  
  AVAnimatorMedia *media = [AVAnimatorMedia aVAnimatorMedia];
  media.resourceLoader = resLoader;
  
  self.media = media;
  
  // Frame decoder will read from generated .mvid file
  
  AVMvidFrameDecoder *aVMvidFrameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
  media.frameDecoder = aVMvidFrameDecoder;
  
  // Create layer that video data will be directed into
  
  CGRect expFrame;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    expFrame = iPhoneExplosionRect;
  } else {
    expFrame = iPadExplosionRect;
  }  
  
  CALayer *layer = [CALayer layer];
  layer.frame = expFrame;

  if (FALSE) {
    layer.backgroundColor = [UIColor orangeColor].CGColor;
  }
  
  [self.view.layer addSublayer:layer];
  
  AVAnimatorLayer *animatorLayer = [AVAnimatorLayer aVAnimatorLayer:layer];

  self.animatorLayer = animatorLayer;

  // Finally connect the media object to the layer so that rendering will be
  // sent to the layer.
  
  [animatorLayer attachMedia:media];
  
  //media.animatorRepeatCount = 3;
  media.animatorRepeatCount = 30;
  
  //[media prepareToAnimate];
  
  [media startAnimator];
  
  return;
}

@end
