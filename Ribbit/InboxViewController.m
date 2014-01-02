//
//  InboxViewController.m
//  Ribbit
//
//  Created by Joaquin Cubero on 03/11/13.
//  Copyright (c) 2013 Joaquin Cubero. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "MSCellAccessory.h"
#import "GlobalTimer.h"

@interface InboxViewController ()

@end

static UITableViewCell* currentCell;
static NSString* currentCellText;
static BOOL isViewing=NO;
static NSTimer* refreshTimer;


@implementation InboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sentComplete = NO;
    self.recivedComplete = NO;
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"Current user: %@", [currentUser username]);
        refreshTimer=  [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(retriveMessages) userInfo:nil repeats:YES];
        
        [self retriveMessages];
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(retriveMessages) forControlEvents:UIControlEventValueChanged];
    
    UILongPressGestureRecognizer* longPressGestureRec =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPressGestureRec.minimumPressDuration = 1.5;
    [self.view addGestureRecognizer:longPressGestureRec];
}

-(void) longPressGesture:(UIGestureRecognizer*)gesture{
    NSLog(@"Long Press");
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [gesture locationInView:self.tableNotifications];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"long press on table view but not on a row");
        } else {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.isHighlighted) {
                
                if (([cell isEqual:currentCell]) && (isViewing)){
                    
                    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
                    
                    [self performSegueWithIdentifier:@"showImage" sender:self];
                    
                    
                }
                else if ((![cell isEqual:currentCell]) && (!isViewing)){
                    if (cell.textLabel.tag==0){
                        currentCell = cell;
                        currentCellText = cell.textLabel.text;
                        isViewing = YES;
                        self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
                        [self performSegueWithIdentifier:@"showImage" sender:self];
                        
                        
                        NSMutableArray *viewedIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"viewedIds"]];
                        NSLog(@"viewedIds: %@", viewedIds);
                        
                        
                        [viewedIds addObject:[[PFUser currentUser] objectId]];
                        [self.selectedMessage setObject:viewedIds forKey:@"viewedIds"];
                        [self.selectedMessage saveInBackground];
                        
                        GlobalTimer* ribbitTimer = [GlobalTimer ribbitTimer];
                        
                        [ribbitTimer startTimer];
                    }
                }
            }
        }
    }
   
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    NSNumber* localTimerValue =[GlobalTimer ribbitTimer].timerValue;
    currentCell.textLabel.text  = [NSString stringWithFormat:@"%@ - %@",currentCellText, localTimerValue];
    
    if ([localTimerValue integerValue]  <= 0){
        currentCell.textLabel.text=[NSString stringWithFormat:@"%@",currentCellText];
        if ([[self.selectedMessage objectForKey:@"fileType"] isEqualToString:@"image"])
        {
            currentCell.imageView.image = [UIImage imageNamed:@"read.png"];
        }
        else
        {
            currentCell.imageView.image = [UIImage imageNamed:@"readfilm.png"];
        }
        currentCell.textLabel.tag = 1;
        isViewing = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[GlobalTimer ribbitTimer] removeObserver:self forKeyPath:@"timerValue" ];
   }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [[GlobalTimer ribbitTimer] addObserver:self forKeyPath:@"timerValue" options:NSKeyValueObservingOptionNew context:NULL];
    
    NSNumber* localTimerValue =[GlobalTimer ribbitTimer].timerValue;
    if ((currentCell)&&(isViewing)&&([localTimerValue integerValue]  <= 0))
    {
        currentCell.textLabel.text=[NSString stringWithFormat:@"%@",currentCellText];
       
        
        if ([[self.selectedMessage objectForKey:@"fileType"] isEqualToString:@"image"])
            {
                currentCell.imageView.image = [UIImage imageNamed:@"read.png"];
            }
            else
            {
                 currentCell.imageView.image = [UIImage imageNamed:@"readfilm.png"];
            }
            
        currentCell.textLabel.tag = 1;
        isViewing = NO;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    
    NSDate *created = [message createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:created]];
    
    NSString* currentUserId = [[PFUser currentUser] objectId];
    
    NSMutableArray *viewedIds = [NSMutableArray arrayWithArray:[message objectForKey:@"viewedIds"]];
    
    BOOL wasRead;
    
    
   for (NSString *viewedId in viewedIds) {
       if ([viewedId isEqualToString:currentUserId]){
                wasRead=YES;
        }
    }
    
    NSString *fileType = [message objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        if (wasRead) {
            cell.imageView.image = [UIImage imageNamed:@"read.png"];
            cell.textLabel.tag = 1;
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"unread.png"];
            cell.textLabel.tag = 0;
        }
    }
    else{
        if (wasRead) {
            cell.imageView.image = [UIImage imageNamed:@"readfilm.png"];
            cell.textLabel.tag = 1;
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"unreadfilm.png"];
            cell.textLabel.tag = 0;
        }
    }
    
    if ([[message objectForKey:@"senderId"] isEqualToString: currentUserId]){
        cell.imageView.image = [UIImage imageNamed:@"sent.png"];
        cell.textLabel.tag = 1;
    }
   
    UIColor *color = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:color];
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   /* UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (([cell isEqual:currentCell]) && (isViewing)){
        
        self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"showImage" sender:self];
            
                
    }
    else if ((![cell isEqual:currentCell]) && (!isViewing)){
        if (cell.textLabel.tag==0){
            currentCell = cell;
            currentCellText = cell.textLabel.text;
            isViewing = YES;
            self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"showImage" sender:self];
            
            
            NSMutableArray *viewedIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"viewedIds"]];
            NSLog(@"viewedIds: %@", viewedIds);
            
            
            [viewedIds addObject:[[PFUser currentUser] objectId]];
            [self.selectedMessage setObject:viewedIds forKey:@"viewedIds"];
            [self.selectedMessage saveInBackground];
            
            GlobalTimer* ribbitTimer = [GlobalTimer ribbitTimer];
            
            [ribbitTimer startTimer];
        }
    }*/
}


