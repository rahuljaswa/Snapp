//
//  RJUserImageCacheEntity.m
//  Community
//

#import "RJUserImageCacheEntity.h"
#import <FastImageCache/FICUtilities.h>


NSString *const kRJImageFormatFamilyUser = @"RJImageFormatFamilyUser";

NSString *const kRJUserImageFormatCard16BitBGR40x40 = @"RJUserImageFormatCard16BitBGR40x40";
CGSize const kRJUserImageSize40x40 = {40, 40};

NSString *const kRJUserImageFormatCard16BitBGR80x80 = @"RJUserImageFormatCard16BitBGR80x80";
CGSize const kRJUserImageSize80x80 = {80, 80};


@interface RJUserImageCacheEntity ()

@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (strong, nonatomic, readonly) NSString *objectID;

@end


@implementation RJUserImageCacheEntity

@synthesize imageURL = _imageURL;
@synthesize objectID = _objectID;
@synthesize sourceImageUUID = _sourceImageUUID;
@synthesize UUID = _UUID;

#pragma mark - Public Protocols - FICEntity

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        
        CGFloat newWidth;
        CGFloat newHeight;
        
        if (image.size.width <= image.size.height) {
            newWidth = contextSize.width;
            newHeight = ((newWidth/image.size.width) * image.size.height);
        } else {
            newHeight = contextSize.height;
            newWidth = ((newHeight/image.size.height) * image.size.width);
        }
        
        CGFloat newX = (CGRectGetWidth(contextBounds)/2.0f - newWidth/2.0f);
        CGFloat newY = (CGRectGetHeight(contextBounds)/2.0f - newHeight/2.0f);
        
        UIGraphicsPushContext(context);
        [image drawInRect:CGRectMake(newX, newY, newWidth, newHeight)];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return self.imageURL;
}

- (NSString *)sourceImageUUID {
    if (!_sourceImageUUID) {
        CFUUIDBytes sourceImageUUIDBytes;
        sourceImageUUIDBytes = FICUUIDBytesFromMD5HashOfString([self.imageURL absoluteString]);
        _sourceImageUUID = FICStringWithUUIDBytes(sourceImageUUIDBytes);
    }
    return _sourceImageUUID;
}

- (NSString *)UUID {
    if (!_UUID) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(self.objectID);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    return _UUID;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithUserImageURL:(NSURL *)imageURL objectID:(NSString *)objectID {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _objectID = objectID;
    }
    return self;
}

@end
