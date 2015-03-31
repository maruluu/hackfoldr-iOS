//
//  HackfoldrClient.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrClient.h"

#import "AFCSVParserResponseSerializer.h"
#import "HackfoldrPage.h"

@implementation HackfoldrTaskCompletionSource

+ (HackfoldrTaskCompletionSource *)taskCompletionSource
{
	return [[HackfoldrTaskCompletionSource alloc] init];
}

- (void)dealloc
{
	[self.connectionTask cancel];
	self.connectionTask = nil;
}

- (void)cancel
{
	[self.connectionTask cancel];
	[super cancel];
}

@end

#pragma mark -

@interface HackfoldrClient ()

@end

@implementation HackfoldrClient

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    static HackfoldrClient *shareClient;
    dispatch_once(&onceToken, ^{
        shareClient = [[HackfoldrClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://ethercalc.org/"]];
    });
    return shareClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        AFCSVParserResponseSerializer *serializer = [AFCSVParserResponseSerializer serializer];
        serializer.usedEncoding = NSUTF8StringEncoding;
		self.responseSerializer = serializer;
    }
    return self;
}

- (HackfoldrTaskCompletionSource *)_taskCompletionWithPath:(NSString *)inPath
{
    HackfoldrTaskCompletionSource *source = [HackfoldrTaskCompletionSource taskCompletionSource];
    NSString *requestPath = [NSString stringWithFormat:@"_/%@/csv", inPath];
    source.connectionTask = [self GET:requestPath parameters:nil success:^(NSURLSessionDataTask *task, id csvFieldArray) {
        HackfoldrPage *page = [[HackfoldrPage alloc] initWithFieldArray:csvFieldArray];
        _lastPage = page;
        [source setResult:page];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [source setError:error];
    }];
    return source;
}

- (HackfoldrTaskCompletionSource *)taskCompletionPagaDataAtPath:(NSString *)inPath
{
    return [self _taskCompletionWithPath:inPath];
}

- (BFTask *)pagaDataAtPath:(NSString *)inPath
{
    return [self taskCompletionPagaDataAtPath:inPath].task;
}

@end
