//
//  ViewTrackModel.h
//  Track
//
//  Created by Brooks on 2020/7/15.
//

#import <Foundation/Foundation.h>


@interface ViewTrackModel : NSObject

- (instancetype)initWithTag:(NSString *)tag;

@property (nonatomic ,copy) NSString *tag;
@property (nonatomic ,assign) NSInteger position;
@property (nonatomic ,copy) NSDictionary *data;
@property (nonatomic, weak) UIView *shieldView; //遮挡View

@end

