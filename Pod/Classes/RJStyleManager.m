//
//  RJStyleManager.m
//  Community
//

#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"


@interface RJStyleManager ()

@property (nonatomic, strong, readwrite) NSDictionary *plainTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *linkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *highlightedDarkGrayTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *highlightedGrayLinkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *highlightedLinkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *highlightedBoldLinkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *highlightedBoldTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *boldLinkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *boldTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *grayLinkTextAttributes;
@property (nonatomic, strong, readwrite) NSDictionary *darkGrayTextAttributes;

@end


@implementation RJStyleManager

#pragma mark - Public Properties - Application Wide Tint Colors

- (UIColor *)accessoryIconColor {
    if (!_accessoryIconColor) {
        _accessoryIconColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    }
    return _accessoryIconColor;
}

- (UIColor *)themedTextColor {
    if (!_themedTextColor) {
        _themedTextColor = [UIColor colorWithRed:31.0f/255.0f green:98.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    }
    return _themedTextColor;
}

- (UIColor *)plainTextColor {
    if (!_plainTextColor) {
        _plainTextColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    }
    return _plainTextColor;
}

- (UIColor *)highlightedBackgroundColor {
    if (!_highlightedBackgroundColor) {
        _highlightedBackgroundColor = [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    }
    return _highlightedBackgroundColor;
}

- (UIColor *)iconTextColor {
    if (!_iconTextColor) {
        _iconTextColor = [UIColor colorWithRed:159.0f/255.0f green:161.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    }
    return _iconTextColor;
}

- (UIColor *)buttonBackgroundColor {
    if (!_buttonBackgroundColor) {
        _buttonBackgroundColor = [UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    }
    return _buttonBackgroundColor;
}

- (UIColor *)loadingImageBackgroundColor {
    if (!_loadingImageBackgroundColor) {
        _loadingImageBackgroundColor = [UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    return _loadingImageBackgroundColor;
}

- (UIColor *)tintBlueColor {
    if (!_tintBlueColor) {
        _tintBlueColor = [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    return _tintBlueColor;
}

#pragma mark - Public Properties - Application Wide Fonts

- (UIFont *)titleFont {
    if (!_titleFont) {
        _titleFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
    }
    return _titleFont;
}

- (UIFont *)plainTextFont {
    if (!_plainTextFont) {
        _plainTextFont = [UIFont fontWithName:@"Helvetica" size:13.0f];
    }
    return _plainTextFont;
}

- (UIFont *)boldTextFont {
    if (!_boldTextFont) {
        _boldTextFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
    }
    return _boldTextFont;
}

#pragma mark - Public Properties - Navigation Bar

- (UIFont *)moreButtonFont {
    if (!_moreButtonFont) {
        _moreButtonFont = [UIFont systemFontOfSize:44.0f];
    }
    return _moreButtonFont;
}

- (UIFont *)navBarFont {
    if (!_navBarFont) {
        _navBarFont = [UIFont fontWithName:@"Avenir-Heavy" size:18.0f];
    }
    return _navBarFont;
}

- (UIColor *)themeColor {
    if (!_themeColor) {
        _themeColor = [UIColor colorWithRed:41.0f/255.0f green:90.0f/255.05 blue:130.0f/255.0f alpha:1.0f];
    }
    return _themeColor;
}

- (UIColor *)windowTintColor {
    if (!_windowTintColor) {
        _windowTintColor = [UIColor whiteColor];
    }
    return _windowTintColor;
}

#pragma mark - Public Properties - Attributes - Links

- (NSDictionary *)boldLinkTextAttributes {
    if (!_boldLinkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _boldLinkTextAttributes = @{
                                    NSFontAttributeName : self.boldTextFont,
                                    NSForegroundColorAttributeName : self.themedTextColor,
                                    NSParagraphStyleAttributeName : style
                                    };
    }
    return _boldLinkTextAttributes;
}

- (NSDictionary *)grayLinkTextAttributes {
    if (!_grayLinkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _grayLinkTextAttributes = @{
                                    NSFontAttributeName : self.boldTextFont,
                                    NSForegroundColorAttributeName : self.accessoryIconColor,
                                    NSParagraphStyleAttributeName : style
                                    };
    }
    return _grayLinkTextAttributes;
}

- (NSDictionary *)highlightedGrayLinkTextAttributes {
    if (!_highlightedGrayLinkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _highlightedGrayLinkTextAttributes = @{
                                               NSFontAttributeName : self.boldTextFont,
                                               NSForegroundColorAttributeName : self.iconTextColor,
                                               NSParagraphStyleAttributeName : style
                                               };
    }
    return _highlightedGrayLinkTextAttributes;
}

- (NSDictionary *)highlightedLinkTextAttributes {
    if (!_highlightedLinkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _highlightedLinkTextAttributes = @{
                                           NSFontAttributeName : [self plainTextFont],
                                           NSForegroundColorAttributeName : self.themedTextColor,
                                           NSBackgroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.3f],
                                           NSParagraphStyleAttributeName : style
                                           };
    }
    return _highlightedLinkTextAttributes;
}

- (NSDictionary *)highlightedBoldLinkTextAttributes {
    if (!_highlightedBoldLinkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _highlightedBoldLinkTextAttributes = @{
                                               NSFontAttributeName : self.boldTextFont,
                                               NSForegroundColorAttributeName : self.themedTextColor,
                                               NSBackgroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.3f],
                                               NSParagraphStyleAttributeName : style
                                               };
    }
    return _highlightedBoldLinkTextAttributes;
}

- (NSDictionary *)linkTextAttributes {
    if (!_linkTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _linkTextAttributes = @{
                                NSFontAttributeName : self.plainTextFont,
                                NSForegroundColorAttributeName : self.themedTextColor,
                                NSParagraphStyleAttributeName : style
                                };
    }
    return _linkTextAttributes;
}

#pragma mark - Public Properties - Attributes - Regular Text

- (NSDictionary *)boldTextAttributes {
    if (!_boldTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        _boldTextAttributes = @{
                                NSFontAttributeName : self.boldTextFont,
                                NSForegroundColorAttributeName : [UIColor darkTextColor],
                                NSParagraphStyleAttributeName : style
                                };
    }
    return _boldTextAttributes;
}

- (NSDictionary *)darkGrayTextAttributes {
    if (!_darkGrayTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        _darkGrayTextAttributes = @{
                                    NSFontAttributeName : self.boldTextFont,
                                    NSForegroundColorAttributeName : self.iconTextColor,
                                    NSParagraphStyleAttributeName : style
                                    };
    }
    return _darkGrayTextAttributes;
}

- (NSDictionary *)highlightedBoldTextAttributes {
    if (!_highlightedBoldTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        _highlightedBoldTextAttributes = @{
                                           NSFontAttributeName : self.boldTextFont,
                                           NSForegroundColorAttributeName : self.themedTextColor,
                                           NSParagraphStyleAttributeName : style
                                           };
    }
    return _highlightedBoldTextAttributes;
}

- (NSDictionary *)highlightedDarkGrayTextAttributes {
    if (!_highlightedDarkGrayTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        _highlightedDarkGrayTextAttributes = @{
                                               NSFontAttributeName : self.boldTextFont,
                                               NSForegroundColorAttributeName : self.themedTextColor,
                                               NSParagraphStyleAttributeName : style
                                               };
    }
    return _highlightedDarkGrayTextAttributes;
}

- (NSDictionary *)plainTextAttributes {
    if (!_plainTextAttributes) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineHeightMultiple = 1.1f;
        _plainTextAttributes = @{
                                 NSFontAttributeName : self.plainTextFont,
                                 NSForegroundColorAttributeName : self.plainTextColor,
                                 NSParagraphStyleAttributeName : style
                                 };
    }
    return _plainTextAttributes;
}

#pragma mark - Public Instance Methods

- (void)applyGlobalStylesToWindow:(UIWindow *)window {
    [window setTintColor:self.windowTintColor];
    
    [[UINavigationBar appearance] setBarTintColor:self.themeColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       NSFontAttributeName : self.navBarFont,
       NSForegroundColorAttributeName : self.windowTintColor
       }
     ];
    
    [[UIBarButtonItem appearance] setTintColor:self.windowTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:37.0f/255.0f green:39.0f/255.0f blue:42.0f/255.0f alpha:1.0f]]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:165.0f/255.0f green:167.0f/255.0f blue:170.0f/255.0f alpha:1.0f]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    CGFloat tabWidth = ceil([[UIScreen mainScreen] bounds].size.width/5.0f);
    CGFloat tabHeight = 49.0f;
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageWithColor:[UIColor colorWithRed:22.0f/255.0 green:24.0f/255.0 blue:25.0f/255.0 alpha:1.0f] size:CGSizeMake(tabWidth, tabHeight)]];
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJStyleManager *_sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[RJStyleManager alloc] init];
    });
    return _sharedInstance;
}

@end
