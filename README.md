# DKCarouselView
![GIF](https://raw.githubusercontent.com/zhangao0086/DKCarouselView/master/preview.gif)
## Overview
DKCarouselView is a automatically & circular infinite scrolling view.The view auto paging/pause can be specified as well.It supports the use of blocks for user interactions.

## How To Get Started

## Installation with CocoaPods
``` bash
$ pod search DKCarouselView

-> DKCarouselView (1.0.0)
   A automatically & circular infinite scrolling view.
   pod 'DKCarouselView', '~> 1.0.0'
   - Homepage: https://github.com/zhangao0086/DKCarouselView
   - Source:   https://github.com/zhangao0086/DKCarouselView.git
   - Versions: 1.0.0 [master repo]
```

Edit your Podfile and add DKCarouselView:

``` bash
pod 'DKCarouselView', '~> x.x.x'
```

Add `#import "DKCarouselView.h"` to the top of classes that will use it.  
##### Create instances (Also supports xib/storyboard)

```  objective-c
DKCarouselView *carouselView = [[DKCarouselView alloc] initWithFrame:CGRectMake(0, 0, 320,220)];
```

##### Setup items

```  objective-c
NSArray *images = @[@"https://c1.staticflickr.com/9/8428/7855079606_5fc8852562_z.jpg",
                    @"http://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Parang_mountain_image_1.jpg/640px-Parang_mountain_image_1.jpg",
                    @"http://www.openjpeg.org/samples/Bretagne1.bmp",
                    @"http://blog.absolutvision.com/wp-content/uploads/2009/10/Gimp_2.6b.jpg"
                    ];
NSMutableArray *items = [NSMutableArray new];
for (NSString *imageUrl in images) {
    DKPaginationURLAd *urlAD = [DKPaginationURLAd new];
    urlAD.imageUrl = imageUrl;
    
    [items addObject:urlAD];
}
[carouselView setItems:items];
```

##### Auto paging for 5 seconds

```  objective-c
[carouselView setAutoPagingForInterval:5];
```

##### Placeholder for online images

```
carouselView.defaultImage = [UIImage imageNamed:@"DefaultImage"];
```

##### Callback

```
[self.carouselView setItemClickedBlock:^(DKCarouselItem *item, NSInteger index) {
    NSLog(@"%zd",index);
}];
```

##### DKCarouselURLItem Or DKCarouselViewItem

```  objective-c
/**
 *  Online Image
 */
@interface DKCarouselURLItem : DKCarouselItem

@property (nonatomic, copy) NSString *imageUrl;

@end

/**
 *  Custom View
 */
@interface DKCarouselViewItem : DKCarouselItem

@property (nonatomic, strong) UIView *view;

@end
```

## License
This code is distributed under the terms and conditions of the <a href="https://github.com/zhangao0086/DKCarouselView/master/LICENSE">MIT license</a>.