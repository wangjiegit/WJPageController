//
//  WJPagesControllerView.h
//  WJPageController
//
//  Created by 王杰 on 2018/10/17.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJPagesTabBarView, WJPagesTabBarItem;

@interface WJPagesControllerView : UIView<UIScrollViewDelegate>

@property (nonatomic, weak) UIViewController *parentController;//添加WJPagesControllerView的Controller

@property (nonatomic, copy) NSArray<NSString *> *tabbarSource;//itemTitle

@property (nonatomic, copy) NSArray *controllers;//需要展示的controller

@property (nonatomic, copy) UIColor *titleColor;//字体颜色

@property (nonatomic, copy) UIColor *selectTitleColor;//字体选中颜色

@property (nonatomic) BOOL hiddenIndexView;//隐藏下划线 默认NO

- (void)complete;//设置完数据后 调用

@end

//下面的类可以不用设置

//////////////////////////////////////////////////////////////////////////////////////////////////
@interface WJPagesTabBarView : UIView

@property (nonatomic, strong) UIView *indexView;//下划线

@property (nonatomic, copy) NSArray *dataSource;

@property (nonatomic) CGFloat itemSpcae;//默认20

@property (nonatomic, copy) UIColor *titleColor;

@property (nonatomic, copy) UIColor *selectTitleColor;

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, copy) void(^selectedItemBlock)(void);

- (void)scrollToItemIndex:(NSInteger)index;

- (WJPagesTabBarItem *)itemAtIndex:(NSInteger)index;

@end


///////////////////////////////////////////////////////////////////////////////////////////////
@interface WJPagesTabBarItem : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tgr;

@end
