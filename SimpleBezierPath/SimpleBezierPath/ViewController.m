//
//  ViewController.m
//  SimpleBezierPath
//
//  Created by iZhihuicheng on 2018/5/23.
//  Copyright © 2018年 iZhihuicheng. All rights reserved.
//

#import "ViewController.h"
#import "UIViewExt.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

const static CGFloat kPoinY = 130.0;
const static CGFloat kArcHeight = 100.0;

@interface ViewController () <CAAnimationDelegate>

/** 上部的View */
@property (nonatomic , strong) UIView *topView;
/** 下部的View */
@property (nonatomic , strong) UIView *bottomView;
/** 展开按钮 */
@property (nonatomic , strong) UIButton *openButton;
/** 关闭按钮 */
@property (nonatomic , strong) UIButton *closeButton;
/** 上部的ShapeLayer */
@property (nonatomic , strong) CAShapeLayer *topShapeLayer;
/** 下部的ShapeLayer */
@property (nonatomic , strong) CAShapeLayer *bottomShapeLayer;
/** 箭头 */
@property (nonatomic , strong) UIButton *arrowButton;
/** 标记是否展开状态 */
@property (nonatomic , assign) BOOL isUnfold;

@property (nonatomic , strong) UIImageView *imagView;

@end

@implementation ViewController
#pragma mark -- 懒加载
- (UIView *)topView{
    
    if (!_topView) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kPoinY + kArcHeight)];
        
        _topView.backgroundColor = [UIColor whiteColor];
        
        _topShapeLayer = [CAShapeLayer layer];
        
        _topShapeLayer.path = [self createTopViewBezierPath].CGPath;
        
        [_topView.layer addSublayer:_topShapeLayer];
        
        _topView.layer.mask = _topShapeLayer;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animationColseAction)];
        
        [_topView addGestureRecognizer:tap];
        
    }
    return _topView;
}

- (UIView *)bottomView{
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kPoinY, kScreenWidth,kPoinY)];
        
        _bottomView.backgroundColor = [UIColor greenColor];
        
        _bottomShapeLayer = [CAShapeLayer layer];
        
        _bottomShapeLayer.fillColor = [UIColor yellowColor].CGColor;
        
        _bottomShapeLayer.path = [self createBottomViewBezierPath].CGPath;
        
        [_bottomView.layer addSublayer:_bottomShapeLayer];
        
        _bottomView.layer.mask = _bottomShapeLayer;
    }
    return _bottomView;
}

- (UIButton *)arrowButton{
    
    if (!_arrowButton) {
        
        CGPoint center = self.view.center;
        
        center.y = self.topView.bottom - kPoinY / 2;
        
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _arrowButton.frame = CGRectMake(self.view.center.x, kScreenHeight - kPoinY, 50, 20);
        
        _arrowButton.center = center;
        
        _arrowButton.userInteractionEnabled = YES;
        
        [_arrowButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        
        [_arrowButton addTarget:self action:@selector(animationUnfoldAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _arrowButton;
}

#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
}

#pragma mark -- 创建UI
- (void)createUI{
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.topView];

    [self.view addSubview:self.bottomView];
    
    [self.view addSubview:self.arrowButton];
}

#pragma mark -- 点击动画
- (void)animationUnfoldAction{
    
    [self unflodAnimation];
}

- (void)animationColseAction{
    
    if (_isUnfold) {
        
        [self closeAnimation];
    }
}

#pragma mark -- 展开
- (void)unflodAnimation{
    
    _isUnfold = YES;
    
    CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    [circleAnim setDuration:0.5];
    circleAnim.delegate = self;
    circleAnim.removedOnCompletion = NO;
    circleAnim.fillMode = kCAFillModeForwards;
    
    [self.bottomShapeLayer addAnimation:circleAnim forKey:@"bottomShapeLayerAnimation"];
    self.bottomShapeLayer.path = [self bottomViewAnimation].CGPath;
    
    __weak typeof(self) kWeakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        
        kWeakSelf.arrowButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        
        kWeakSelf.topView.frame = CGRectMake(0, 0, kScreenWidth, 64);
        
        CGPoint center = kWeakSelf.view.center;
        
        center.y = kWeakSelf.topView.bottom - 20;
        
        kWeakSelf.arrowButton.center = center;
        
        kWeakSelf.bottomView.frame = CGRectMake(0, kScreenHeight - kPoinY + 20, kScreenWidth, kPoinY - 20);
        
    } completion:nil];
    
}

