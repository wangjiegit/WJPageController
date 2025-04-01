//
//  WJPagesControllerView.m
//  WJPageController
//
//  Created by 王杰 on 2018/10/17.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import "WJPagesControllerView.h"

#define WJPagesTabBarHeight 36
#define WJPagesTabBarFont 18

typedef NS_ENUM(NSInteger, WJScrollDirection) {
    WJScrollDirectionNone = 0,//点击item滑动
    WJScrollDirectionLeft = 1,//内容向左滑动
    WJScrollDirectionRight = 2,//内容向右滑动
};

@implementation WJPagesControllerView {
    WJPagesTabBarView *_tabBarView;
    UIScrollView *_contentView;
    WJScrollDirection _direction;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        [self setupUI];
    }
    return self;
}

//设置初始值
- (void)prepare {
    self.backgroundColor = [UIColor whiteColor];
    _titleColor = [UIColor lightGrayColor];
    _selectTitleColor = [UIColor blackColor];
}

//添加tabbar和内容
- (void)setupUI {
    _tabBarView = [[WJPagesTabBarView alloc] init];
    _tabBarView.titleColor = _titleColor;
    _tabBarView.selectTitleColor = _selectTitleColor;
    __weak typeof(self) weakSelf = self;
    _tabBarView.selectedItemBlock = ^() {
        [weakSelf handleSelectedItemBack];
    };
    [self addSubview:_tabBarView];
    
    _contentView = [[UIScrollView alloc] init];
    _contentView.pagingEnabled = YES;
    _contentView.delegate = self;
    _contentView.scrollsToTop = NO;
    _contentView.showsHorizontalScrollIndicator = NO;
    [_contentView.panGestureRecognizer addTarget:self action:@selector(scrollViewPan:)];
    [self addSubview:_contentView];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _tabBarView.frame = CGRectMake(0, 0, self.frame.size.width, WJPagesTabBarHeight);
    _contentView.frame = CGRectMake(0, CGRectGetMaxY(_tabBarView.frame), self.frame.size.width, CGRectGetHeight(self.frame) - WJPagesTabBarHeight);
}

//处理点击item回调
- (void)handleSelectedItemBack {
    _direction = WJScrollDirectionNone;
    [self showChildController];
}

//显示selectedIndex对应的controller
- (void)showChildController {
    if (_tabBarView.selectedIndex >= _controllers.count) return;
    _contentView.contentOffset = CGPointMake(_tabBarView.selectedIndex * _contentView.frame.size.width, 0);
    UIViewController *controller = _controllers[_tabBarView.selectedIndex];
    if (!controller.parentViewController) {
        controller.view.frame = CGRectMake(_tabBarView.selectedIndex * _contentView.frame.size.width, 0, _contentView.frame.size.width, CGRectGetHeight(_contentView.frame));
        [_contentView addSubview:controller.view];
        [_parentController addChildViewController:controller];
    }
}

//展示视图
- (void)complete {
    assert(_parentController);
    _tabBarView.dataSource = _tabbarSource;
    _contentView.contentSize = CGSizeMake(_contentView.frame.size.width * _tabbarSource.count, CGRectGetHeight(_contentView.frame) - WJPagesTabBarHeight);
}

#pragma mark - UIScrollViewDelegate
//判断展示左边的视图还是右边的视图
- (void)scrollViewPan:(UIPanGestureRecognizer *)pgr {
    CGPoint velocity = [pgr velocityInView:pgr.view];
    if (velocity.x == 0) return;
    if (velocity.x > 0) {
        _direction = WJSwitchPagesDirectionLeft;
    } else {
        _direction = WJSwitchPagesDirectionRight;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_direction == WJScrollDirectionNone || scrollView.contentOffset.x < 0) return;
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    //currentIndex 不等于_tabBarView.selectedIndex的原因是 防止一次触摸左右滑动出现bug
    NSInteger currentIndex = _direction == WJScrollDirectionLeft ? index + 1 : index;//当前index
    NSInteger nextIndex = _direction == WJScrollDirectionLeft ? index : index + 1;//下一个index
    
    WJPagesTabBarItem *item = [_tabBarView itemAtIndex:currentIndex];
    WJPagesTabBarItem *nextItem = [_tabBarView itemAtIndex:nextIndex];
    
    CGFloat sr = 0, sg = 0, sb = 0;
    [_selectTitleColor getRed:&sr green:&sg blue:&sb alpha:NULL];
    CGFloat nr = 0, ng = 0, nb = 0;
    [_titleColor getRed:&nr green:&ng blue:&nb alpha:NULL];
    
    CGFloat progress = (scrollView.contentOffset.x - scrollView.frame.size.width * currentIndex) / scrollView.frame.size.width;

    CGFloat fabs_progress = fabs(progress);
    
    //颜色跟随滑动距离改变
    item.titleLabel.textColor = [UIColor colorWithRed:sr + (nr - sr) * fabs_progress green:sg + (ng - sg) * fabs_progress blue:sb + (nb - sb) * fabs_progress alpha:1];

    nextItem.titleLabel.textColor = [UIColor colorWithRed:nr + (sr - nr) * fabs_progress green:ng + (sg - ng) * fabs_progress blue:nb + (sb - nb) * fabs_progress alpha:1];

    //下划线跟随滑动距离改变
    CGRect frame = _tabBarView.indexView.frame;
    //x的偏移量
    CGFloat x = ((_direction == WJScrollDirectionLeft ? nextItem.frame.size.width : item.frame.size.width) + _tabBarView.itemSpcae) * progress;
    frame.origin.x = x + item.frame.origin.x;
    //width的改变
    CGFloat w = (nextItem.frame.size.width - item.frame.size.width) * fabs_progress;
    frame.size.width = w + item.frame.size.width;
    _tabBarView.indexView.frame = frame;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollView.scrollEnabled = NO;//防止暴力滑动
}

