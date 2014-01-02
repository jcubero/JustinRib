//
//  ImageViewController.h
//  Ribbit
//
//  Created by Joaquin Cubero on 04/11/13.
//  Copyright (c) 2013 Joaquin Cubero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ImageViewController : UIViewController

@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (strong, nonatomic) IBOutlet UILabel *timerLbl;

@property (nonatomic, strong) MPMoviePlayerViewController *movieViewPlayer;

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end
