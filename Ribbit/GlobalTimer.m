//
//  GlobalTimer.m
//  Ribbit
//
//  Created by jcubero on 12/20/13.
//  Copyright (c) 2013 Tord Åsnes. All rights reserved.
//

#import "GlobalTimer.h"

static NSNumber* localTimerValue;


@implementation GlobalTimer
+(GlobalTimer*) ribbitTimer{
    static GlobalTimer* ribbitTimer=nil;
    
    if (!ribbitTimer) {
        ribbitTimer = [[GlobalTimer alloc]init];
    }
    
    return ribbitTimer;
}


-(void)startTimer
{
    if (!self.timer){
        localTimerValue=[NSNumber numberWithInteger:10];
        self.timerValue = [NSNumber numberWithInteger:10];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
    }
    self.isRunning = YES;
}

-(void)stopTimer
{
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    
   
    self.isRunning = NO;
}

-(void)aTime
{
        NSInteger temp = [localTimerValue integerValue];
        temp --;
        localTimerValue= [NSNumber numberWithInteger:temp];
    
    if ([localTimerValue integerValue]  >= 0)
    {
        self.timerValue = [NSNumber numberWithInteger:temp];
    }
    else
    {
        [self stopTimer];
    }
}
@end
