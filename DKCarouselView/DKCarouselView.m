//
//  DKCarouselView.m
//  DKCarouselView
//
//  Created by ZhangAo on 10/31/11.
//  Copyright 2011 DKCarouselView. All rights reserved.
//

#import "DKCarouselView.h"
#import "UIImageView+WebCache.h"

typedef void(^TapBlock)();

@interface DKImageViewTap : UIImageView

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) TapBlock tapBlock;

@end

@implementation DKImageViewTap

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        self.enable = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enable) return;
    if (self.tapBlock) {
        self.tapBlock();
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

@end

////////////////////////////////////////////////////////////////////////////////////////

@implementation DKCarouselItem

@end

@implementation DKCarouselURLItem

@end

@implementation DKCarouselViewItem

@end

////////////////////////////////////////////////////////////////////////

@interface DKCarouselView () <UIScrollViewDelegate>
@property (nonatomic, assign) NSUInteger shouldBeCurrentPage;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *autoPagingTimer;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) NSMutableArray *carouselItemViews;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, assign) CGRect lstRect;

@end

@implementation DKCarouselView

@dynamic numberOfItems;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _currentPage = 0;
    self.lstRect = CGRectZero;
    //        _stretchingImage = YES;
    self.carouselItemViews = [[NSMutableArray alloc] initWithCapacity:5];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    _scrollView.showsHorizontalScrollIndicator = _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    self.indicatorTintColor = [UIColor lightGrayColor];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = self.indicatorTintColor;
    pageControl.userInteractionEnabled = NO;
    self.pageControl = pageControl;
    
    [self addSubview:_scrollView];
    [self addSubview:pageControl];
    self.clipsToBounds = YES;
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        [self.autoPagingTimer invalidate];
        self.autoPagingTimer = nil;
    }
}

-(void)dealloc{
    [self.autoPagingTimer invalidate];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.lstRect, self.frame)) return;
    self.lstRect = self.frame;
    
    _scrollView.frame = self.bounds;
    
    if (self.carouselItemViews.count == 0) {
        return;
    }
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * 3, CGRectGetHeight(self.bounds));
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
    
    [self.carouselItemViews[self.currentPage] setFrame:CGRectMake(CGRectGetWidth(self.scrollView.bounds), 0,
                                                        CGRectGetWidth(self.scrollView.bounds),
                                                        CGRectGetHeight(self.scrollView.bounds))];

    CGRect newPageControlFrame;
    newPageControlFrame.size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];;
    newPageControlFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - newPageControlFrame.size.width - 10,
                                             CGRectGetHeight(self.bounds) - newPageControlFrame.size.height);
    self.pageControl.frame = newPageControlFrame;
}

#pragma mark - Public

- (void)setIndicatorTintColor:(UIColor *)indicatorTintColor {
    _indicatorTintColor = indicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = indicatorTintColor;
}

-(void)setItems:(NSArray *)items{
    if (items == nil) return;
    
    [self.carouselItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.carouselItemViews removeAllObjects];
    self.pageControl.numberOfPages = 0;
    
    if (items.count == 0) return;
    
    _items = nil;
    _items = [items copy];
    
    self.pageControl.numberOfPages = _items.count;
    self.currentPage = 0;
    self.pageControl.currentPage = self.currentPage;
    
    _scrollView.scrollEnabled = _items.count > 1;
    
    NSInteger index = 0;
    for (DKCarouselItem *item in _items) {
        DKImageViewTap *itemView = [[DKImageViewTap alloc] init];
        itemView.userInteractionEnabled = YES;
        if ([item isKindOfClass:[DKCarouselURLItem class]]) {
            NSString *imageUrl = [(DKCarouselURLItem *)item imageUrl];
            [itemView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:self.defaultImage];
        } else if ([item isKindOfClass:[DKCarouselViewItem class]]) {
            UIView *customView = [(DKCarouselViewItem *)item view];
            [itemView addSubview:customView];
            customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        } else {
            assert(0);
        }
        
        [itemView setTapBlock:^ {
            if (self.itemClickedBlock != nil) {
                self.itemClickedBlock(item,index);
            }
        }];
        index++;
        [self.carouselItemViews addObject:itemView];
    }
    [_scrollView addSubview:self.carouselItemViews.firstObject];
    self.lstRect = CGRectZero;
    
    [self setNeedsLayout];
}