#pragma mark -- 关闭
- (void)closeAnimation{
    
    CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    [circleAnim setDuration:0.8];
    circleAnim.delegate = self;
    circleAnim.removedOnCompletion = NO;
    circleAnim.fillMode = kCAFillModeForwards;
    [self.bottomShapeLayer addAnimation:circleAnim forKey:@"bottomShapeLayerAnimation"];
    self.bottomShapeLayer.path = [self createBottomViewBezierPath].CGPath;
    
    __weak typeof(self) kWeakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        
        kWeakSelf.arrowButton.imageView.transform = CGAffineTransformIdentity;
        
        kWeakSelf.topView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kPoinY + kArcHeight);
        
        CGPoint center = kWeakSelf.view.center;
        
        center.y = kScreenHeight - kPoinY + 30;
        
        kWeakSelf.arrowButton.center = center;
        
        kWeakSelf.bottomView.frame = CGRectMake(0, kScreenHeight - kPoinY, kScreenWidth, kPoinY);
        
    } completion:^(BOOL finished) {
        
        kWeakSelf.isUnfold = NO;
    }];
}


#pragma mark -- 创建贝塞尔曲线
/** 上部的贝塞尔 */
- (UIBezierPath *)createTopViewBezierPath{
    
    UIBezierPath *topBezierPath = [UIBezierPath bezierPath];
    [topBezierPath removeAllPoints];
    
    topBezierPath.lineCapStyle = kCGLineCapRound; //线条拐角
    topBezierPath.lineJoinStyle = kCGLineCapRound; //终点处理
    //起始点 （上左下右）
    [topBezierPath moveToPoint:CGPointMake(0, 0)];
    //画线
    [topBezierPath addLineToPoint:CGPointMake(0, kScreenHeight - kPoinY)];
    [topBezierPath addLineToPoint:CGPointMake(kScreenWidth, kScreenHeight - kPoinY)];
    [topBezierPath addLineToPoint:CGPointMake(kScreenWidth, 0)];
    //画弧线
    //起始点
    [topBezierPath moveToPoint:CGPointMake(0, kScreenHeight - kPoinY)];
    //绘制二次贝塞尔曲线(endPoint:终止点 ， controlPoint：控制点)
    [topBezierPath addQuadCurveToPoint:CGPointMake(kScreenWidth, kScreenHeight - kPoinY) controlPoint:CGPointMake(kScreenWidth / 2, kScreenHeight - kPoinY + 100)];
    
    [topBezierPath closePath];
    
    return topBezierPath;
}

#pragma mark -- 上弧线收起
- (UIBezierPath *)topViewAnimation{
    
    UIBezierPath *topAnimationBP = [UIBezierPath bezierPath];
    [topAnimationBP removeAllPoints];
    
    //起始点 （上左下右）
    [topAnimationBP moveToPoint:CGPointMake(0, 0)];
    //画线
    [topAnimationBP addLineToPoint:CGPointMake(0, kScreenHeight - kPoinY)];
    [topAnimationBP addLineToPoint:CGPointMake(kScreenWidth, kScreenHeight - kPoinY)];
    [topAnimationBP addLineToPoint:CGPointMake(kScreenWidth, 0)];
    
    [topAnimationBP moveToPoint:CGPointMake(0, kScreenHeight - kPoinY)];
    
    [topAnimationBP addQuadCurveToPoint:CGPointMake(kScreenWidth, kScreenHeight - kPoinY) controlPoint:CGPointMake(kScreenWidth/2, kScreenHeight - kPoinY)];
    
    [topAnimationBP closePath];
    
    return topAnimationBP;
}

