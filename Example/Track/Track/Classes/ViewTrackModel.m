//
//  ViewTrackModel.m
//  Track
//
//  Created by Brooks on 2020/7/15.
//

#import "ViewTrackModel.h"

@implementation ViewTrackModel

- (instancetype)initWithTag:(NSString *)tag {
    if (!tag) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.tag = tag;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    if (self.tag) dictionary[NSStringFromSelector(@selector(tag))]              = self.tag;
    if (@(self.position)) dictionary[NSStringFromSelector(@selector(position))] = @(self.position);
    if (self.data) dictionary[NSStringFromSelector(@selector(data))]            = self.data;
    
    return [dictionary copy];
}

- (NSString *)description {
    NSDictionary *dictionary = [self toDictionary];
    
    NSData *jsonData   = nil;
    NSError *jsonError = nil;
    
    @try {
        jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&jsonError];
    } @catch (NSException *exception) {
        // this should not happen in properly design
        // usually means there was no reverse transformer for a custom property
        NSLog(@"eventPayload JSON serialization exception: %@", exception.description);
        return @"{}";
    }
    
    if (!jsonData) {
        return @"{}";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (BOOL)isEqual:(ViewTrackModel *)object {
    if (!object) {
        return NO;
    }
    return  [self.tag isEqual:object.tag] && self.position == object.position && [self.data isEqualToDictionary:object.data];
}

@end
