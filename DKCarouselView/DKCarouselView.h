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

////////////////////////////////////////////////////////////////////////

typedef void(^ItemClicked)(DKCarouselItem *ad, NSInteger index);

@interface DKCarouselView : UIView

//@property (nonatomic, assign) BOOL stretchingImage;
@property (nonatomic, readonly) NSUInteger numberOfItems;

@property (nonatomic, copy) ItemClicked itemClickedBlock;

-(void)setItems:(NSArray *)items;

-(void)setAutoPagingForInterval:(NSTimeInterval)timeInterval;
@property (nonatomic, assign, getter = isPause) BOOL pause;

@property (nonatomic, strong) UIColor *indicatorTintColor;

@end