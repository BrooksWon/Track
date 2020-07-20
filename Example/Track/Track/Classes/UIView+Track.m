//
//  UIView+Track.m
//  Track
//
//  Created by Brooks on 2020/7/15.
//

#import "UIView+Track.h"
#import "ViewTrackModel.h"
#import <objc/runtime.h>
#import "BTLogStorage.h"

@interface ShieldViewMap : NSObject

@property (nonatomic, strong, readonly) NSMapTable *map;

+ (instancetype)shared;

- (void)setObject:(id)anObject forKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

@implementation ShieldViewMap

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static ShieldViewMap *s = nil;
    dispatch_once(&onceToken, ^{
        s = [[self alloc] init];
    });
    
    return s;
}

- (instancetype)init {
    if (self = [super init]) {
        _map = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)key
{
    NSHashTable *table = [ShieldViewMap.shared.map objectForKey:key];
    if (!table) {
        table = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    }
    [table addObject:anObject];
    [ShieldViewMap.shared.map setObject:table forKey:key];
    NSLog(@"😁");
}

- (void)removeObjectForKey:(id)key
{
    [ShieldViewMap.shared.map removeObjectForKey:key];
}
- (NSHashTable<UIView *> *)objectForKey:(id)key
{
    return [ShieldViewMap.shared.map objectForKey:key];
}


@end

@interface UIView ()

@property (nonatomic ,strong,readwrite) ViewTrackModel *bt_trackModel;
@property (nonatomic ,assign) BOOL bt_trackHasPerform;
@property (nonatomic ,strong) NSMapTable *bt_shieldViewMap;


@end

@implementation UIView (Statistical)

+ (void)exChanageMethodSystemSel:(SEL)systemSel swizzSel:(SEL)swizzSel{
    //两个方法的Method
    Method systemMethod = class_getInstanceMethod([self class], systemSel);
    Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
    BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
    if (isAdd) {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, swizzMethod);
    }
}

//影响一个view是否可见的因素
//1.frame的改变
//2.bounds的改变
//3.view或者父试图是否加载到Window上
//4.Hidden的改变
//5.Alpha的改变
//6.view tree视图树的变化

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL setFrameSel = @selector(setFrame:);
        SEL swizzhSetFrameSel = @selector(bt_setFrame:);
        [[self class] exChanageMethodSystemSel:setFrameSel swizzSel:swizzhSetFrameSel];
        
        SEL setBoundsSel = @selector(setBounds:);
        SEL swizzhSetBoundsSel = @selector(bt_setBounds:);
        [[self class] exChanageMethodSystemSel:setBoundsSel swizzSel:swizzhSetBoundsSel];
        
        SEL didMoveToWindowSel = @selector(didMoveToWindow);
        SEL swizzhdidMoveToWindowSel = @selector(bt_didMoveToWindow);
        [[self class] exChanageMethodSystemSel:didMoveToWindowSel swizzSel:swizzhdidMoveToWindowSel];
        
        SEL setHiddenSel = @selector(setHidden:);
        SEL swizzhSetHiddenSel = @selector(bt_setHidden:);
        [[self class] exChanageMethodSystemSel:setHiddenSel swizzSel:swizzhSetHiddenSel];
        
        SEL setAlphaSel = @selector(setAlpha:);
        SEL swizzhSetAlphaSel = @selector(bt_setAlpha:);
        [[self class] exChanageMethodSystemSel:setAlphaSel swizzSel:swizzhSetAlphaSel];
        
        //        SEL removeFromSuperviewSel = @selector(removeFromSuperview);
        //        SEL swizzhremoveFromSuperviewSel = @selector(bt_removeFromSuperview);
        //        [[self class] exChanageMethodSystemSel:removeFromSuperviewSel swizzSel:swizzhremoveFromSuperviewSel];
        //
        //        SEL bringSubviewToFrontSel = @selector(bringSubviewToFront:);
        //        SEL swizzhBringSubviewToFrontSel = @selector(bt_bringSubviewToFront:);
        //        [[self class] exChanageMethodSystemSel:bringSubviewToFrontSel swizzSel:swizzhBringSubviewToFrontSel];
        
        
        SEL sendSubviewToBackSel = @selector(sendSubviewToBack:);
        SEL swizzhSetSendSubviewToBackSel = @selector(bt_sendSubviewToBack:);
        [[self class] exChanageMethodSystemSel:sendSubviewToBackSel swizzSel:swizzhSetSendSubviewToBackSel];
        
        
        SEL exchangeSubviewAtIndexwithSubviewAtIndexSel = @selector(exchangeSubviewAtIndex:withSubviewAtIndex:);
        SEL swizzhExchangeSubviewAtIndexwithSubviewAtIndexSel = @selector(bt_exchangeSubviewAtIndex:withSubviewAtIndex:);
        [[self class] exChanageMethodSystemSel:exchangeSubviewAtIndexwithSubviewAtIndexSel swizzSel:swizzhExchangeSubviewAtIndexwithSubviewAtIndexSel];
    });
}

