//
//  InboxViewController.h
//  Ribbit
//
//  Created by Joaquin Cubero on 03/11/13.
//  Copyright (c) 2013 Joaquin Cubero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
@interface InboxViewController : UITableViewController

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSArray *sentMessages;
@property (nonatomic, strong) NSArray *recivedMessages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (IBAction)logOut:(id)sender;

@end
