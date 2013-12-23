//
//  FriendsViewController.h
//  Ribbit
//
//  Created by Joaquin Cubero on 04/11/13.
//  Copyright (c) 2013 Joaquin Cubero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;

@end
