//
//  ViewController.m
//  WJPageController
//
//  Created by 王杰 on 2018/10/17.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import "ViewController.h"
#import "WJPagesControllerView.h"
#import "RandomColorController.h"

@interface ViewController ()

@property (nonatomic, strong) WJPagesControllerView *pagesView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
}

- (void)setupUI {
    [self.view addSubview:self.pagesView];
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createData];
        });
    });
}

- (void)createData {
    self.pagesView.tabbarSource = @[@"首页", @"关注", @"微时代", @"要闻", @"品牌团", @"美妆达人", @"母婴用品", @"食品饮料", @"服饰", @"家用生活", @"生鲜", @"日用家纺", @"手机", @"数码", @"店铺精选", @"体育", @"娱乐", @"明星写真", @"视频", @"体育新闻", @"段子手", @"NBA", @"轻松一刻", @"历史"];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.pagesView.tabbarSource.count; i++) {
        [array addObject:RandomColorController.new];
    }
    self.pagesView.controllers = [array copy];
    [self.pagesView complete];
}


#pragma mark Setter and Getter

- (WJPagesControllerView *)pagesView {
    if (!_pagesView) {
        _pagesView = [[WJPagesControllerView alloc] init];
        _pagesView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        _pagesView.parentController = self;
    }
    return _pagesView;
}

@end
