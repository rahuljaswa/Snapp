//
//  RJStyleManager.h
//  Community
//

#import <UIKit/UIKit.h>


@interface RJStyleManager : NSObject

// *** APP OPTIONS ***

@property (nonatomic, assign) BOOL cropsImagesToSquares;
@property (nonatomic, assign) BOOL displaysImageResultsFromWeb;

// *** APPLICATION WIDE TINT COLORS ***

/* 
 @discussion Tint color used for accessories like borders and icons.
 */
@property (nonatomic, strong) UIColor *accessoryIconColor;
/*
 @discussion Tint color used for `UIButton`s.
 */
@property (nonatomic, strong) UIColor *buttonBackgroundColor;
/*
 @discussion Background color for text that is being touched by user.
 */
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
/*
 @discussion Tint color used for icons and text on buttons.
 */
@property (nonatomic, strong) UIColor *iconTextColor;
/*
 @discussion Tint color used for plain text, usually a shade of gray.
 */
@property (nonatomic, strong) UIColor *plainTextColor;
/*
 @discussion Tint color used for themed text like borders and icons.
 */
@property (nonatomic, strong) UIColor *themedTextColor;
/*
 @discussion Tint color used for things like text labels.
 */
@property (nonatomic, strong) UIColor *tintBlueColor;



// *** APPLICATION WIDE FONTS ***

/* 
 @discussion Plain-text font used in all text-based objects.
 */
@property (nonatomic, strong) UIFont *plainTextFont;
/*
 @discussion Bold-text font used in all text-based objects.
 */
@property (nonatomic, strong) UIFont *boldTextFont;
/*
 @discussion Title font used in all text-based objects.
 */
@property (nonatomic, strong) UIFont *titleFont;



// *** NAVIGATION BAR ***

/*
 @discussion Font used with `...` text for more buttons.
 */
@property (nonatomic, strong) UIFont *moreButtonFont;
/*
 @discussion Font used for `UINavigationBar`s.
 */
@property (nonatomic, strong) UIFont *navBarFont;
/*
 @discussion Color used for `UINavigationBar` backgrounds.
 */
@property (nonatomic, strong) UIColor *themeColor;
/*
 @discussion Color used for `UINavigationBar` text and `UIBarButtonItem`s.
 */
@property (nonatomic, strong) UIColor *windowTintColor;



// *** SPECIALIZED VIEWS ***

/*
 @discussion Color used for loading state with images.
 */
@property (nonatomic, strong) UIColor *loadingImageBackgroundColor;



// *** ATTRIBUTES - LINKS ***
@property (nonatomic, strong, readonly) NSDictionary *boldLinkTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *grayLinkTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *highlightedBoldLinkTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *highlightedGrayLinkTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *highlightedLinkTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *linkTextAttributes;



// *** ATTRIBUTES - REGULAR TEXT ***
@property (nonatomic, strong, readonly) NSDictionary *boldTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *darkGrayTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *highlightedBoldTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *highlightedDarkGrayTextAttributes;
@property (nonatomic, strong, readonly) NSDictionary *plainTextAttributes;



// *** SINGLETON ***
+ (instancetype)sharedInstance;

// *** WINDOW CUSTOMIZATION ***
- (void)applyGlobalStylesToWindow:(UIWindow *)window;

@end
