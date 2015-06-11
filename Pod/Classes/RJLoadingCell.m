//
//  RJLoadingCell.m
//  Pods
//
//  Created by Rahul Jaswa on 3/14/15.
//
//

#import "RJLoadingCell.h"

@implementation RJLoadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.center = self.contentView.center;
        _spinner.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
        [self.contentView addSubview:_spinner];
    }
    return self;
}

@end
