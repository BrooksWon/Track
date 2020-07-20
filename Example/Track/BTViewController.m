//
//  BTViewController.m
//  Track
//
//  Created by BrooksWon on 07/15/2020.
//  Copyright (c) 2020 BrooksWon. All rights reserved.
//

#import "BTViewController.h"
#import "UIView+Track.h"
#import "Masonry.h"
#import "BTTableViewController.h"

@interface BTViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *shieldV;                           ///<遮挡view

@end

@implementation BTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    UIView *shieldView = [[UIView alloc] init];
    shieldView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:shieldView];
    self.shieldV = shieldView;
    [shieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    [shieldView bt_setTrackTag:@"shieldView" position:1212];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(pushVC)];
}

- (void)pushVC {
    BTTableViewController *vc = [[BTTableViewController alloc] init];
    vc.view.backgroundColor = [UIColor grayColor];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.frame.size.width - 10)/2.0, 100.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UILabel *label = [self addLabelInCell:cell];
    label.text = [NSString stringWithFormat:@"%ld",indexPath.row];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [cell bt_setTrackTag:@"collectionView" position:indexPath.row];
    [cell bt_setTrackTag:@"collectionView" position:indexPath.row trackData:@{@"cellForRow":@(indexPath.row)} shieldView:self.shieldV];

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //todo
        [ self.shieldV removeFromSuperview];
    }else if (indexPath.row == 1) {
        self.shieldV.hidden = !self.shieldV.hidden;
    }else if (indexPath.row == 2) {
        self.shieldV.alpha = 0.01;
    }else if (indexPath.row == 11) {
        [self.view sendSubviewToBack:self.shieldV];
    }else if (indexPath.row == 12) {
        [self.view bringSubviewToFront:self.shieldV];
    }else if (indexPath.row == 13) {
        [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    }
    else {
        self.shieldV.alpha = 1;
    }
}


- (UILabel *)addLabelInCell:(UICollectionViewCell *)cell {
    __block BOOL hadLB = NO;
    __block UILabel *label = nil;
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UILabel class]] && obj.tag == 1011) {
            *stop = YES;
            hadLB = YES;
            label = obj;
        }
    }];
    if (hadLB) {
        return label;
    } else {
        label = [[UILabel alloc] init];
        label.tag = 1011;
        [cell.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(cell.contentView);
        }];
        return label;
    }
}


#pragma mark - getters and setters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 10.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
