//
//  UIView+Track.h
//  Track
//
//  Created by Brooks on 2020/7/15.
//  优化自 https://mp.weixin.qq.com/s/QQJxGleNylECxPF4whLMgA
//  增加了 1.view被遮挡时不采集曝光，2.view tree 手动变化时自动曝光之前被遮挡的view

#import <UIKit/UIKit.h>
@class ViewTrackModel;

@interface UIView (Track)

@property (nonatomic ,assign) BOOL bt_viewVisible;
@property (nonatomic ,strong ,readonly) ViewTrackModel *bt_trackModel;

- (void)bt_setTrackTag:(NSString *)trackTag;
- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position;
- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData;
- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData shieldView:(UIView *)shieldView;//shieldView, 如果被已知遮挡控件完全覆盖则不算有效曝光 

@end
