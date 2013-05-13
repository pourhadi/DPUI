//
//  DPStyleRenderer.m
//  TheQ
//
//  Created by Daniel Pourhadi on 4/29/13.
//
//

#import "DYNRenderer.h"
#import "DYNDefines.h"
#import "DynUI.h"
#import <objc/runtime.h>
@implementation DYNRenderer

+ (NSOperationQueue *)drawQueue {
    NSOperationQueue *queue = objc_getAssociatedObject(self, kDYNDrawQueueKey);
    if (!queue) {
        queue = [[NSOperationQueue alloc] init];
        objc_setAssociatedObject(self, kDYNDrawQueueKey, queue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return queue;
}

+ (void)renderView:(UIView *)view withStyleNamed:(NSString *)styleName {
	
    if ([view isKindOfClass:[UIButton class]]) {
        [self renderButton:(UIButton *)view withStyleNamed:styleName];
        return;
    } else if ([view isKindOfClass:[UINavigationBar class]]) {
        [self renderNavigationBar:(UINavigationBar *)view withStyleNamed:styleName];
        return;
    } else if ([view isKindOfClass:[UITableViewCell class]]) {
        [self renderTableCell:(UITableViewCell *)view withStyleNamed:styleName];
        return;
    } else if ([view isKindOfClass:[UIToolbar class]]) {
		[self renderToolbar:(UIToolbar*)view withStyleNamed:styleName];
		return;
	} else if ([view isKindOfClass:[UISearchBar class]]) {
		[self renderSearchBar:(UISearchBar*)view withStyleNamed:styleName];
		return;
	} else if ([view isKindOfClass:[UISlider class]]) {
		[self renderSlider:(UISlider*)view withSliderStyleNamed:styleName];
		return;
	}
	
    DYNViewStyle *style = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
	
    [style applyStyleToView:view];
}

+ (void)renderSlider:(UISlider*)slider withSliderStyleNamed:(NSString*)name
{
	DYNSliderStyle *style = [[DYNManager sharedInstance] sliderStyleForName:name];
	
	UIImage *min = [style minTrackImageForSlider:slider];
	UIImage *max = [style maxTrackImageForSlider:slider];
	UIImage *thumb = [style thumbImageForSlider:slider];
	
	[slider setMinimumTrackImage:min forState:UIControlStateNormal];
	[slider setMaximumTrackImage:max forState:UIControlStateNormal];
	[slider setThumbImage:thumb forState:UIControlStateNormal];
}

+ (void)renderSearchBar:(UISearchBar*)searchBar withStyleNamed:(NSString*)styleName
{
	DYNViewStyle *style = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
	
	UIImage *bgImage = [style imageForStyleWithSize:searchBar.frame.size withOuterShadow:NO flippedGradient:NO parameters:searchBar.styleParameters];
	
	[searchBar setBackgroundImage:bgImage];
	
	if (style.shadow) {
		[style.shadow addShadowToView:searchBar];
	}
	
	// text field
	NSString *searchFieldStyleName = style.searchFieldStyleName;
	DYNViewStyle *fieldStyle;
	if (searchFieldStyleName) {
		[searchBar setSearchFieldBackgroundImage:nil forState:UIControlStateNormal];
		[searchBar setNeedsLayout];
		BOOL flipGrad = NO;
		BOOL halfAlpha = NO;
		BOOL makeLighter = NO;
		BOOL makeDarker = NO;
		
			if ([searchFieldStyleName isEqualToString:kDYNFlippedGradientKey]) {
				flipGrad = YES;
				fieldStyle = style;
			} else if ([searchFieldStyleName isEqualToString:kDYNMakeDarkerKey]) {
				flipGrad = NO;
				halfAlpha = NO;
				makeLighter = NO;
				makeDarker = YES;
				fieldStyle = style;
			} else if ([searchFieldStyleName isEqualToString:kDYNMakeLigherKey]) {
				flipGrad = NO;
				halfAlpha = NO;
				makeLighter = YES;
				makeDarker = NO;
				fieldStyle = style;
			} else {
				if ([searchFieldStyleName isEqualToString:kDYNHalfOpacityKey]) {
					fieldStyle = style;
					halfAlpha = YES;
				} else {
					fieldStyle = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:searchFieldStyleName];
				}
			}
		
		UITextField *textField;
		
		CGFloat textFieldHeight = searchBar.frame.size.height - 13;
		for (UIView *sub in searchBar.subviews){
			if ([sub isKindOfClass:[UITextField class]]) {
				textField = (UITextField*)sub;
			}
		}
		
		if (style.searchFieldTextStyleName) {
			DYNTextStyle *textStyle = [[DYNManager sharedInstance] textStyleForName:style.searchFieldTextStyleName];
			textField.textColor = textStyle.textColor.color;
			textField.textAlignment = textStyle.alignment;
			textField.font = textStyle.font;
		}
		
		//textFieldHeight = MAX(textFieldHeight, 2);
		UIImage *searchFieldImage = [fieldStyle imageForStyleWithSize:CGSizeMake(textFieldHeight, textFieldHeight) withOuterShadow:YES flippedGradient:flipGrad parameters:searchBar.styleParameters];
		if (halfAlpha) {
			searchFieldImage = [searchFieldImage imageWithOpacity:0.5];
		}
		if (makeDarker) {
			searchFieldImage = [searchFieldImage imageOverlayedWithColor:[UIColor blackColor] opacity:0.3];
		}
		if (makeLighter) {
			searchFieldImage = [searchFieldImage imageOverlayedWithColor:[UIColor whiteColor] opacity:0.3];
		}
		[searchBar setSearchFieldBackgroundImage:searchFieldImage.dyn_resizableImage forState:UIControlStateNormal];
	}
}

+ (void)renderToolbar:(UIToolbar*)toolbar withStyleNamed:(NSString*)styleName
{
	DYNViewStyle *style = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];

	UIImage *img = [style imageForStyleWithSize:toolbar.frame.size parameters:toolbar.styleParameters];
	
	[toolbar setBackgroundImage:img forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

+ (void)renderNavigationBar:(UINavigationBar *)navigationBar withStyleNamed:(NSString *)styleName {
    DYNViewStyle *navStyle = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
	
    UIImage *img = [navStyle imageForStyleWithSize:navigationBar.frame.size parameters:navigationBar.styleParameters];
    [navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
	
    if (navStyle.navBarTitleTextStyle) {
        [navigationBar setTitleTextAttributes:navStyle.navBarTitleTextStyle.titleTextAttributes];
    }
	
	if (navStyle.shadow) {
		CIColor *color = [CIColor colorWithCGColor:navStyle.shadow.color.CGColor];
		if (!(CGSizeEqualToSize(navStyle.shadow.offset, CGSizeZero) && navStyle.shadow.radius == 0) && color.alpha != 0 && navStyle.shadow.opacity != 0) {
			UIImage *shadowImage = [navStyle.shadow getImageForWidth:navigationBar.frame.size.width];
			[navigationBar setShadowImage:shadowImage];
		} else {
			[navigationBar setShadowImage:[UIImage blankOnePointImage].dyn_resizableImage];
		}
	}
	
	
    if (navStyle.barButtonItemStyleName) {
        DYNViewStyle *style = [[DYNManager sharedInstance] styleForName:navStyle.barButtonItemStyleName];
        UIImage *buttonImg = [style imageForStyleWithSize:CGSizeMake(18, 28) withOuterShadow:YES parameters:navigationBar.styleParameters];
        [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackgroundImage:buttonImg.dyn_resizableImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        UIImage *backImg = [DYNRenderer backBarButtonImageForStyle:navStyle.barButtonItemStyleName superStyle:nil parameters:navigationBar.styleParameters];
        [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackButtonBackgroundImage:backImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		
		
        if (style.controlStyle) {
            NSDictionary *textAttr;
			
            if (style.controlStyle.normalTextStyle) {
                textAttr = [style.controlStyle.normalTextStyle titleTextAttributes];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setTitleTextAttributes:textAttr forState:UIControlStateNormal];
            }
			
            if (style.controlStyle.highlightedTextStyle) {
                textAttr = [style.controlStyle.highlightedTextStyle titleTextAttributes];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setTitleTextAttributes:textAttr forState:UIControlStateHighlighted];
            }
			
            if (style.controlStyle.selectedTextStyle) {
                textAttr = [style.controlStyle.selectedTextStyle titleTextAttributes];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setTitleTextAttributes:textAttr forState:UIControlStateSelected];
            }
			
            if (style.controlStyle.disabledTextStyle) {
                textAttr = [style.controlStyle.disabledTextStyle titleTextAttributes];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
            }
			
            if (style.controlStyle.highlightedStyleName) {
                UIImage *buttonImg = [self imageForSize:CGSizeMake(18, 28) controlStyleName:style.controlStyle.highlightedStyleName superStyle:style parameters:navigationBar.styleParameters];
				
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackgroundImage:buttonImg.dyn_resizableImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
                UIImage *backImg = [DYNRenderer backBarButtonImageForStyle:style.controlStyle.highlightedStyleName superStyle:style parameters:navigationBar.styleParameters];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackButtonBackgroundImage:backImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            }
			
            if (style.controlStyle.selectedStyleName) {
                UIImage *buttonImg = [self imageForSize:CGSizeMake(18, 28) controlStyleName:style.controlStyle.selectedStyleName superStyle:style parameters:navigationBar.styleParameters];
				
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackgroundImage:buttonImg.dyn_resizableImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
                UIImage *backImg = [DYNRenderer backBarButtonImageForStyle:style.controlStyle.selectedStyleName superStyle:style parameters:navigationBar.styleParameters];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackButtonBackgroundImage:backImg forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
            }
			
            if (style.controlStyle.disabledStyleName) {
                UIImage *buttonImg = [self imageForSize:CGSizeMake(18, 28) controlStyleName:style.controlStyle.disabledStyleName superStyle:style parameters:navigationBar.styleParameters];
				
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackgroundImage:buttonImg.dyn_resizableImage forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
                UIImage *backImg = [DYNRenderer backBarButtonImageForStyle:style.controlStyle.disabledStyleName superStyle:style parameters:navigationBar.styleParameters];
                [[UIBarButtonItem appearanceWhenContainedIn:[navigationBar class], nil] setBackButtonBackgroundImage:backImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
            }
        }
    }
}

+ (void)renderButton:(UIButton *)button withStyleNamed:(NSString *)styleName {
    DYNViewStyle *style = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
	
    if (style.drawAsynchronously) {
        __weak __typeof(& *self) weakSelf = self;
        [[self drawQueue] addOperationWithBlock:^{
            UIImage *image = [style imageForStyleWithSize:button.frame.size withOuterShadow:YES parameters:button.styleParameters];
			
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf applyImage:image fromStyle:style toButton:button];
            }];
        }];
    } else {
        UIImage *image = [style imageForStyleWithSize:button.frame.size withOuterShadow:YES parameters:button.styleParameters];
        [self applyImage:image fromStyle:style toButton:button];
    }
}

