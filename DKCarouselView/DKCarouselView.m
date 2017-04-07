//
//  DKCarouselView.m
//  DKCarouselView
//
//  Created by ZhangAo on 10/31/11.
//  Modified by Jiyee Sheng on 02/11/15
//  Copyright 2011 DKCarouselView. All rights reserved.
//

#import "DKCarouselView.h"
#import "FLAnimatedImageView+WebCache.h"

typedef void(^DKCarouselViewTapBlock)();

@interface DKClickableImageView : FLAnimatedImageView

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) DKCarouselViewTapBlock tapBlock;

@end

@implementation DKClickableImageView

// -initWithImage: isn't documented as a designated initializer of UIImageView, but it actually seems to be.
// Using -initWithImage: doesn't call any of the other designated initializers.
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self customComonInit];
    }
    return self;
}

// -initWithImage:highlightedImage: also isn't documented as a designated initializer of UIImageView, but it doesn't call any other designated initializers.
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self customComonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customComonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customComonInit];
    }
    return self;
}

- (void)customComonInit {
    self.userInteractionEnabled = YES;
    self.enable = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGesture];
}

- (IBAction)onTap:(id)sender {
    if (!self.enable) return;
    
    if (self.tapBlock) {
        self.tapBlock();
    }
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

#define GetPreviousIndex()          (self.currentPage - 1 < 0 ? self.carouselItemViews.count - 1 : self.currentPage - 1)
#define GetNextIndex()              (self.currentPage + 1 >= self.carouselItemViews.count ? 0 : self.currentPage + 1)
#define kScrollViewFrameWidth       CGRectGetWidth(self.scrollView.bounds)
#define kScrollViewFrameHeight      CGRectGetHeight(self.scrollView.bounds)
#define ProcessFinite()             do {if (self.finite) return;} while(0)

@interface DKCarouselView () <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) NSMutableArray *carouselItemViews;
@property (nonatomic, readwrite, weak) UIPageControl *pageControl;
@property (nonatomic, assign) CGSize lastSize;

@property (nonatomic, strong) NSTimer *autoPagingTimer;
@property (nonatomic, copy) DKCarouselViewDidSelectBlock didSelectBlock;
@property (nonatomic, copy) DKCarouselViewDidChangeBlock didChangeBlock;

@end

@implementation DKCarouselView

@dynamic numberOfItems;

// Subclasses can override this method to perform any custom initialization
// this method is not called when your view objects are subsequently loaded from the nib file
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.currentPage = 0;
    self.lastSize = CGSizeZero;
    [self setCarouselItemViews:[[NSMutableArray alloc] initWithCapacity:5]];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsHorizontalScrollIndicator = scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    self.indicatorTintColor = [UIColor whiteColor];
    self.indicatorTintColorUnselected = [UIColor lightGrayColor];
    
    UIPageControl *pageControl = [UIPageControl new];
    pageControl.currentPageIndicatorTintColor = self.indicatorTintColor;
    pageControl.pageIndicatorTintColor = self.indicatorTintColorUnselected;
    pageControl.userInteractionEnabled = NO;
    
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    self.clipsToBounds = YES;
    self.finite = NO;
}

// Subclasses can override this method as needed to perform more precise layout of their subviews.
// You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want.
// You can use your implementation to set the frame rectangles of your subviews directly.
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.lastSize, self.bounds.size)) return;
    self.lastSize = self.bounds.size;
    
    self.scrollView.frame = self.bounds;
    
    if (self.carouselItemViews.count == 0) {
        return;
    }
    
    CGRect frame;
    frame.size = self.indicatorSize;
    frame.origin = CGPointMake(CGRectGetWidth(self.bounds) / 2 - frame.size.width / 2 + self.indicatorOffset.x,
                               CGRectGetHeight(self.bounds) - frame.size.height + self.indicatorOffset.y);
    self.pageControl.frame = frame;
    
    [self setupViews];
}

