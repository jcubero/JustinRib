//
//  ImageViewController.m
//  Ribbit
//
//  Created by Joaquin Cubero on 04/11/13.
//  Copyright (c) 2013 Joaquin Cubero. All rights reserved.
//

#import "ImageViewController.h"
#import "GlobalTimer.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *fileType = [self.message objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        self.imageView.hidden = NO;
        PFFile *imageFile = [self.message objectForKey:@"file"];
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        self.imageView.image = [UIImage imageWithData:imageData];
    } else {
        PFFile *videoFile = [self.message objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        
        self.movieViewPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileUrl];
        
        [self.movieViewPlayer.view setFrame:self.contentView.frame];
        self.movieViewPlayer.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        
        
        [self.movieViewPlayer.moviePlayer play];
        
        [self.view addSubview:self.movieViewPlayer.view];
    }
}

-(void)playerPlaybackDidFinish:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[GlobalTimer ribbitTimer] removeObserver:self forKeyPath:@"timerValue" ];
    [self.movieViewPlayer.moviePlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSNumber* localTimerValue =[GlobalTimer ribbitTimer].timerValue;
    self.navigationItem.title  = [NSString stringWithFormat:@"%@",localTimerValue];
    
    if ([localTimerValue integerValue]  <= 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GlobalTimer ribbitTimer] addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:NULL];
}


@end