+ (void)applyImage:(UIImage *)image fromStyle:(DYNViewStyle *)style toButton:(UIButton *)button {
    [button setBackgroundImage:image forState:UIControlStateNormal];
	
    if (style.controlStyle.normalTextStyle) {
        [style.controlStyle.normalTextStyle applyToButton:button forState:UIControlStateNormal];
    }
    if (style.controlStyle.highlightedTextStyle) {
        [style.controlStyle.highlightedTextStyle applyToButton:button forState:UIControlStateHighlighted];
    }
    if (style.controlStyle.selectedTextStyle) {
        [style.controlStyle.selectedTextStyle applyToButton:button forState:UIControlStateSelected];
    }
    if (style.controlStyle.disabledTextStyle) {
        [style.controlStyle.disabledTextStyle applyToButton:button forState:UIControlStateDisabled];
    }
	
    if (style.controlStyle.highlightedStyleName) {
        UIImage *image = [self imageForSize:button.frame.size controlStyleName:style.controlStyle.highlightedStyleName superStyle:style parameters:button.styleParameters];
        [button setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    if (style.controlStyle.selectedStyleName) {
        UIImage *image = [self imageForSize:button.frame.size controlStyleName:style.controlStyle.selectedStyleName superStyle:style parameters:button.styleParameters];
		
        [button setBackgroundImage:image forState:UIControlStateSelected];
    }
    if (style.controlStyle.disabledStyleName) {
        UIImage *image = [self imageForSize:button.frame.size controlStyleName:style.controlStyle.disabledStyleName superStyle:style parameters:button.styleParameters];
        [button setBackgroundImage:image forState:UIControlStateDisabled];
    }
}

+ (UIImage *)imageForSize:(CGSize)size controlStyleName:(NSString *)controlStyleName superStyle:(DYNViewStyle *)style parameters:(DYNStyleParameters *)parameters {
    DYNViewStyle *buttonStyle;
    BOOL flipGrad = NO;
    BOOL halfAlpha = NO;
    BOOL makeLighter = NO;
    BOOL makeDarker = NO;
    if ([controlStyleName isEqualToString:kDYNFlippedGradientKey]) {
        flipGrad = YES;
        buttonStyle = style;
    } else if ([controlStyleName isEqualToString:kDYNMakeDarkerKey]) {
        flipGrad = NO;
        halfAlpha = NO;
        makeLighter = NO;
        makeDarker = YES;
        buttonStyle = style;
    } else if ([controlStyleName isEqualToString:kDYNMakeLigherKey]) {
        flipGrad = NO;
        halfAlpha = NO;
        makeLighter = YES;
        makeDarker = NO;
        buttonStyle = style;
    } else {
        if ([controlStyleName isEqualToString:kDYNHalfOpacityKey]) {
            buttonStyle = style;
            halfAlpha = YES;
        } else {
            buttonStyle = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:controlStyleName];
        }
    }
    UIImage *image = [buttonStyle imageForStyleWithSize:size withOuterShadow:YES flippedGradient:flipGrad parameters:parameters];
	
    if (halfAlpha) {
        image = [image imageWithOpacity:0.5];
    }
	
    if (makeDarker) {
        image = [image imageOverlayedWithColor:[UIColor blackColor] opacity:0.3];
    }
	
    if (makeLighter) {
        image = [image imageOverlayedWithColor:[UIColor whiteColor] opacity:0.3];
    }
	
    return image;
}

+ (void)renderTableCell:(UITableViewCell *)tableCell withStyleNamed:(NSString *)styleName {
    DYNViewStyle *style = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
	
    if (style.drawAsynchronously) {
        __weak __typeof(& *self) weakSelf = self;
        [[self drawQueue] addOperationWithBlock:^{
            UIImage *img = [style imageForStyleWithSize:tableCell.frame.size parameters:tableCell.styleParameters];
			
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf applyImage:img fromStyle:style toTableCell:tableCell];
            }];
        }];
    } else {
        UIImage *img = [style imageForStyleWithSize:tableCell.frame.size parameters:tableCell.styleParameters];
        [self applyImage:img fromStyle:style toTableCell:tableCell];
    }
}

