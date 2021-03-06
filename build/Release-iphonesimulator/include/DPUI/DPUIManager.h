//
//  DPStyleManager.h
//  TheQ
//
//  Created by Dan Pourhadi on 4/27/13.
//
//

#import <Foundation/Foundation.h>

@class DPUIStyle;
@class DPUITextStyle;
@class DPUIViewStyle;
@interface DPUIManager : NSObject

+ (DPUIManager *)sharedInstance;

@property (nonatomic, strong) NSMutableArray *styles;
@property (nonatomic, strong) NSMutableArray *colorVariables;
@property (nonatomic, strong) NSMutableArray *textStyles;

@property (nonatomic, strong) NSDictionary *defaultParameterValues;

- (id)defaultValueForParameter:(NSString *)parameter;

@property (nonatomic, strong) NSArray *registeredViews;

@property (nonatomic, readonly) BOOL liveUpdating;

- (DPUIViewStyle *)styleForName:(NSString *)name;
- (UIColor *)colorForVariableName:(NSString *)variableName;
- (DPUITextStyle *)textStyleForName:(NSString *)name;

- (void)registerView:(id)view;
- (void)unregisterView:(id)view;

- (void)sendUpdateNotification;
/*!
 @method -loadStylesFromFile:replaceExisting:liveUpdate:
 @abstract Loads a .dpui style file
 @param fileName The name, with extension, of the style file. (i.e., "Style.dpui"). When live-updating, this string must be the absolute path to the file (i.e., /Users/dpourhad/Projects/App/Style.dpui)
 @param replaceExisting Replace the existing styles or append to them. Adding duplicate styles results in undefine behavior
 @param liveUpdate When liveUpdate is YES, changes saved to the style file specified in fileName are instantly reflected in the simulator when the app is running (no need to re-compile).
 */
- (void)loadStylesFromFile:(NSString *)fileName replaceExisting:(BOOL)replaceExisting liveUpdate:(BOOL)liveUpdate;
@end