// The default implementation of this method does nothing.
// Subclasses can override it to perform additional actions whenever the superview changes.
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        [self.autoPagingTimer invalidate];
        self.autoPagingTimer = nil;
    }
}

// You should typically not override this method—instead you should put “clean-up” code in prepareForDeletion or didTurnIntoFault.
- (void)dealloc {
    [self.autoPagingTimer invalidate];
}


#pragma mark - Public methods

- (void)setIndicatorIsVisible:(BOOL)indicatorIsVisible {
    _indicatorIsVisible = indicatorIsVisible;
    
    self.pageControl.hidden = !indicatorIsVisible;
}

- (void)setFinite:(BOOL)finite {
    _finite = finite;
    
    self.scrollView.bounces = finite;
}

- (void)setIndicatorTintColor:(UIColor *)indicatorTintColor {
    _indicatorTintColor = indicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = indicatorTintColor;
}

- (void)setIndicatorTintColorUnselected:(UIColor *)indicatorTintColorUnselected {
    _indicatorTintColorUnselected = indicatorTintColorUnselected;
    
    self.pageControl.pageIndicatorTintColor = indicatorTintColorUnselected;
}

- (CGSize)indicatorSize {
    return [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
}

- (void)setSelectedPage: (NSUInteger)selectedPage {
    self.pageControl.currentPage = self.currentPage = selectedPage;
    if (self.carouselItemViews.count > selectedPage){
        if (self.finite) {
            [self.scrollView setContentOffset:CGPointMake(kScrollViewFrameWidth * selectedPage, 0) animated:YES];
        }else{
            [self setupViews];
        }
    }
}

-(void)setItems:(NSArray *)items {
    if (items == nil) return;
    
    [self.carouselItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.carouselItemViews removeAllObjects];
    self.pageControl.numberOfPages = 0;
    
    if (items.count == 0) return;
    
    _items = nil;
    _items = [items copy];
    
    self.pageControl.numberOfPages = _items.count;
    self.currentPage = MIN(self.currentPage, self.pageControl.numberOfPages-1);
    self.pageControl.currentPage = self.currentPage;
    
    _scrollView.scrollEnabled = _items.count > 1;
    
    NSInteger index = 0;
    for (DKCarouselItem *item in _items) {
        DKClickableImageView *itemView = [DKClickableImageView new];
        
        itemView.userInteractionEnabled = YES;
        if ([item isKindOfClass:[DKCarouselURLItem class]]) {
            NSString *imageUrl = [(DKCarouselURLItem *)item imageUrl];
            [itemView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:self.defaultImage];
        } else if ([item isKindOfClass:[DKCarouselViewItem class]]) {
            UIView *customView = [(DKCarouselViewItem *)item view];
            customView.frame = itemView.bounds;
            customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [itemView addSubview:customView];
        } else {
            assert(0);
        }
        
        [itemView setTapBlock:^ {
            if (self.didSelectBlock != nil) {
                self.didSelectBlock(item, index);
            }
        }];
        
        index++;
        [self.carouselItemViews addObject:itemView];
    }
    
    [self setupViews];
    self.lastSize = CGSizeZero;
    
    [self setNeedsLayout];
}

- (void)setDidSelectBlock:(DKCarouselViewDidSelectBlock)didSelectBlock {
    _didSelectBlock = didSelectBlock;
}

- (void)setDidChangeBlock:(DKCarouselViewDidChangeBlock)didChangeBlock {
    _didChangeBlock = didChangeBlock;
}

- (void)setAutoPagingForInterval:(NSTimeInterval)timeInterval {
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
                                                          selector:@selector(pagingNext)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)setPause:(BOOL)pause {
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

- (NSUInteger)numberOfItems {
    return self.items.count ? self.items.count : 0;
}

#pragma mark - Private methods

- (void)pagingNext {
    if (self.pageControl.numberOfPages > 1) {
        if (self.finite) {
            [self.scrollView setContentOffset:CGPointMake(kScrollViewFrameWidth * GetNextIndex(), 0)
                                     animated:YES];
        } else {
            [self.scrollView setContentOffset:CGPointMake(2 * kScrollViewFrameWidth, 0) animated:YES];
        }
    }
}

- (void)setupViews {
    if (self.finite || self.carouselItemViews.count == 1) {
        self.scrollView.contentSize = CGSizeMake(kScrollViewFrameWidth * self.items.count,
                                                 0);
        for (int i = 0; i < self.carouselItemViews.count; i++) {
            UIView *view = self.carouselItemViews[i];
            if (view.superview == nil) {
                [self.scrollView addSubview:view];
            }
            
            view.frame = CGRectMake(i * kScrollViewFrameWidth,
                                    0,
                                    kScrollViewFrameWidth,
                                    kScrollViewFrameHeight);
        }
    } else {
        [self.carouselItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat originX,
        originY = 0;
        
        originX = CGRectGetWidth(self.scrollView.bounds);
        self.scrollView.contentSize = CGSizeMake(kScrollViewFrameWidth * 3, kScrollViewFrameHeight);
        
        [self insertPreviousPage];
        
        self.scrollView.contentOffset = CGPointMake(originX, originY);
        
        UIView *currentView = self.carouselItemViews[self.currentPage];
        currentView.frame = CGRectMake(originX, originY, kScrollViewFrameWidth, kScrollViewFrameHeight);
        [self.scrollView addSubview:currentView];
        
        [self insertNextPage];
        
        [self setNeedsLayout];
    }
}

- (void)insertPreviousPage {
    NSInteger index = GetPreviousIndex();
    UIView *currentView = self.carouselItemViews[index];
    currentView.frame = CGRectMake(0, 0, kScrollViewFrameWidth, kScrollViewFrameHeight);
    [self.scrollView addSubview:currentView];
}

- (void)insertNextPage {
    NSInteger index = GetNextIndex();
    UIView *currentView = self.carouselItemViews[index];
    currentView.frame = CGRectMake(kScrollViewFrameWidth * 2, 0,
                                   kScrollViewFrameWidth, kScrollViewFrameHeight);
    [self.scrollView addSubview:currentView];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        self.autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.autoPagingTimer.timeInterval];
        
        if (self.carouselItemViews.count == 2) {
            if (scrollView.contentOffset.x < kScrollViewFrameWidth) {
                UIView *previousView = self.carouselItemViews[GetPreviousIndex()];
                if (!CGRectEqualToRect(CGRectMake(0, 0, kScrollViewFrameWidth, kScrollViewFrameHeight), previousView.frame)) {
                    [self insertPreviousPage];
                }
            } else if (scrollView.contentOffset.x > kScrollViewFrameWidth * 2) {
                UIView *nextView = self.carouselItemViews[GetNextIndex()];
                if (!CGRectEqualToRect(CGRectMake(kScrollViewFrameWidth * 2, 0, kScrollViewFrameWidth, kScrollViewFrameHeight), nextView.frame)) {
                    [self insertNextPage];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.finite) {
        self.currentPage = scrollView.contentOffset.x / kScrollViewFrameWidth;
    } else {
        NSInteger currentOffsetIndex = scrollView.contentOffset.x / kScrollViewFrameWidth;
        static NSInteger minmiumOffsetIndex = 0;
        NSInteger maxmiumOffsetIndex = scrollView.contentSize.width / kScrollViewFrameWidth - 1;
        
        if (currentOffsetIndex == minmiumOffsetIndex) { //  scroll to previous page
            self.currentPage = GetPreviousIndex();
        } else if (currentOffsetIndex == maxmiumOffsetIndex) {  // scroll to next page
            self.currentPage = GetNextIndex();
        }
        [self setupViews];
    }
    
    if (self.didChangeBlock != nil) {
        self.didChangeBlock(self, self.currentPage);
    }
    
    self.pageControl.currentPage = self.currentPage;
}

// 针对scrollRectVisible:animated:
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

@end
