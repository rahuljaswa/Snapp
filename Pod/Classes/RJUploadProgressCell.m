//
//  RJUploadProgressCell.m
//  Pods
//
//  Created by Rahul Jaswa on 3/21/15.
//
//

#import "RJUploadProgressCell.h"

@implementation RJUploadProgressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.bounds)-2.0f, CGRectGetWidth(self.contentView.bounds), 2.0f);
        [self.contentView addSubview:_progressView];
    }
    return self;
}

@end
