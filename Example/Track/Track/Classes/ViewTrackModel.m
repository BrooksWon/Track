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

- (BOOL)isEqual:(ViewTrackModel *)object {
    if (!object) {
        return NO;
    }
    return  [self.tag isEqual:object.tag] && self.position == object.position && [self.data isEqualToDictionary:object.data];
}

@end
