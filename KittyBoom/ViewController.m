//
//  ViewController.m
//  KittyBoom
//
//  Created by Moses DeJong on 12/31/12.
//

#import "ViewController.h"

#import "AVFileUtil.h"

#import "AVAssetJoinAlphaResourceLoader.h"

#import "AVApng2MvidResourceLoader.h"

#import "AVAnimatorMedia.h"

#import "AVAnimatorLayer.h"

#import "AVMvidFrameDecoder.h"

#import <QuartzCore/QuartzCore.h>

#import "AutoPropertyRelease.h"

@interface ViewController ()

// Explosion

@property (nonatomic, retain) AVAnimatorMedia *expMedia;

@property (nonatomic, retain) AVAnimatorLayer *expAnimatorLayer;

// Kitty run loop

@property (nonatomic, retain) AVAnimatorMedia *kittyMedia;

@property (nonatomic, retain) AVAnimatorLayer *kittyAnimatorLayer;

@end

@implementation ViewController

- (void) dealloc
{
  [AutoPropertyRelease releaseProperties:self thisClass:ViewController.class];
  [super dealloc];
}

// Prepare media player for Explosion video as assign to self.expMedia

- (void) prepareExplosionMedia
{
  // Create resource loader that will combine RGB and Alpha values back
  // into one Maxvid file.
  
  CGRect iPhoneExplosionRect = CGRectMake(0, -2, 640/2, 480/2);
  CGRect iPadExplosionRect = CGRectMake(0, -5, 840, 630);
  
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
  
  self.expMedia = media;
  
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
  
  self.expAnimatorLayer = animatorLayer;
  
  // Finally connect the media object to the layer so that rendering will be
  // sent to the layer.
  
  [animatorLayer attachMedia:media];
  
  //media.animatorRepeatCount = 3;
  media.animatorRepeatCount = 30;
  
  [media prepareToAnimate];
  
  return;
}

// Prepare media player for Explosion video as assign to self.kittyMedia

- (void) prepareKittyMedia
{
  // Kitty animation 112x115 pixels

  CGPoint iPhoneKittyExplosionPoint = CGPointMake(166, 155);
  CGPoint iPadKittyExplosionPoint = CGPointMake(470, 440);
  
  CGRect iPhoneKittyRect = CGRectMake(iPhoneKittyExplosionPoint.x, iPhoneKittyExplosionPoint.y, 112/2, 115.0/2);
  CGRect iPadKittyRect = CGRectMake(iPadKittyExplosionPoint.x, iPadKittyExplosionPoint.y, 112, 115.0);
  
  NSString *kittyResourceName = @"kitty-run.apng";
  
  // Output filename
  
  NSString *tmpFilename;
  NSString *tmpPath;
  tmpFilename = @"kitty-run.mvid";
  tmpPath = [AVFileUtil getTmpDirPath:tmpFilename];
  
  // Set to TRUE to always decode from H.264
  
  BOOL alwaysDecode = FALSE;
  
  if (alwaysDecode && [AVFileUtil fileExists:tmpPath]) {
    BOOL worked = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    NSAssert(worked, @"could not remove file %@", tmpPath);
  }
  
  // This loader will decode an APNG (png8 table encoded) to 32BPP .mvid
  
  AVApng2MvidResourceLoader *resLoader = [AVApng2MvidResourceLoader aVApng2MvidResourceLoader];
  
  resLoader.movieFilename = kittyResourceName;
  resLoader.outPath = tmpPath;
  //resLoader.alwaysGenerateAdler = TRUE;
  
  AVAnimatorMedia *media = [AVAnimatorMedia aVAnimatorMedia];
  media.resourceLoader = resLoader;
  
  self.kittyMedia = media;
  
  // Frame decoder will read from generated .mvid file
  
  AVMvidFrameDecoder *aVMvidFrameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
  media.frameDecoder = aVMvidFrameDecoder;
  
  // Create layer that video data will be directed into
  
  CGRect expFrame;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    expFrame = iPhoneKittyRect;
  } else {
    expFrame = iPadKittyRect;
  }
  
  CALayer *layer = [CALayer layer];
  layer.frame = expFrame;
  
  if (FALSE) {
    layer.backgroundColor = [UIColor orangeColor].CGColor;
  }
  
  [self.view.layer addSublayer:layer];
  
  AVAnimatorLayer *animatorLayer = [AVAnimatorLayer aVAnimatorLayer:layer];
  
  self.kittyAnimatorLayer = animatorLayer;
  
  // Finally connect the media object to the layer so that rendering will be
  // sent to the layer.
  
  [animatorLayer attachMedia:media];
  
  //media.animatorRepeatCount = 3;
  media.animatorRepeatCount = 30;
  
  [media prepareToAnimate];
  
  return;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
 
  [self prepareExplosionMedia];
  
  [self prepareKittyMedia];
  
  [self.expMedia startAnimator];

  [self.kittyMedia startAnimator];
  
  return;
}

@end
