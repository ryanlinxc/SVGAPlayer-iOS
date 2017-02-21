//
//  SVGAVectorLayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAVectorLayer.h"
#import "SVGABezierPath.h"

@interface SVGAVectorLayer ()

@property (nonatomic, strong) NSArray *spec;

@end

@implementation SVGAVectorLayer

- (instancetype)initWithSpec:(NSArray *)spec previous:(SVGAVectorLayer *)previous
{
    self = [super init];
    if (self) {
        _spec = spec;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.masksToBounds = NO;
        [self createSublayers:previous];
    }
    return self;
}

- (void)createSublayers:(SVGAVectorLayer *)previous {
    for (NSDictionary *shape in self.spec) {
        if ([shape isKindOfClass:[NSDictionary class]]) {
            if ([shape[@"type"] isKindOfClass:[NSString class]]) {
                if ([shape[@"type"] isEqualToString:@"shape"]) {
                    [self addSublayer:[self createCurveLayer:shape]];
                }
                else if ([shape[@"type"] isEqualToString:@"ellipse"]) {
                    [self addSublayer:[self createEllipseLayer:shape]];
                }
                else if ([shape[@"type"] isEqualToString:@"rect"]) {
                    [self addSublayer:[self createRectLayer:shape]];
                }
                else if ([shape[@"type"] isEqualToString:@"keep"] && previous != nil) {
                    for (CALayer *item in previous.sublayers) {
                        [self addSublayer:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:item]]];
                    }
                }
            }
        }
    }
}

- (CALayer *)createCurveLayer:(NSDictionary *)shape {
    SVGABezierPath *bezierPath = [SVGABezierPath new];
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"d"] isKindOfClass:[NSString class]]) {
            [bezierPath setValues:shape[@"args"][@"d"]];
        }
    }
    CAShapeLayer *shapeLayer = [bezierPath createLayer];
    [self resetStyles:shapeLayer shape:shape];
    [self resetTransform:shapeLayer shape:shape];
    return shapeLayer;
}

- (CALayer *)createEllipseLayer:(NSDictionary *)shape {
    UIBezierPath *bezierPath;
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"x"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"y"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"radiusX"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"radiusY"] isKindOfClass:[NSNumber class]]) {
            CGFloat x = [shape[@"args"][@"x"] floatValue];
            CGFloat y = [shape[@"args"][@"y"] floatValue];
            CGFloat rx = [shape[@"args"][@"radiusX"] floatValue];
            CGFloat ry = [shape[@"args"][@"radiusY"] floatValue];
            bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x - rx, y - ry, rx * 2, ry * 2)];
        }
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer shape:shape];
        [self resetTransform:shapeLayer shape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (CALayer *)createRectLayer:(NSDictionary *)shape {
    UIBezierPath *bezierPath;
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"x"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"y"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"width"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"height"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"cornerRadius"] isKindOfClass:[NSNumber class]]) {
            CGFloat x = [shape[@"args"][@"x"] floatValue];
            CGFloat y = [shape[@"args"][@"y"] floatValue];
            CGFloat width = [shape[@"args"][@"width"] floatValue];
            CGFloat height = [shape[@"args"][@"height"] floatValue];
            CGFloat cornerRadius = [shape[@"args"][@"cornerRadius"] floatValue];
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, width, height) cornerRadius:cornerRadius];
        }
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer shape:shape];
        [self resetTransform:shapeLayer shape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (void)resetStyles:(CAShapeLayer *)shapeLayer shape:(NSDictionary *)shape {
    shapeLayer.masksToBounds = NO;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    if ([shape[@"styles"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"styles"][@"fill"] isKindOfClass:[NSArray class]]) {
            NSArray *colorArray = shape[@"styles"][@"fill"];
            if ([colorArray count] == 4 &&
                [colorArray[0] isKindOfClass:[NSNumber class]] &&
                [colorArray[1] isKindOfClass:[NSNumber class]] &&
                [colorArray[2] isKindOfClass:[NSNumber class]] &&
                [colorArray[3] isKindOfClass:[NSNumber class]]) {
                shapeLayer.fillColor = [UIColor colorWithRed:[colorArray[0] floatValue]
                                                       green:[colorArray[1] floatValue]
                                                        blue:[colorArray[2] floatValue]
                                                       alpha:[colorArray[3] floatValue]].CGColor;
            }
        }
        else {
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
        }
        if ([shape[@"styles"][@"stroke"] isKindOfClass:[NSArray class]]) {
            NSArray *colorArray = shape[@"styles"][@"stroke"];
            if ([colorArray count] == 4 &&
                [colorArray[0] isKindOfClass:[NSNumber class]] &&
                [colorArray[1] isKindOfClass:[NSNumber class]] &&
                [colorArray[2] isKindOfClass:[NSNumber class]] &&
                [colorArray[3] isKindOfClass:[NSNumber class]]) {
                shapeLayer.strokeColor = [UIColor colorWithRed:[colorArray[0] floatValue]
                                                         green:[colorArray[1] floatValue]
                                                          blue:[colorArray[2] floatValue]
                                                         alpha:[colorArray[3] floatValue]].CGColor;
            }
        }
        if ([shape[@"styles"][@"strokeWidth"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.lineWidth = [shape[@"styles"][@"strokeWidth"] floatValue];
        }
        if ([shape[@"styles"][@"lineCap"] isKindOfClass:[NSString class]]) {
            shapeLayer.lineCap = shape[@"styles"][@"lineCap"];
        }
        if ([shape[@"styles"][@"lineJoin"] isKindOfClass:[NSString class]]) {
            shapeLayer.lineJoin = shape[@"styles"][@"lineJoin"];
        }
        if ([shape[@"styles"][@"lineDash"] isKindOfClass:[NSArray class]]) {
            BOOL accept = YES;
            for (id obj in shape[@"styles"][@"lineDash"]) {
                if (![obj isKindOfClass:[NSNumber class]]) {
                    accept = NO;
                }
            }
            if (accept) {
                shapeLayer.lineDashPattern = shape[@"styles"][@"lineDash"];
            }
        }
        if ([shape[@"styles"][@"miterLimit"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.miterLimit = [shape[@"styles"][@"miterLimit"] floatValue];
        }
    }
}

- (void)resetTransform:(CAShapeLayer *)shapeLayer shape:(NSDictionary *)shape {
    if ([shape[@"transform"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"transform"][@"a"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"b"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"c"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"d"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"tx"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"ty"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake([shape[@"transform"][@"a"] floatValue],
                                                                                          [shape[@"transform"][@"b"] floatValue],
                                                                                          [shape[@"transform"][@"c"] floatValue],
                                                                                          [shape[@"transform"][@"d"] floatValue],
                                                                                          [shape[@"transform"][@"tx"] floatValue],
                                                                                          [shape[@"transform"][@"ty"] floatValue])
                                                                    );
        }
    }
}

@end
