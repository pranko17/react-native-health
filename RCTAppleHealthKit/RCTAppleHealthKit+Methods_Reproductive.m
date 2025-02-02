//
//  RCTAppleHealthKit+Methods_Results.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "RCTAppleHealthKit+Methods_Reproductive.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Reproductive)

- (void)reproductive_getSexualActivity:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    double limit = [RCTAppleHealthKit doubleFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:HKSampleSortIdentifierEndDate
                                            ascending:NO
    ];
    
    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];
    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];
    
    HKSampleQuery *query = [[HKSampleQuery alloc]
                            initWithSampleType:type
                            predicate:predicate
                            limit: limit
                            sortDescriptors:@[timeSortDescriptor]
                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if (error != nil) {
            NSLog(@"error with fetchCumulativeSumStatisticsCollection: %@", error);
            callback(@[RCTMakeError(@"error with fetchCumulativeSumStatisticsCollection", error, nil)]);
            return;
        }
        
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:(10)];
        
        for (HKCategorySample *sample in results) {
            NSLog(@"sample for sexual activity %@", sample);
            NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
            NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
            
            NSDictionary *elem = @{
                @"startDate" : startDateString,
                @"endDate" : endDateString,
                @"metadata": sample.metadata == nil ? [NSNull null] : sample.metadata,
            };
            
            [data addObject:elem];
        }
        callback(@[[NSNull null], data]);
    }
    ];
    [self.healthStore executeQuery:query];
}

- (void)reproductive_saveSexualActivity:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double value = [RCTAppleHealthKit doubleFromOptions:input key:@"value" withDefault:(double)0];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    NSDictionary *metadata = [RCTAppleHealthKit metadataFromOptions:input withDefault: @{}];
    
    if(startDate == nil || endDate == nil){
        callback(@[RCTMakeError(@"startDate and endDate are required in options", nil, nil)]);
        return;
    }
    
    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier: HKCategoryTypeIdentifierSexualActivity];
    HKCategorySample *sample = [HKCategorySample categorySampleWithType:type value:value startDate:startDate endDate:endDate metadata:metadata];
    
    
    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(value)]);
    }];
    
}

@end