- (void)bt_didMoveToWindow {
    [self bt_didMoveToWindow];
    [self bt_updateViewVisible];
    
    //当view移除时，需要取出被它遮盖的view进行曝光统计。
    [self bt_updateCoverViewsByShieldView:self];
}

- (void)bt_setFrame:(CGRect)frame {
    [self bt_setFrame:frame];
    [self bt_updateViewVisible];
}

- (void)bt_setBounds:(CGRect)bounds {
    [self bt_setBounds:bounds];
    [self bt_updateViewVisible];
}

- (void)bt_setHidden:(BOOL)hidden {
    [self bt_setHidden:hidden];
    [self bt_updateViewVisible];
    
    if (hidden) {
        [self bt_updateCoverViewsByShieldView:self];
    }
}

- (void)bt_setAlpha:(CGFloat)alpha {
    [self bt_setAlpha:alpha];
    [self bt_updateViewVisible];
    
    if (alpha <= 0.1) {
        [self bt_updateCoverViewsByShieldView:self];
    }
}

- (void)bt_exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2 {
    //改变view tree时，需要取出被它遮盖的view进行曝光统计。
    NSInteger index = index1>index2 ? index1:index2;
    if (index <= self.subviews.count) {
        [self bt_updateCoverViewsByShieldView:self.subviews[index]];
    }

    [self bt_exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
}

- (void)bt_sendSubviewToBack:(UIView *)view {
    [self bt_sendSubviewToBack:view];
    
    //改变view tree时，需要取出被它遮盖的view进行曝光统计。
    [self bt_updateCoverViewsByShieldView:view];
}


#pragma mark - public methods
- (void)bt_setTrackTag:(NSString *)trackTag {
    [self bt_setTrackTag:trackTag position:0 trackData:nil];
}

- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position {
    [self bt_setTrackTag:trackTag position:position trackData:nil];
}

- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData {
    [self bt_setTrackTag:trackTag position:position trackData:trackData shieldView:nil];
}

- (void)bt_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData shieldView:(UIView *)shieldView {
    ViewTrackModel *trackModel = [[ViewTrackModel alloc] initWithTag:trackTag];
    trackModel.position = position;
    trackModel.data = trackData;
    trackModel.shieldView = shieldView;
    if ([self.bt_trackModel isEqual:trackModel]) {
        return;
    }
    self.bt_trackModel = trackModel;
    if (!trackModel) {
        return;
    }
    
    self.bt_viewVisible = NO;
    [self bt_updateViewVisible];
}

#pragma mark - private methods
- (void)bt_updateCoverViewsByShieldView:(UIView *)view {
    //改变view tree时，需要取出被它遮盖的view进行曝光统计。
    NSHashTable<UIView *> *table = [ShieldViewMap.shared objectForKey:view];
    for (UIView *v in table.allObjects) {
        v.bt_trackModel.shieldView = nil;
    }
    [table.allObjects makeObjectsPerformSelector:@selector(bt_updateViewVisible)];
    [ShieldViewMap.shared removeObjectForKey:self.bt_trackModel.shieldView];
}

- (void)bt_updateViewVisible {
    if (self.bt_trackHasPerform) {
        return;
    }
    self.bt_trackHasPerform = YES;
    
    [self performSelector:@selector(bt_calculateViewVisible) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
    for (UIView *view in self.subviews) {
        [view bt_updateViewVisible];
    }
}

- (void)bt_calculateViewVisible {
    self.bt_trackHasPerform = NO;
    self.bt_viewVisible = [self bt_isDisplayedInScreen];
}

// 判断是否显示在屏幕上
- (BOOL)bt_isDisplayedInScreen {
    
    if (self == nil) {
        return NO;
    }
    
    if (self.hidden){
        return NO;
    }
    
    if (self.alpha <= 0.1) {
        return NO;
    }
    
    if (!self.window){
        return NO;
    }
    
    if (self.superview && ![self.superview.nextResponder isKindOfClass:[UIViewController class]] && !self.superview.bt_viewVisible) {
        return NO;
    }
    
    //iOS11 以下 特殊处理 UITableViewWrapperView 需要使用的supview
    //UITableviewWrapperview 的大小为tableView 在屏幕中出现第一个完整的屏幕大小的视图
    //并且会因为contentOffset的改变而改变，所以UITableviewWrapperview会滑出屏幕，这样因为self.superview.hlj_viewVisible 这个条件导致 他下面的子试图都被判定为不可见，因此将cell的父试图为UITableViewWrapperView的时候，使用tableView 计算
    UIView *view = self;
    if ([NSStringFromClass([self class]) isEqualToString:@"UITableViewWrapperView"]) {
        view = self.superview;
    }
    
    // 与 window 的关系判断
    BOOL showInWidow = NO;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [view convertRect:view.bounds toView:window];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // 包含：算有效显示
    BOOL isContained = CGRectContainsRect(screenRect, rect);
    BOOL isViewRectValid = !CGRectIsEmpty(rect) || !CGRectIsNull(rect);
    if (isContained && isViewRectValid) {
        showInWidow = YES;
    }
    
    // 与 shieldView 关系判断
    BOOL coverByShieldV = NO;
    if (self.bt_trackModel.shieldView
        && !self.bt_trackModel.shieldView.hidden
        && self.bt_trackModel.shieldView.alpha > 0.1
        && self.bt_trackModel.shieldView == self.bt_trackModel.shieldView.superview.subviews.lastObject)
    {
        CGRect shieldViewRect = [self.bt_trackModel.shieldView convertRect:self.bt_trackModel.shieldView.bounds toView:window];
        //        NSLog(@"%@ ===== %@ ==== %ld", NSStringFromCGRect(shieldViewRect), NSStringFromCGRect(self.bt_trackModel.shieldView.bounds), self.bt_trackModel.position);
        BOOL isShieldVRectValid = !CGRectIsEmpty(shieldViewRect) || !CGRectIsNull(shieldViewRect);
        //只要当前view和shieldView有交集、则认为view非有效曝光
        CGRect intersectionRect = CGRectIntersection(shieldViewRect, rect);
        coverByShieldV = ((!CGRectIsEmpty(intersectionRect) && !CGRectIsNull(intersectionRect)) && isShieldVRectValid);
    }
    
    //记录当前view。当view的遮盖层移除时，需要取出view进行曝光统计。
    if (showInWidow && coverByShieldV) {
        [ShieldViewMap.shared setObject:self forKey:self.bt_trackModel.shieldView];
    }
    
    // 根据 window 和 shieldview关系返回结果
    if (showInWidow && !coverByShieldV) {
        
        return YES;
    }
    return NO;
    
}

- (void)bt_viewStatistical {
    NSLog(@"hlj_trackTag:%@,position:%zd",self.bt_trackModel.tag,self.bt_trackModel.position);
#warning 本地存储
    [[BTLogStorage shraed] pushLog:self.bt_trackModel.description];
}

- (void)setBt_viewVisible:(BOOL)bt_viewVisible {
    if (!self.bt_viewVisible && bt_viewVisible) {
        if (self.bt_trackModel) {
            [self bt_viewStatistical];
        }
    }
    objc_setAssociatedObject(self, @selector(bt_viewVisible), @(bt_viewVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bt_viewVisible {
    return [objc_getAssociatedObject(self, @selector(bt_viewVisible)) boolValue];
}

- (ViewTrackModel *)bt_trackModel {
    return objc_getAssociatedObject(self, @selector(bt_trackModel));
}

- (void)setBt_trackModel:(ViewTrackModel *)bt_trackModel {
    objc_setAssociatedObject(self, @selector(bt_trackModel), bt_trackModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bt_trackHasPerform {
    return [objc_getAssociatedObject(self, @selector(bt_trackHasPerform)) boolValue];
}

- (void)setBt_trackHasPerform:(BOOL)bt_trackHasPerform {
    objc_setAssociatedObject(self, @selector(bt_trackHasPerform), @(bt_trackHasPerform), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable *)bt_shieldViewMap {
    return objc_getAssociatedObject(self, @selector(bt_shieldViewMap));
}

- (void)setBt_shieldViewMap:(NSMapTable *)bt_shieldViewMap {
    objc_setAssociatedObject(self, @selector(bt_shieldViewMap), bt_shieldViewMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