//滑动停止后 选定需要展示的controller
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = YES;//防止暴力滑动
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (index == _tabBarView.selectedIndex) return;
    [_tabBarView scrollToItemIndex:index];
    [self showChildController];
}

#pragma Setter and Getter

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = [titleColor copy];
    _tabBarView.titleColor = _titleColor;
}

- (void)setSelectTitleColor:(UIColor *)selectTitleColor {
    _selectTitleColor = [selectTitleColor copy];
    _tabBarView.selectTitleColor = _selectTitleColor;
}

- (void)setControllers:(NSArray *)controllers {
    for (UIViewController *vc in _controllers) {
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
    }
    _controllers = [controllers copy];
}

- (void)setHiddenIndexView:(BOOL)hiddenIndexView {
    _hiddenIndexView = hiddenIndexView;
    _tabBarView.indexView.hidden = hiddenIndexView;
}

@end

//////////////////////////////////////////////////////

@implementation WJPagesTabBarView {
    UIScrollView *_contentView;
    NSArray *_subViewList;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        [self setupUI];
    }
    return self;
}

//默认间距
- (void)prepare {
    _itemSpcae = 20;
}

- (void)setupUI {
    _contentView = [[UIScrollView alloc] init];
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.scrollsToTop = NO;
    [self addSubview:_contentView];
    
    _indexView = [[UIView alloc] init];
    [_contentView addSubview:_indexView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

#pragma mark Function

- (WJPagesTabBarItem *)itemAtIndex:(NSInteger)index {
    if (index < _subViewList.count) {
        return _subViewList[index];
    }
    return nil;
}

//拖动结束后设置对应的属性
- (void)scrollToItemIndex:(NSInteger)index {
    [self selectItemIndex:index animations:NO];
}

//处理选中的item
- (void)selectItemIndex:(NSInteger)index animations:(BOOL)animations {
    if (index >= _subViewList.count) return;
    WJPagesTabBarItem *oldItem = _subViewList[_selectedIndex];
    oldItem.titleLabel.textColor = _titleColor;
    _selectedIndex = index;
    WJPagesTabBarItem *item = _subViewList[index];
    item.titleLabel.textColor = _selectTitleColor;
    //让item在scrollView中居中显示
    CGFloat offsetX = item.center.x - self.frame.size.width / 2.0;
    if (offsetX < 0) offsetX = 0;
    CGFloat offsetMax = _contentView.contentSize.width - self.frame.size.width;
    if (offsetX > offsetMax) offsetX = offsetMax;
    [_contentView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    __weak typeof(_indexView) weakIndexView = _indexView;
    if (animations) {
        [UIView animateWithDuration:0.2 animations:^{
            weakIndexView.frame = CGRectMake(item.frame.origin.x, WJPagesTabBarHeight - 2, item.frame.size.width, 2);
        }];
    } else {
        _indexView.frame = CGRectMake(item.frame.origin.x, WJPagesTabBarHeight - 2, item.frame.size.width, 2);
    }
}

#pragma mark TouchEvent

//点击某个item
- (void)clickItem:(UITapGestureRecognizer *)tgr {
    WJPagesTabBarItem *newItem = (WJPagesTabBarItem *)tgr.view;
    NSInteger index = [_subViewList indexOfObject:newItem];
    if (index == _selectedIndex) return;
    [self selectItemIndex:index animations:YES];
    if (_selectedItemBlock) _selectedItemBlock();
}

#pragma mark Setter and Getter

//设置展示多少个item 并且默认选中第0个
- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = [dataSource copy];
    [_subViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (dataSource.count > 0) {
        NSMutableArray *views = [NSMutableArray array];
        CGFloat x = self.itemSpcae / 2.0;
        for (NSString *title in _dataSource) {
            WJPagesTabBarItem *item = [[WJPagesTabBarItem alloc] init];
            CGRect rect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, WJPagesTabBarHeight) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:WJPagesTabBarFont]} context:NULL];
            item.frame = CGRectMake(x, 0, ceilf(rect.size.width), WJPagesTabBarHeight);
            item.titleLabel.textColor = _titleColor;
            item.titleLabel.text = title;
            [item.tgr addTarget:self action:@selector(clickItem:)];
            [_contentView addSubview:item];
            [views addObject:item];
            x += (item.frame.size.width + self.itemSpcae);
        }
        _contentView.contentSize = CGSizeMake(x, WJPagesTabBarHeight);
        _subViewList = [views copy];
        _indexView.backgroundColor = _selectTitleColor;
        [self selectItemIndex:0 animations:NO];
        if (_selectedItemBlock) _selectedItemBlock();
    }
}

@end

///////////////////////////////////////////////////////////////////////////

@implementation WJPagesTabBarItem 

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:WJPagesTabBarFont];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    _tgr = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:_tgr];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

@end
