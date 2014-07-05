//
//  TPProcessImage.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPProcessImage : NSObject


+(void)addPost:(NSString *)text andImage:(UIImage *)image completed:(void (^)(BOOL success))completed;


@end
