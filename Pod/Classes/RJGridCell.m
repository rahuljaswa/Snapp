//
//  RJGridCell.m
//  Community
//

#import "RJGridCell.h"
#import "RJManagedObjectImage.h"
#import "RJPostImageCacheEntity.h"
#import "RJStyleManager.h"
#import <FastImageCache/FICImageCache.h>
#import <Parse/Parse.h>
@import AssetsLibrary.ALAsset;


@interface RJGridCell ()

@property (nonatomic, strong) NSArray *dynamicConstraints;
@property (nonatomic, strong) RJPostImageCacheEntity *entity;
@property (nonatomic, strong) NSString *formatName;
@property (nonatomic, strong, readonly) UIView *maskView;
@property (nonatomic, assign, getter=hasSetupConstraints) BOOL setupConstraints;

@end


@implementation RJGridCell

#pragma mark - Public Properties

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        self.selectedBackgroundView.backgroundColor = [_selectedColor colorWithAlphaComponent:0.8f];
    }
}

- (void)setMask:(BOOL)mask {
    _mask = mask;
    if (_mask) {
        if (_maskView) {
            [self.contentView insertSubview:_maskView belowSubview:self.title];
        } else {
            _maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
            [self.contentView insertSubview:_maskView belowSubview:self.title];
        }
    } else {
        [_maskView removeFromSuperview];
    }
    [self updateConstraints];
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Private Instance Methods - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        
        self.clipsToBounds = YES;
        
        _setupConstraints = NO;
        
        _title = [[UILabel alloc] initWithFrame:frame];
        _title.numberOfLines = 3;
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [[RJStyleManager sharedInstance] titleFont];
        [self.contentView addSubview:_title];
        
        _image = [[UIImageView alloc] initWithFrame:frame];
        [self.backgroundView addSubview:_image];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.backgroundView addSubview:_spinner];
    }
    return self;
}

#pragma mark - Private Instance Methods - Layout

- (void)dealloc {
    [[FICImageCache sharedImageCache] cancelImageRetrievalForEntity:self.entity withFormatName:self.formatName];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[FICImageCache sharedImageCache] cancelImageRetrievalForEntity:self.entity withFormatName:self.formatName];
}

- (void)updateConstraints {
    if (!self.hasSetupConstraints) {
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *i = self.image;
        i.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *s = self.spinner;
        s.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *backgroundViews = NSDictionaryOfVariableBindings(i, s);
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[i]|"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-<=10-[s]"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-<=10-[s]"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.title
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.title
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f
                                       constant:0.0f]];
        self.title.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.bounds) - 2.0f*10.0f);
        
        self.setupConstraints = YES;
    }
    
    if (self.dynamicConstraints) {
        [self.backgroundView removeConstraints:self.dynamicConstraints];
    }
    
    if (self.mask) {
        self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f
                                       constant:10.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f
                                       constant:10.0f]];
    }
    
    [super updateConstraints];
}

- (void)updateWithImage:(id)image formatName:(NSString *)formatName displaysLoadingIndicator:(BOOL)displaysLoadingIndicator {
    self.formatName = formatName;
    self.image.image = nil;
    
    if ([image isKindOfClass:[UIImage class]]) {
        self.image.image = image;
        return;
    } else if ([image isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)image;
        self.image.image = [UIImage imageWithCGImage:asset.thumbnail];
        return;
    }
    
    NSString *objectID = nil;
    NSURL *imageURL = nil;
    if ([image isKindOfClass:[PFFile class]]) {
        PFFile *imageFile = image;
        imageURL = [NSURL URLWithString:imageFile.url];
        objectID = imageFile.url;
    } else if ([image isKindOfClass:[NSString class]]) {
        NSString *imageURLString = image;
        imageURL = [NSURL URLWithString:imageURLString];
        objectID = imageURLString;
    } else if ([image isKindOfClass:[RJManagedObjectImage class]]) {
        RJManagedObjectImage *imageObject = image;
        if (imageObject.imageURL) {
            imageURL = [NSURL URLWithString:imageObject.imageURL];
            objectID = imageObject.imageURL;
        } else {
            return;
        }
    }
    
    FICImageCache *imageCache = [FICImageCache sharedImageCache];
    
    if (self.entity) {
        [imageCache cancelImageRetrievalForEntity:self.entity withFormatName:formatName];
    }
    
    self.entity = [[RJPostImageCacheEntity alloc] initWithPostImageURL:imageURL
                                                              objectID:objectID];
    
    if (![imageCache imageExistsForEntity:self.entity withFormatName:formatName]) {
        if (displaysLoadingIndicator) {
            [self.spinner startAnimating];
        }
        if (self.shouldDisableDuringLoading) {
            self.userInteractionEnabled = NO;
        }
    }
    
    __weak __typeof(self) weakSelf = self;
    [imageCache retrieveImageForEntity:self.entity
                        withFormatName:formatName
                       completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image)
     {
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         if (strongSelf) {
             strongSelf.userInteractionEnabled = YES;
             if (displaysLoadingIndicator) {
                 [strongSelf.spinner stopAnimating];
             }
             strongSelf.image.image = image;
         }
     }];
}

@end