#pragma mark -- 上视图运动
- (UIBezierPath *)upperViewMotion{
    
    UIBezierPath *upperViewMotionBP = [UIBezierPath bezierPath];
    [upperViewMotionBP removeAllPoints];
    
    //起始点 （上左下右）
    [upperViewMotionBP moveToPoint:CGPointMake(0, 0)];
    //画线
    [upperViewMotionBP addLineToPoint:CGPointMake(0, 64)];
    [upperViewMotionBP addLineToPoint:CGPointMake(kScreenWidth, 64)];
    [upperViewMotionBP addLineToPoint:CGPointMake(kScreenWidth, 0)];
    
    [upperViewMotionBP moveToPoint:CGPointMake(0, 64)];
    
    [upperViewMotionBP addQuadCurveToPoint:CGPointMake(kScreenWidth, 64) controlPoint:CGPointMake(0, 64)];
    
    [upperViewMotionBP closePath];
    
    return upperViewMotionBP;
}


/** 下部的贝塞尔 */
- (UIBezierPath *)createBottomViewBezierPath{
    
    UIBezierPath *bottomBezierPath = [UIBezierPath bezierPath];
    
    bottomBezierPath.lineCapStyle = kCGLineCapRound; //线条拐角
    bottomBezierPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //起始点 （上左下右）
    [bottomBezierPath moveToPoint:CGPointMake(0, 0)];
    //画线
    [bottomBezierPath addLineToPoint:CGPointMake(0, kPoinY)];
    [bottomBezierPath addLineToPoint:CGPointMake(kScreenWidth, kPoinY)];
    [bottomBezierPath addLineToPoint:CGPointMake(kScreenWidth, 0)];
    
    //圆弧
    UIBezierPath *circularArc = [UIBezierPath bezierPath];
    circularArc.lineCapStyle = kCGLineCapRound; //线条拐角
    circularArc.lineJoinStyle = kCGLineCapRound; //终点处理
    [circularArc moveToPoint:CGPointMake(0, 0)];
    [circularArc addLineToPoint:CGPointMake(0, kScreenWidth)];
    //画弧线
    //起始点
    [circularArc moveToPoint:CGPointMake(0, 0)];
    //绘制二次贝塞尔曲线(endPoint:终止点 ， controlPoint：控制点)
    [circularArc addQuadCurveToPoint:CGPointMake(kScreenWidth, 0) controlPoint:CGPointMake(kScreenWidth / 2, kArcHeight)];
    [bottomBezierPath appendPath:[circularArc bezierPathByReversingPath]];
    
    [bottomBezierPath closePath];
    
    return bottomBezierPath;
}

- (UIBezierPath *)bottomViewAnimation{
    
    UIBezierPath *bottomAnimationBP = [UIBezierPath bezierPath];
    
    [bottomAnimationBP removeAllPoints];
    
    bottomAnimationBP.lineCapStyle = kCGLineCapRound; //线条拐角
    
    bottomAnimationBP.lineJoinStyle = kCGLineCapRound; //终点处理
    //起始点 （上左下右）
    [bottomAnimationBP moveToPoint:CGPointMake(0, kArcHeight / 2)];
    //画线
    [bottomAnimationBP addLineToPoint:CGPointMake(0, kPoinY)];
    [bottomAnimationBP addLineToPoint:CGPointMake(kScreenWidth, kPoinY)];
    [bottomAnimationBP addLineToPoint:CGPointMake(kScreenWidth, kArcHeight / 2)];
    
    //圆弧
    UIBezierPath *circularArc = [UIBezierPath bezierPath];
    [circularArc moveToPoint:CGPointMake(0, kArcHeight/2)];
    [circularArc addLineToPoint:CGPointMake(kScreenWidth, kArcHeight/2)];
    //画弧线
    //起始点
    [circularArc moveToPoint:CGPointMake(0, kArcHeight/2)];
    //绘制二次贝塞尔曲线(endPoint:终止点 ， controlPoint：控制点)
    [circularArc addQuadCurveToPoint:CGPointMake(kScreenWidth, kArcHeight/2) controlPoint:CGPointMake(kScreenWidth/2, kArcHeight/2)];
    [bottomAnimationBP appendPath:[circularArc bezierPathByReversingPath]];
    
    [bottomAnimationBP closePath];
    
    return bottomAnimationBP;
}

@end
