//
//  GlobalTimer.h
//  Ribbit
//
//  Created by jcubero on 12/20/13.
//  Copyright (c) 2013 Tord Åsnes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalTimer : NSObject
    @property (nonatomic,retain) NSNumber *timerValue;
    @property (nonatomic,strong)NSTimer *timer ;
    @property  BOOL isRunning;

    +(GlobalTimer*) ribbitTimer;

    -(void) startTimer;

    -(void) stopTimer;
@end
