//
//  TPProcessImage.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAppDelegate.h"
@interface TPProcessImage : NSObject


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(UIImage *)image inBatch:(NSString *)batchId completed:(void (^)(BOOL success))completed;

@end
