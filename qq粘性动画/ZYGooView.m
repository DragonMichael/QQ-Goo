//
//  ZYGooView.m
//  qq粘性动画
//
//  Created by 王志盼 on 16/2/17.
//  Copyright © 2016年 王志盼. All rights reserved.
//

#import "ZYGooView.h"

#define kMaxDistance 100

@interface ZYGooView ()
@property (nonatomic, weak) UIView *smallCircleView;

@property (nonatomic, assign) CGFloat smallCircleR;

@property (nonatomic, weak) CAShapeLayer *shapeLayer;
@end

@implementation ZYGooView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self commitInit];
}

- (void)commitInit
{
    self.layer.cornerRadius = self.frame.size.width * 0.5;
    self.layer.masksToBounds = YES;
    
    self.smallCircleR = self.frame.size.width * 0.5;
    self.smallCircleView.bounds = self.bounds;
    self.smallCircleView.center = self.center;
    self.smallCircleView.layer.cornerRadius = self.smallCircleView.frame.size.width * 0.5;
    
    [self addGesture];
}

#pragma mark ----懒加载方法

- (UIView *)smallCircleView
{
    if (_smallCircleView == nil) {
        UIView *view = [[UIView alloc] init];
        
        view.backgroundColor = self.backgroundColor;
        
        [self.superview addSubview:view];
        
        [self.superview insertSubview:view atIndex:0];
        
        _smallCircleView = view;
        
    }
    return _smallCircleView;
}

- (CAShapeLayer *)shapeLayer
{
    if (_shapeLayer == nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:self.smallCircleView].CGPath;
        shapeLayer.fillColor = self.backgroundColor.CGColor;
        
        [self.superview.layer addSublayer:shapeLayer];
        
        [self.superview.layer insertSublayer:shapeLayer atIndex:0];
        
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer;
}

#pragma mark ----其他方法

- (void)addGesture
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:recognizer];
}



- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.superview];
    
    CGPoint center = self.center;
    center.x += point.x;
    center.y += point.y;
    self.center = center;
    //复位
    [recognizer setTranslation:CGPointZero inView:self];
    
    CGFloat distance = [self distanceWithPointA:self.smallCircleView.center pointB:self.center];
    
    if (distance == 0) return;
    
    CGFloat newR = self.smallCircleR - distance / 15.0;
    NSLog(@"%f", newR);
    self.smallCircleView.bounds = CGRectMake(0, 0, newR * 2, newR * 2);
    self.smallCircleView.layer.cornerRadius = newR;
    
    if (distance > kMaxDistance || newR <= 0) {
        self.smallCircleView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    }
    
    if (distance <= kMaxDistance && self.smallCircleView.hidden == NO) {
        self.shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:self.smallCircleView].CGPath;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (distance <= kMaxDistance) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.shapeLayer removeFromSuperlayer];
                self.shapeLayer = nil;
            });
            
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.smallCircleView.center;
                
            } completion:^(BOOL finished) {
                self.smallCircleView.hidden = NO;
            }];
        }
        else {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            [self addSubview:imageView];
            
            NSMutableArray *images = [NSMutableArray array];
            
            for (int i = 1; i <= 8; i++) {
                NSString *imageName = [NSString stringWithFormat:@"%d", i];
                UIImage *image = [UIImage imageNamed:imageName];
                [images addObject:image];
            }
            
            imageView.animationImages = images;
            imageView.animationDuration = 0.6;
            imageView.animationRepeatCount = 1;
            [imageView startAnimating];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
    }
}

- (CGFloat)distanceWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB
{
    CGFloat dx = pointB.x - pointA.x;
    CGFloat dy = pointB.y - pointA.y;
    
    return sqrt(dx * dx + dy * dy);
}

- (UIBezierPath *)pathWithBigCircleView:(UIView *)bigCircleView smallCircleView:(UIView *)smallCircleView
{
    
    CGPoint bigCenter = bigCircleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCircleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCircleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCircleView.bounds.size.width / 2;
    
    
    
    // 获取圆心距离
    CGFloat d = [self distanceWithPointA:bigCenter pointB:smallCenter];
    
    //Θ:(xita)
    CGFloat sinθ = (x2 - x1) / d;
    
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP =  CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // A
    [path moveToPoint:pointA];
    
    // AB
    [path addLineToPoint:pointB];
    
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    
    
    // CD
    [path addLineToPoint:pointD];
    
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

@end