-(void)setAutoPagingForInterval:(NSTimeInterval)timeInterval{
    assert(timeInterval >= 0);
    if (self.autoPagingTimer.timeInterval == timeInterval) {
        [self setPause:NO];
        return;
    }
    
    if (self.autoPagingTimer) {
        [self.autoPagingTimer invalidate];
        self.autoPagingTimer = nil;
        if (timeInterval == 0) return;
    }
    self.autoPagingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                            target:self
                                                          selector:@selector(paging)
                                                          userInfo:nil
                                                           repeats:YES];
}

-(void)paging{
    [_scrollView scrollRectToVisible:CGRectMake(2 * CGRectGetWidth(_scrollView.bounds), 0,
                                                CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds)) animated:YES];
}

-(void)setPause:(BOOL)pause{
    if (self.autoPagingTimer.timeInterval == 0) return;
    if (_pause == pause) return;
    if (!self.autoPagingTimer) return;
    _pause = pause;
    if (pause) {
        self.autoPagingTimer.fireDate = [NSDate distantFuture];
    } else {
        self.autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.autoPagingTimer.timeInterval];
    }
}

-(NSUInteger)numberOfItems{
    return _items.count ? _items.count : 0;
}

-(void)insertPreviousPage{
    UIView *currentView = self.carouselItemViews[self.shouldBeCurrentPage];
    currentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [_scrollView addSubview:currentView];
}

-(void)insertNextPage{
    UIView *currentView = self.carouselItemViews[self.shouldBeCurrentPage];
    currentView.frame = CGRectMake(CGRectGetWidth(self.scrollView.bounds) * 2, 0,
                                   CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [_scrollView addSubview:currentView];
}
#pragma mark UIScrollView Delegate Methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.isDragging) {
        self.autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.autoPagingTimer.timeInterval];
    }
    if (scrollView.subviews.count == 1) {
        if (scrollView.contentOffset.x > CGRectGetWidth(scrollView.bounds)) {
            if (self.currentPage == self.carouselItemViews.count - 1) {
                self.shouldBeCurrentPage = 0;
            } else {
                self.shouldBeCurrentPage = self.currentPage + 1;
            }
            [self insertNextPage];
        } else if (scrollView.contentOffset.x < CGRectGetWidth(scrollView.bounds)) {
            if (self.currentPage == 0) {
                self.shouldBeCurrentPage = self.carouselItemViews.count - 1;
            } else {
                self.shouldBeCurrentPage = self.currentPage - 1;
            }
            [self insertPreviousPage];
        }
    }
}

// 针对用户手势
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.subviews.count != 1) {
        if (scrollView.contentOffset.x == CGRectGetWidth(scrollView.bounds)) {
            UIView *abandonView = self.carouselItemViews[self.shouldBeCurrentPage];
            [abandonView removeFromSuperview];
        } else {
            scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.bounds), 0);
            UIView *lastView = self.carouselItemViews[self.currentPage];
            UIView *currentView = self.carouselItemViews[self.shouldBeCurrentPage];
            CGRect newFrame = currentView.frame;
            newFrame.origin.x = CGRectGetWidth(scrollView.bounds);
            currentView.frame = newFrame;
            [lastView removeFromSuperview];
            self.currentPage = self.shouldBeCurrentPage;
        }
        self.pageControl.currentPage = self.currentPage;
    }
}

// 针对scrollRectVisible:animated:
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == CGRectGetWidth(scrollView.bounds)) {
        UIView *abandonView = self.carouselItemViews[self.shouldBeCurrentPage];
        [abandonView removeFromSuperview];
    } else {
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.bounds), 0);
        UIView *lastView = self.carouselItemViews[self.currentPage];
        UIView *currentView = self.carouselItemViews[self.shouldBeCurrentPage];
        CGRect newFrame = currentView.frame;
        newFrame.origin.x = CGRectGetWidth(scrollView.bounds);
        currentView.frame = newFrame;
        [lastView removeFromSuperview];
        self.currentPage = self.shouldBeCurrentPage;
    }
    self.pageControl.currentPage = self.currentPage;
}

@end