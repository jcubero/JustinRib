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
        PFFile *imageFile = [self.message objectForKey:@"file"];
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        self.imageView.image = [UIImage imageWithData:imageData];
        
    } else {
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        PFFile *videoFile = [self.message objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        
        // Add it to the viewController
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }

    
   /* NSDate *created = [self.message createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];

    NSString *title = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:created]];
    self.navigationItem.title  = title;*/
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[GlobalTimer ribbitTimer] removeObserver:self forKeyPath:@"timerValue" ];
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
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
