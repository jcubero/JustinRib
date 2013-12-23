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
    
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
    self.imageView.image = [UIImage imageWithData:imageData];
    
    
    NSDate *created = [self.message createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];

    NSString *title = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:created]];
    self.navigationItem.title  = title;
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[GlobalTimer ribbitTimer] removeObserver:self forKeyPath:@"timerValue" ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSNumber* localTimerValue =[GlobalTimer ribbitTimer].timerValue;
    self.navigationItem.title  = [NSString stringWithFormat:@"%@",localTimerValue];
    
    if ([localTimerValue isEqualToNumber:@10]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GlobalTimer ribbitTimer] addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:NULL];
}


@end
