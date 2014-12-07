//
//  UICircularSlider.m
//  UICircularSlider
//
//  Created by Zouhair Mahieddine on 02/03/12.
//  Copyright (c) 2012 Zouhair Mahieddine.
//  http://www.zedenem.com
//  
//  This file is part of the UICircularSlider Library, released under the MIT License.
//

#import "UICurveSlider.h"

@interface UICurveSlider()

@property (nonatomic) CGPoint thumbCenterPoint;

#pragma mark - Init and Setup methods
- (void)setup;

#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point;

#pragma mark - Drawing methods

- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context;
- (CGPoint)drawCircularTrack:(CGFloat)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;

@end

#pragma mark -
@implementation UICurveSlider

@synthesize value = _value;
- (void)setValue:(CGFloat)value {
	if (value != _value) {
		if (value > self.maximumValue) { value = self.maximumValue; }
		if (value < self.minimumValue) { value = self.minimumValue; }
		_value = value;
		[self setNeedsDisplay];
        if (self.isContinuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
	}
}
@synthesize minimumValue = _minimumValue;
- (void)setMinimumValue:(CGFloat)minimumValue {
	if (minimumValue != _minimumValue) {
		_minimumValue = minimumValue;
		if (self.maximumValue < self.minimumValue)	{ self.maximumValue = self.minimumValue; }
		if (self.value < self.minimumValue)			{ self.value = self.minimumValue; }
	}
}
@synthesize maximumValue = _maximumValue;
- (void)setMaximumValue:(CGFloat)maximumValue {
	if (maximumValue != _maximumValue) {
		_maximumValue = maximumValue;
		if (self.minimumValue > self.maximumValue)	{ self.minimumValue = self.maximumValue; }
		if (self.value > self.maximumValue)			{ self.value = self.maximumValue; }
	}
}

@synthesize minimumTrackTintColor = _minimumTrackTintColor;
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
	if (![minimumTrackTintColor isEqual:_minimumTrackTintColor]) {
		_minimumTrackTintColor = minimumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize maximumTrackTintColor = _maximumTrackTintColor;
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
	if (![maximumTrackTintColor isEqual:_maximumTrackTintColor]) {
		_maximumTrackTintColor = maximumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize thumbTintColor = _thumbTintColor;
- (void)setThumbTintColor:(UIColor *)thumbTintColor {
	if (![thumbTintColor isEqual:_thumbTintColor]) {
		_thumbTintColor = thumbTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize continuous = _continuous;

@synthesize thumbCenterPoint = _thumbCenterPoint;

/** @name Init and Setup methods */
#pragma mark - Init and Setup methods
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    } 
    return self;
}
- (void)awakeFromNib {
	[self setup];
}

- (void)setup {
	self.value = 0.0;
	self.minimumValue = 0.0;
	self.maximumValue = 1.0;
	self.minimumTrackTintColor = [UIColor blueColor];
	self.maximumTrackTintColor = [UIColor whiteColor];
	self.thumbTintColor = [UIColor darkGrayColor];
	self.continuous = YES;
	self.thumbCenterPoint = CGPointZero;
    self.clockwise = YES;
    self.lineWidth = 6.0f;
    self.thumbRadius = 12.0f;
	
    /**
     * This tapGesture isn't used yet but will allow to jump to a specific location in the circle
     */
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
	[self addGestureRecognizer:tapGestureRecognizer];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHappened:)];
	panGestureRecognizer.maximumNumberOfTouches = panGestureRecognizer.minimumNumberOfTouches;
	[self addGestureRecognizer:panGestureRecognizer];
}

/** @name Drawing methods */
#pragma mark - Drawing methods

- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y);
	CGContextAddArc(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y, self.thumbRadius, 0.0, 2*M_PI, NO);
	
	CGContextFillPath(context);
	UIGraphicsPopContext();
}

- (CGPoint)drawCircularTrack:(CGFloat)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
    CGContextSetLineCap(context, kCGLineCapRound);
	CGFloat endAngle = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, self.startAngel, self.endAngel);
	CGContextAddArc(context, center.x, center.y, radius, self.startAngel, endAngle, !self.clockwise);
    
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextStrokePath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint middlePoint = self.arcCenter;
    
	CGContextSetLineWidth(context, self.lineWidth);
	
    [self.maximumTrackTintColor setStroke];
    [self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:self.radius inContext:context];
    [self.minimumTrackTintColor setStroke];
    self.thumbCenterPoint = [self drawCircularTrack:self.value atPoint:middlePoint withRadius:self.radius inContext:context];
	
	[self.thumbTintColor setFill];
	[self drawThumbAtPoint:self.thumbCenterPoint inContext:context];
}

/** @name Thumb management methods */
#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point {
	CGRect thumbTouchRect = CGRectMake(self.thumbCenterPoint.x - self.thumbRadius, self.thumbCenterPoint.y - self.thumbRadius, self.thumbRadius*2, self.thumbRadius*2);
	return CGRectContainsPoint(thumbTouchRect, point);
}

/** @name UIGestureRecognizer management methods */
#pragma mark - UIGestureRecognizer management methods
- (void)panGestureHappened:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint tapLocation = [panGestureRecognizer locationInView:self];
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateChanged: {
            CGPoint sliderCenter = self.arcCenter;
            CGPoint sliderStartPoint = pointWithCenterRadiusAngle(sliderCenter, self.radius, self.startAngel);
			CGFloat angle = angleBetweenThreePoints(sliderCenter, sliderStartPoint, tapLocation);
            if (angle < 0) {
                angle = -angle;
            }
            angle += self.startAngel;
            while (angle > M_PI*2) {
                angle -= M_PI*2;
            }
            
			self.value = translateValueFromSourceIntervalToDestinationInterval(angle, self.startAngel, self.endAngel, self.minimumValue, self.maximumValue);
			break;
		}
        case UIGestureRecognizerStateEnded:
            if (!self.isContinuous) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            if ([self isPointInThumb:tapLocation]) {
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
            }
            break;
		default:
			break;
	}
}
- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer {
	if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
		if ([self isPointInThumb:tapLocation]) {
		}
		else {
		}
	}
}

/** @name Touches Methods */
#pragma mark - Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if ([self isPointInThumb:touchLocation]) {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
}

@end

/** @name Utility Functions */
#pragma mark - Utility Functions

CGFloat translateValueFromSourceIntervalToDestinationInterval(CGFloat sourceValue, CGFloat sourceIntervalMinimum, CGFloat sourceIntervalMaximum, CGFloat destinationIntervalMinimum, CGFloat destinationIntervalMaximum) {
    if (sourceValue == sourceIntervalMinimum)
        return destinationIntervalMinimum;
    if (sourceValue == sourceIntervalMaximum)
        return destinationIntervalMaximum;
    
	CGFloat a, b, destinationValue;
	
	a = (destinationIntervalMaximum - destinationIntervalMinimum) / (sourceIntervalMaximum - sourceIntervalMinimum);
	b = destinationIntervalMaximum - a*sourceIntervalMaximum;
	
	destinationValue = a*sourceValue + b;
    
	return destinationValue;
}

CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
	CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}

CGPoint pointWithCenterRadiusAngle(CGPoint center, CGFloat radius, CGFloat angle) {
    CGFloat targetX = center.x + radius * cos(angle);
    CGFloat targetY = center.y + radius * sin(angle);
    CGPoint position = CGPointMake(targetX, targetY);
    return position;
}
