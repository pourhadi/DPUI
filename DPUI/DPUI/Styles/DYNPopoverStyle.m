//
//  DYNPopoverStyle.m
//  DynUI-Example
//
//  Created by Daniel Pourhadi on 5/16/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//
#import "DYNPopoverStyle.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "DynUI.h"
#import "DYNDefines.h"
#define CONTENT_INSET 10.0
#define CAP_INSET 25.0
#define ARROW_BASE 38
#define ARROW_HEIGHT 20.0

@interface DYNPopoverStyle ()
{
	UIImageView *_borderImageView;
	CGFloat _arrowOffset;
	UIPopoverArrowDirection _arrowDirection;
}
@property (nonatomic, strong) UIBezierPath *containerPath;

@end

@implementation DYNPopoverStyle

+ (void)setCurrentStyle:(DYNViewStyle *)style
{
    objc_setAssociatedObject(self, kDYNCurrentPopoverStyleKey, style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (DYNViewStyle*)currentStyle
{
    return objc_getAssociatedObject(self, kDYNCurrentPopoverStyleKey);
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
		_borderImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		
		self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_borderImageView];
//		
//		self.layer.shadowColor = [[UIColor blackColor] CGColor];
//		self.layer.shadowRadius = 8;
//		self.layer.shadowOffset = CGSizeMake(0, 2);
//		self.layer.shadowOpacity = 1;
//		self.layer.shouldRasterize = YES;
//		self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		
    }
    return self;
}
+ (BOOL)wantsDefaultContentAppearance
{
	return NO;
}

- (CGFloat) arrowOffset {
    return _arrowOffset;
}

- (void) setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
}


+(UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

+(CGFloat)arrowHeight{
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase{
    return ARROW_BASE;
}


-  (void)layoutSubviews {
    [super layoutSubviews];
	
    CGFloat _height = self.frame.size.height;
    CGFloat _width = self.frame.size.width;
    CGFloat _left = 0.0;
    CGFloat _top = 0.0;
    CGFloat _coordinate = 0.0;
    CGAffineTransform _rotation = CGAffineTransformIdentity;
	
	CGFloat offset = 0;
	
	CGRect arrowRect;
	
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _top += ARROW_HEIGHT;
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            arrowRect = CGRectMake(_coordinate, 0+offset, ARROW_BASE, ARROW_HEIGHT);
            break;
        case UIPopoverArrowDirectionDown:
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            arrowRect = CGRectMake(_coordinate, _height-offset, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI );
            break;
			
        case UIPopoverArrowDirectionLeft:
            _left += ARROW_HEIGHT;
            _width -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (ARROW_BASE/2);
            arrowRect = CGRectMake(offset, _coordinate, ARROW_HEIGHT, ARROW_BASE);
            _rotation = CGAffineTransformMakeRotation( -M_PI_2 );
            break;
			
        case UIPopoverArrowDirectionRight:
            _width -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset)- (ARROW_BASE/2);
            arrowRect = CGRectMake(_width-offset, _coordinate, ARROW_HEIGHT, ARROW_BASE);
            _rotation = CGAffineTransformMakeRotation( M_PI_2 );
            break;
		default:
			break;
    }
	
    _borderImageView.frame =  self.bounds;
	
	_borderImageView.image = [self getBgImageOfSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height) withArrowRect:arrowRect andBgRect:CGRectMake(_left+1, _top+1, _width-2, _height-2)];
    
//	self.layer.shadowColor = [[UIColor blackColor] CGColor];
//	self.layer.shadowRadius = 15;
//	self.layer.shadowOffset = CGSizeMake(0, 10);
//	self.layer.shadowOpacity = 0.75;
//	self.layer.shouldRasterize = YES;
//	self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
//	self.layer.shadowPath = self.containerPath.CGPath;
    
    
    
    [[[DYNPopoverStyle currentStyle] shadow] addShadowToView:self withPath:self.containerPath];

}

