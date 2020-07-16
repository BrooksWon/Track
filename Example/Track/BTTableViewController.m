//
//  BTTableViewController.m
//  Track_Example
//
//  Created by Brooks on 2020/7/15.
//  Copyright © 2020 BrooksWon. All rights reserved.
//

#import "BTTableViewController.h"
#import "UIView+Track.h"
#import "Masonry.h"

@interface BTTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) UIView *redView;

@end

@implementation BTTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"test";
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    
    [self.view addSubview:self.redView];
       [self.redView bt_setTrackTag:@"red"];
       [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.width.height.mas_equalTo(60.0);
           make.center.mas_equalTo(self.view);
       }];
}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if(cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell bt_setTrackTag:@"tableView" position:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //todo
    }else if (indexPath.row == 1) {
        self.redView.hidden = !self.redView.hidden;
    }else if (indexPath.row == 2) {
        self.redView.alpha = 0.01;
    }else {
        self.redView.alpha = 1;
    }
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIView *)redView {
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.backgroundColor = [UIColor redColor];
    }
    return _redView;
}

@end