+ (void)applyImage:(UIImage *)image fromStyle:(DYNViewStyle *)style toTableCell:(UITableViewCell *)tableCell {
    UIView *backgroundView = [[UIView alloc] initWithFrame:tableCell.bounds];
    backgroundView.layer.contents = (id)image.CGImage;
    tableCell.backgroundView = backgroundView;
	
    if (style.tableCellTitleTextStyle) {
        [style.tableCellTitleTextStyle applyToLabel:tableCell.textLabel];
    }
	
    if (style.tableCellDetailTextStyle) {
        [style.tableCellDetailTextStyle applyToLabel:tableCell.detailTextLabel];
    }
}

+ (UIImage *)backBarButtonImageForStyle:(NSString *)styleName superStyle:(DYNViewStyle *)style parameters:(DYNStyleParameters *)parameters {
    DYNViewStyle *buttonStyle;
    BOOL flipGrad = NO;
    BOOL halfAlpha = NO;
	BOOL makeDarker = NO;
	BOOL makeLighter = NO;
	NSString *controlStyleName = styleName;
	
    if (style) {
        if ([controlStyleName isEqualToString:kDYNFlippedGradientKey]) {
			flipGrad = YES;
			buttonStyle = style;
		} else if ([controlStyleName isEqualToString:kDYNMakeDarkerKey]) {
			flipGrad = NO;
			halfAlpha = NO;
			makeLighter = NO;
			makeDarker = YES;
			buttonStyle = style;
		} else if ([controlStyleName isEqualToString:kDYNMakeLigherKey]) {
			flipGrad = NO;
			halfAlpha = NO;
			makeLighter = YES;
			makeDarker = NO;
			buttonStyle = style;
		} else {
			if ([controlStyleName isEqualToString:kDYNHalfOpacityKey]) {
				buttonStyle = style;
				halfAlpha = YES;
			} else {
				buttonStyle = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:controlStyleName];
			}
		}
    } else {
        buttonStyle = (DYNViewStyle *)[[DYNManager sharedInstance] styleForName:styleName];
    }
	
    CGFloat width = 10.5 + 13;
    CGFloat height = 28;
	
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(width - buttonStyle.cornerRadii.width, height)];
	
    [path addArcWithCenter:CGPointMake([path currentPoint].x, [path currentPoint].y - buttonStyle.cornerRadii.height) radius:buttonStyle.cornerRadii.width startAngle:M_PI / 2 endAngle:0 clockwise:NO];
    [path addLineToPoint:CGPointMake(width, buttonStyle.cornerRadii.height)];
    [path addArcWithCenter:CGPointMake([path currentPoint].x - buttonStyle.cornerRadii.width, buttonStyle.cornerRadii.height) radius:buttonStyle.cornerRadii.width startAngle:0 endAngle:degreesToRadians(270) clockwise:NO];
    [path addLineToPoint:CGPointMake(11.5, 0)];
    [path addQuadCurveToPoint:CGPointMake(0, 14) controlPoint:CGPointMake((10.5 / 2) + 3, 2)];
    [path addQuadCurveToPoint:CGPointMake(11.5, height) controlPoint:CGPointMake(((10.5 / 2) + 3), height - 2)];
    [path closePath];
	
	
    UIImage *img = [buttonStyle imageForStyleWithSize:CGSizeMake(CGRectGetWidth(path.bounds) + (CGRectGetWidth(path.bounds) * 0.25), CGRectGetHeight(path.bounds)) path:path withOuterShadow:YES parameters:parameters].dyn_resizableImage;
	
    if (halfAlpha) {
        img = [img imageWithOpacity:0.5];
    }
	if (makeDarker) {
        img = [img imageOverlayedWithColor:[UIColor blackColor] opacity:0.3];
    }
	
    if (makeLighter) {
        img = [img imageOverlayedWithColor:[UIColor whiteColor] opacity:0.3];
    }
    return img;
}

@end