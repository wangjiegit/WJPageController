# WJPageController
![gif](https://github.com/wangjiegit/WJPageController/blob/master/WJPageController/WJPageController.GIF)

## 简单使用

```_pagesView = [[WJPagesControllerView alloc] init];
```_pagesView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
```_pagesView.parentController = self;
`[self.view addSubview:_pagesView];

```_pagesView.tabbarSource = @[@"首页", @"关注", @"微时代", @"要闻", @"品牌团", @"美妆达人", @"母婴用品", @"食品饮料", @"服饰", @"家用生活", @"生鲜", @"日用家纺", @"手机", @"数码", @"店铺精选", @"体育", @"娱乐", @"明星写真", @"视频", @"体育新闻", @"段子手", @"NBA", @"轻松一刻", @"历史"];
```_pagesView.controllers = controllers;
```[_pagesView complete];
