//
//  DKCarouselView.h
//  DKCarouselView
//
//  Created by ZhangAo on 10/31/11.
//  Copyright 2011 DKCarouselView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DKCarouselItem : NSObject

@property (nonatomic, strong) id userInfo;

@end

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

//////////////////////////////////////////////////////////////////////////////////////////

@interface DKCarouselView : UIView

typedef void(^DKCarouselViewDidSelectBlock)(DKCarouselItem *item, NSInteger index);
typedef void(^DKCarouselViewDidChangeBlock)(DKCarouselView *view, NSInteger index);

@property (nonatomic, readonly) NSUInteger numberOfItems;

// set clicked block
- (void)setDidSelectBlock:(DKCarouselViewDidSelectBlock)didSelectBlock;

// set page changed block
- (void)setDidChangeBlock:(DKCarouselViewDidChangeBlock)didChangeBlock;

 // placeholder for DKCarouselURLItem
@property (nonatomic, strong) UIImage *defaultImage;

// set infinite slide or not, defaults to NO.
@property (nonatomic, assign, getter = isFinite) BOOL finite;

- (void)setItems:(NSArray *)items;

// auto paging.
- (void)setAutoPagingForInterval:(NSTimeInterval)timeInterval;
@property (nonatomic, assign, getter = isPause) BOOL pause;

// indicator
@property (nonatomic, strong) UIColor *indicatorTintColor;
@property (nonatomic, assign) CGPoint indicatorOffset; // default offset is CGPointZero, the indicator is centered horizontally.
@property (nonatomic, readonly) CGSize indicatorSize; // returns minimum size for given items.

@end