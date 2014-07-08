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


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps completed:(void (^)(BOOL success))completed;
+ (void) createSprayTo:(NSMutableArray *)recipients withBatchId: (NSString *) batchId withNumOfTaps: (NSUInteger) numOfTaps withDirect: (BOOL) isDirect;

+ (void) updateInteractions:(NSMutableArray *)recipients withBatchId:(NSString *)batchId;

@end
