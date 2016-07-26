//
//  TryCatch.m
//  SwiftyStoryboard
//
//  Created by Sergii Gavryliuk on 2016-07-24.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

#import "TryCatch.h"

@implementation TryCatch

+ (BOOL)tryBlock:(void(^)())tryBlock
           error:(NSError **)error
{
    @try {
        tryBlock ? tryBlock() : nil;
    }
    @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.swiftysb.rtexception"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: exception.description,
                                                @"exception": exception}];
        }
        return NO;
    }
    return YES;
}

@end