-(UIImage*)getBgImageOfSize:(CGSize)size withArrowRect:(CGRect)arrowRect andBgRect:(CGRect)bgRect
{
	
	UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);

	UIBezierPath *path = [UIBezierPath bezierPath];
	CGSize radius = [[DYNPopoverStyle currentStyle] cornerRadii];
	CGFloat curve = radius.width;
    CGFloat controlOff = curve*0.55;
	[path moveToPoint:CGPointMake(bgRect.origin.x, bgRect.origin.y+curve)];
	[path addCurveToPoint:CGPointMake(bgRect.origin.x+curve, bgRect.origin.y) controlPoint1:CGPointMake(bgRect.origin.x, bgRect.origin.y+controlOff) controlPoint2:CGPointMake(bgRect.origin.x+controlOff, bgRect.origin.y)];
	/* top */
	
	if (self.arrowDirection == UIPopoverArrowDirectionUp)
	{
		[path addLineToPoint:CGPointMake(arrowRect.origin.x, bgRect.origin.y)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x + (arrowRect.size.width/2), 1)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x+arrowRect.size.width, bgRect.origin.y)];
	}
	
	[path addLineToPoint:CGPointMake((bgRect.origin.x+bgRect.size.width)-curve, bgRect.origin.y)];
	[path addCurveToPoint:CGPointMake(bgRect.origin.x+bgRect.size.width, bgRect.origin.y+curve) controlPoint1:CGPointMake((bgRect.origin.x+bgRect.size.width)-controlOff, bgRect.origin.y) controlPoint2:CGPointMake(bgRect.origin.x+bgRect.size.width, bgRect.origin.y+controlOff)];
	/* right */
	
	if (self.arrowDirection == UIPopoverArrowDirectionRight)
	{
		[path addLineToPoint:CGPointMake(bgRect.origin.x+bgRect.size.width, arrowRect.origin.y)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x+arrowRect.size.width, arrowRect.origin.y + (arrowRect.size.height/2))];
		[path addLineToPoint:CGPointMake(bgRect.origin.x+bgRect.size.width, arrowRect.origin.y+arrowRect.size.height)];
	}
	
	[path addLineToPoint:CGPointMake(bgRect.origin.x+bgRect.size.width, (bgRect.origin.y+bgRect.size.height)-curve)];
	[path addCurveToPoint:CGPointMake((bgRect.origin.x+bgRect.size.width)-curve, bgRect.origin.y+bgRect.size.height) controlPoint1:CGPointMake(bgRect.origin.x+bgRect.size.width, (bgRect.origin.y+bgRect.size.height)-controlOff) controlPoint2:CGPointMake((bgRect.origin.x+bgRect.size.width)-controlOff, bgRect.origin.y+bgRect.size.height)];
	/* bottom */
	
	if (self.arrowDirection == UIPopoverArrowDirectionDown)
	{
		[path addLineToPoint:CGPointMake(arrowRect.origin.x+arrowRect.size.width, bgRect.origin.y+bgRect.size.height)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x+(arrowRect.size.width/2), arrowRect.origin.y+arrowRect.size.height)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x, bgRect.origin.y+bgRect.size.height)];
	}
	
	[path addLineToPoint:CGPointMake(bgRect.origin.x+curve, bgRect.origin.y+bgRect.size.height)];
	[path addCurveToPoint:CGPointMake(bgRect.origin.x, (bgRect.origin.y+bgRect.size.height)-curve) controlPoint1:CGPointMake(bgRect.origin.x+controlOff, bgRect.origin.y+bgRect.size.height) controlPoint2:CGPointMake(bgRect.origin.x, (bgRect.origin.y+bgRect.size.height)-controlOff)];
	/* left */
	
	if (self.arrowDirection == UIPopoverArrowDirectionLeft)
	{
		[path addLineToPoint:CGPointMake(bgRect.origin.x, arrowRect.origin.y+arrowRect.size.height)];
		[path addLineToPoint:CGPointMake(arrowRect.origin.x, arrowRect.origin.y + (arrowRect.size.height/2))];
		[path addLineToPoint:CGPointMake(bgRect.origin.x, arrowRect.origin.y)];
	}
    
	
	[path closePath];
    
    if ([DYNPopoverStyle currentStyle]) {
        UIImage *bgImage = [[DYNPopoverStyle currentStyle] imageForStyleWithSize:path.bounds.size path:path withOuterShadow:NO parameters:nil];
        [bgImage drawAtPoint:CGPointZero];
    }
    
	
	self.containerPath = path;

	self.layer.shadowPath = [self.containerPath CGPath];
	
    
    
	return UIGraphicsGetImageFromCurrentImageContext();
}

@end