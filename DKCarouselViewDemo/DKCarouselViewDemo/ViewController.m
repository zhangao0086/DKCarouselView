//
//  ViewController.m
//  DKCarouselViewDemo
//
//  Created by ZhangAo on 14-11-12.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import "ViewController.h"
#import "DKCarouselView.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet DKCarouselView *carouselView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *images = @[@"https://c1.staticflickr.com/9/8428/7855079606_5fc8852562_z.jpg",
                        @"http://static.vueling.com/cms/media/1216271/malaga.jpg",
                        @"http://www.d10.karoo.net/ruby/quiz/50/duck.bmp",
                        @"http://www.rutadeltempranillo.es/wp-content/uploads/2013/09/puente-genil.jpg",
                        ];
    NSMutableArray *items = [NSMutableArray new];
    for (NSString *imageUrl in images) {
        DKCarouselURLItem *urlAD = [DKCarouselURLItem new];
        urlAD.imageUrl = imageUrl;
        
        [items addObject:urlAD];
    }
    self.carouselView.defaultImage = [UIImage imageNamed:@"DefaultImage"];
//    [self.carouselView setFinite:YES];
    [self.carouselView setItems:items];
    [self.carouselView setAutoPagingForInterval:2];
    [self.carouselView setDidSelectBlock:^(DKCarouselItem *item, NSInteger index) {
        NSLog(@"%zd",index);
    }];
    [self.carouselView setDidChangeBlock:^(DKCarouselView *view, NSInteger index) {
        NSLog(@"%@, %zd", view, index);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
