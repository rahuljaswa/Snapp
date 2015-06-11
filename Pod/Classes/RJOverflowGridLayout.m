//
//  RJOverflowGridLayout.m
//  Pods
//
//  Created by Rahul Jaswa on 3/20/15.
//
//

#import "RJOverflowGridLayout.h"


@interface RJOverflowGridLayout ()

@property (nonatomic, strong) NSArray *rowFrames;
@property (nonatomic, assign) CGFloat itemsPerRow;
@property (nonatomic, assign) CGFloat spacing;

@end


@implementation RJOverflowGridLayout

#pragma mark - Private Instance Methods

- (void)cacheRowFrames {
    self.itemsPerRow = floor(CGRectGetWidth(self.collectionView.bounds)/self.sideLength);
    self.spacing = (CGRectGetWidth(self.collectionView.bounds) - (self.sideLength * self.itemsPerRow))/(self.itemsPerRow - 2.0f);
    
    NSUInteger numberOfItems = 0;
    NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger i = 0; i < numberOfSections; i++) {
        numberOfItems += [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:i];
    }
    
    NSMutableArray *rowFrames = [[NSMutableArray alloc] init];
    NSUInteger numberOfRows = ceil((CGFloat)numberOfItems/self.itemsPerRow);
    for (NSUInteger i = 0; i < numberOfRows; i++) {
        CGRect rowFrame = CGRectMake(0.0f, (i * (self.sideLength + self.spacing)), CGRectGetWidth(self.collectionView.bounds), self.sideLength);
        [rowFrames addObject:NSStringFromCGRect(rowFrame)];
    }
    self.rowFrames = rowFrames;
}

- (void)setSideLength:(CGFloat)sideLength {
    _sideLength = sideLength < 0.5f ? 0.5f : floorf(sideLength * 2) / 2;
}

#pragma mark - Public Instance Methods - Layout

- (void)prepareLayout {
    [super prepareLayout];
    [self cacheRowFrames];
}

- (CGSize)collectionViewContentSize {
    CGFloat height = ([self.rowFrames count] * self.sideLength);
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    NSUInteger numberOfRows = [self.rowFrames count];
    for (NSUInteger i = 0; i < numberOfRows; i++) {
        CGRect rowFrame = CGRectFromString(self.rowFrames[i]);
        if (CGRectIntersectsRect(rect, rowFrame)) {
            for (NSUInteger j = 0; j < self.itemsPerRow; j++) {
                NSUInteger aggregateItemNumber = ((self.itemsPerRow * i) + j);
                NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
                NSUInteger numberOfItemsBeforeSection = 0;
                for (NSUInteger k = 0; k < numberOfSections; k++) {
                    NSUInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:k];
                    if (((aggregateItemNumber + 1) > numberOfItemsBeforeSection) &&
                        ((aggregateItemNumber + 1) <= (numberOfItemsBeforeSection + numberOfItemsInSection)))
                    {
                        NSUInteger item = (aggregateItemNumber - numberOfItemsBeforeSection);
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:k];
                        UICollectionViewLayoutAttributes *layoutAttr = [self layoutAttributesForItemAtIndexPath:indexPath];
                        layoutAttr.frame = CGRectMake((j * (self.spacing + self.sideLength)), CGRectGetMinY(rowFrame), self.sideLength, self.sideLength);
                        [layoutAttributes addObject:layoutAttr];
                        break;
                    }
                    numberOfItemsBeforeSection += numberOfItemsInSection;
                }
            }
        }
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
}

@end
