//
//  TryCatch.h
//  SwiftyStoryboard
//
//  Created by Sergii Gavryliuk on 2016-07-24.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface TryCatch : NSObject

+ (BOOL)tryBlock:(void(^)())tryBlock
           error:(NSError **)error;

@end
