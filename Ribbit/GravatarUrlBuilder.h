//
//  GravatarUrlBuilder.h
//  Ribbit
//
//  Copyright (c) 2013 Justin Junda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GravatarUrlBuilder : NSObject

+ (NSURL *)getGravatarUrl:(NSString *)email;

@end
