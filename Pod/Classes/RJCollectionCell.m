//
//  RJCollectionCell.m
//  Community
//

#import "RJCollectionCell.h"


@implementation RJCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collection = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        _collection.alwaysBounceHorizontal = YES;
        _collection.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.contentView addSubview:_collection];
    }
    return self;
}

@end
