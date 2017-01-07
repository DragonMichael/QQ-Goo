//
//  ViewController.m
//  qq粘性动画
//
//  Created by 王志盼 on 16/2/17.
//  Copyright © 2016年 王志盼. All rights reserved.
//

#import "ViewController.h"
#import "ZYGooView.h"

@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int count;

@property (nonatomic, strong) ZYGooView *gooView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.gooView = [[ZYGooView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    self.gooView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.gooView];
    
//    [self setupTimer];
}

- (void)setupTimer
{
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

//截图
- (void)updateTimer
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSString *path = [NSString stringWithFormat:@"//Users//wangzhipan1//Desktop//%d.png", self.count++];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}
@end
