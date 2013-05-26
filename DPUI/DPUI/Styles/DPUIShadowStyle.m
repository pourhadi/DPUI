//
//  DPStyleShadow.m
//  TheQ
//
//  Created by Dan Pourhadi on 4/27/13.
//
//

#import "DPUIShadowStyle.h"
#import "DPUIDefines.h"
#import "DPUI.h"
@implementation DPUIShadowStyle

- (id)init {
    self = [super init];
    if (self) {
        self.offset = CGSizeMake(0, 1);
        self.radius = 0;
        self.color = [UIColor blackColor];
        self.opacity = 1;
    }
    return self;
}

- (void)addShadowToView:(UIView *)view {
    view.layer.shadowColor = self.color.CGColor;
    view.layer.shadowRadius = self.radius;
    view.layer.shadowOpacity = self.opacity;
    view.layer.shadowOffset = self.offset;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        CGFloat xOffset = [[dictionary objectForKey:kDPUIXOffsetKey] floatValue];
        CGFloat yOffset = [[dictionary objectForKey:kDPUIYOffsetKey] floatValue];
        
        self.offset = CGSizeMake(xOffset, yOffset);
        self.radius = [[dictionary objectForKey:kDPUIRadiusKey] floatValue];
        self.opacity = [[dictionary objectForKey:kDPUIOpacityKey] floatValue];
        CIColor *ciColor = [CIColor colorWithString:[dictionary objectForKey:kDPUIColorKey]];
        self.color = [UIColor colorWithRed:ciColor.red green:ciColor.green blue:ciColor.blue alpha:ciColor.alpha];
		//self.color = [UIColor colorWithCIColor:ciColor];
    }
    return self;
}

@end