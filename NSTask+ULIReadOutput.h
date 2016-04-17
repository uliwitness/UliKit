//
//  NSTask+ULIReadOutput.h
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTask (ULIReadOutput)

+(NSTask*)	launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock;
+(NSTask*)	launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock progressHandler: (void(^ _Nullable)(NSTask* sender, NSData* _Nullable output, NSData* _Nullable errOutput))inProgressBlock;;

+(NSTask*)	taskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock progressHandler: (void(^ _Nullable)(NSTask* sender, NSData* _Nullable output, NSData* _Nullable errOutput))inProgressBlock;

@end

NS_ASSUME_NONNULL_END