- (IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if ([segue.identifier isEqualToString:@"showImage"]) {

        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController*)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}

#pragma mark - Helper methods

- (void)retriveMessages
{
    if (!isViewing){
        PFQuery *mySentMessages = [PFQuery queryWithClassName:@"Messages"];
        [mySentMessages whereKey:@"senderId" equalTo:[[PFUser currentUser] objectId]];
        [mySentMessages orderByDescending:@"createdAt"];
        [mySentMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, error.userInfo);
            } else {
                // Found messages!
                self.sentComplete= YES;
                self.sentMessages = objects;
                [self mergeSendRecivedMessage];
            }
        }];
        
        
        PFQuery *myMessages = [PFQuery queryWithClassName:@"Messages"];
        [myMessages whereKey:@"recipientsIds" equalTo:[[PFUser currentUser] objectId]];

        [myMessages orderByDescending:@"createdAt"];
        [myMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, error.userInfo);
            } else {
                // Found messages!
                PFObject *message;
                int i;
                for (i=0; i<[objects count]; i++) {
                    message =[objects objectAtIndex:i];
                    [message setValue:@"" forKey:@"senderId"];
                }
                self.recivedComplete = YES;
                self.recivedMessages = objects;
                [self mergeSendRecivedMessage];
            }
        }];
    }
}

-(void)mergeSendRecivedMessage
{
    if ((self.sentComplete) && (self.recivedComplete)){
        NSMutableSet* unionArray = [[NSMutableSet alloc]init];
        NSArray* sortedArray;
        NSArray* allNotifications;

    
        [unionArray unionSet:[NSSet setWithArray:self.sentMessages]];
    
        [unionArray unionSet:[NSSet setWithArray:self.recivedMessages]];
    
        allNotifications = [unionArray allObjects];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO]; //Just write the key for which you
        NSArray * descriptors = [NSArray arrayWithObject:descriptor];
        sortedArray = [allNotifications sortedArrayUsingDescriptors:descriptors];
        
    
        self.messages =sortedArray;
        [self.tableView reloadData];
        NSLog(@"Retrived %lu messages", (unsigned long)self.messages.count);
    
    
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }

}




@end
