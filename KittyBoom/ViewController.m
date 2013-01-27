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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  //media.animatorRepeatCount = 30;
  //media.animatorRepeatCount = INT_MAX;
  
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
  
  layer.opacity = 0.0;
  
  AVAnimatorLayer *animatorLayer = [AVAnimatorLayer aVAnimatorLayer:layer];
  
  self.kittyAnimatorLayer = animatorLayer;
  
  // Finally connect the media object to the layer so that rendering will be
  // sent to the layer.
  
  [animatorLayer attachMedia:media];
  
  //media.animatorRepeatCount = 3;
  //media.animatorRepeatCount = 30;
  media.animatorRepeatCount = INT_MAX;
  
  [media prepareToAnimate];
  
  return;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
 
  [self prepareExplosionMedia];
  
  [self prepareKittyMedia];
    
  // Setup animator ready callback, will be invoked after media is done loading
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(animatorPreparedNotification:)
                                               name:AVAnimatorPreparedToAnimateNotification
                                             object:self.expMedia];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(animatorPreparedNotification:)
                                               name:AVAnimatorPreparedToAnimateNotification
                                             object:self.kittyMedia];
  
  return;
}

// Invoked once a specific media object is ready to animate.

- (void)animatorPreparedNotification:(NSNotification*)notification {
  AVAnimatorMedia *media = notification.object;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:AVAnimatorPreparedToAnimateNotification
                                                object:media];
  
  AVMvidFrameDecoder *decoder = (AVMvidFrameDecoder*) media.frameDecoder;
  NSString *file = [decoder.filePath lastPathComponent];
	NSLog( @"animatorPreparedNotification %@", file);
  
  if (self.kittyMedia.isReadyToAnimate && self.expMedia.isReadyToAnimate) {
    // Both movies are ready to animate
    
    [self startKittyAnimation];
  }
  
  return;
}

- (void) startKittyAnimation
{
  NSLog(@"startKittyAnimation");
  
  CALayer *layer = self.kittyAnimatorLayer.layer;
  
  layer.opacity = 1.0;
  
  [CATransaction begin];

  NSValue *currentPosition = [layer valueForKey:@"position"];
  CGPoint currentPoint = [currentPosition CGPointValue];
  CGPoint startPoint = currentPoint;
  startPoint.x = 0;
  
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  
  animation.duration = 7.0f;
  animation.fromValue = [NSValue valueWithCGPoint:startPoint];
  animation.toValue = [NSValue valueWithCGPoint:currentPoint];
  
  [CATransaction setCompletionBlock:^{
    // Done with animation, invoke callback on this object
    [self doKittyBoom];
  }];
  
  // Add the animation, overriding the implicit animation.
  [layer addAnimation:animation forKey:@"position"];
  
  [CATransaction commit];
  
  // Start kitty skipping loop
  
  [self.kittyMedia startAnimator];
}

// Invoked when kitty skip animation is complete

- (void) doKittyBoom
{
  [self.kittyMedia stopAnimator];
  [self.expMedia startAnimator];
  
  // Animate kitty opacity to zero
  
  {
    CALayer *layer = self.kittyAnimatorLayer.layer;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0f];
    layer.opacity = 0.0;
    [CATransaction commit];
  }

  // Kick off callback when explosion animation is finished
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(explosionDoneNotification:)
                                               name:AVAnimatorDoneNotification
                                             object:self.expMedia];
  
  return;
}

// Invoked once the explosion animation is completed

- (void) explosionDoneNotification:(NSNotification*)notification {
  AVAnimatorMedia *media = notification.object;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:AVAnimatorDoneNotification
                                                object:media];
  
	NSLog(@"explosionDoneNotification");
  
  // Start the kitty skip animation again
  
  [self.expMedia stopAnimator];

  [self startKittyAnimation];
  
  return;
}

@end
