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


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps withCaption:(NSString *)caption completed:(void (^)(BOOL success))completed;


+ (void)updateInteractions:(NSMutableArray *)recipients withBatchId:(NSString *)batchId;
+(void)updateBroadcast:(NSString *)batchId withFirstCaption:(NSString *)caption;

@end
