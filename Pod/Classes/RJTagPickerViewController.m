//
//  RJTagPickerViewController.m
//  Community
//

#import "RJCoreDataManager.h"
#import "RJTagPickerViewController.h"
#import "RJGridCell.h"
#import "RJManagedObjectPostCategory.h"
#import "RJOverflowGridLayout.h"
#import "RJPostImageCacheEntity.h"
#import "RJStore.h"
#import "RJStyleManager.h"

static NSString *const kRJGridCellID = @"RJGridCellID";


@interface RJTagPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, strong) NSString *pendingCreatedCategory;

@property (nonatomic, strong) NSArray *searchCreatedCategories;
@property (nonatomic, strong) NSArray *searchExistingCategories;

@property (nonatomic, strong) NSMutableArray *selectedCreatedTagsSearchIndexes;
@property (nonatomic, strong) NSMutableArray *selectedExistingTagsSearchIndexes;

@property (nonatomic, strong) NSMutableArray *createdCategories;
@property (nonatomic, strong) NSArray *existingCategories;

@property (nonatomic, strong) NSMutableArray *selectedCreatedTagsIndexes;
@property (nonatomic, strong) NSMutableArray *selectedExistingTagsIndexes;

@property (nonatomic, strong, readonly) NSArray *initiallySelectedCreatedTags;
@property (nonatomic, strong, readonly) NSArray *initiallySelectedExistingTags;

@end


@implementation RJTagPickerViewController

#pragma mark - Public Properties

- (NSArray *)selectedCreatedTags {
    NSMutableArray *selectedCreatedTags = [[NSMutableArray alloc] init];
    for (NSNumber *indexNumber in self.selectedCreatedTagsIndexes) {
        [selectedCreatedTags addObject:[self.createdCategories objectAtIndex:[indexNumber integerValue]]];
    }
    return selectedCreatedTags;
}

- (NSArray *)selectedExistingTags {
    NSMutableArray *selectedExistingTags = [[NSMutableArray alloc] init];
    for (NSNumber *indexNumber in self.selectedExistingTagsIndexes) {
        [selectedExistingTags addObject:[self.existingCategories objectAtIndex:[indexNumber integerValue]]];
    }
    return selectedExistingTags;
}

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSError *error = nil;
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllCategories];
    
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    [categories addObjectsFromArray:self.createdCategories];
    
    self.existingCategories = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching categories\n\n%@", [error localizedDescription]);
    }
    
    for (NSString *selectedCreatedCategory in self.initiallySelectedCreatedTags) {
        NSUInteger item = [self.createdCategories indexOfObject:selectedCreatedCategory];
        if (item != NSNotFound) {
            [self addSelectedIndexPath:[NSIndexPath indexPathForItem:item inSection:1]];
        }
    }
    
    for (RJManagedObjectPostCategory *selectedExistingCategory in self.initiallySelectedExistingTags) {
        NSUInteger item = [self.existingCategories indexOfObject:selectedExistingCategory];
        if (item != NSNotFound) {
            [self addSelectedIndexPath:[NSIndexPath indexPathForItem:item inSection:2]];
        }
    }
}

#pragma mark - Private Protocols - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.searchString = nil;
        self.pendingCreatedCategory = nil;
    } else {
        self.searchString = searchText;
        self.pendingCreatedCategory = self.searchString;
        [self updateSearchResults];
    }
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeSelectedIndexPath:indexPath];
    RJGridCell *cell = (RJGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = [self shouldSelectCellAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self updateTitle];
    if ([self.pickerDelegate respondsToSelector:@selector(tagPickerViewControllerSelectedTagsDidChange:)]) {
        [self.pickerDelegate tagPickerViewControllerSelectedTagsDidChange:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.createdCategories addObject:self.pendingCreatedCategory];
        [self updateSearchResults];
        NSUInteger section = 1;
        NSUInteger item = [self.searchCreatedCategories indexOfObject:self.pendingCreatedCategory];
        [self addSelectedIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        self.pendingCreatedCategory = nil;
        [self updateSelectedSearchIndexes];
        [collectionView reloadData];
    } else {
        [self addSelectedIndexPath:indexPath];
        RJGridCell *cell = (RJGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selected = [self shouldSelectCellAtIndexPath:indexPath];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [self updateTitle];
    if ([self.pickerDelegate respondsToSelector:@selector(tagPickerViewControllerSelectedTagsDidChange:)]) {
        [self.pickerDelegate tagPickerViewControllerSelectedTagsDidChange:self];
    }
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    if (section == 0) {
        numberOfItems = !!self.pendingCreatedCategory;
    } else if (section == 1) {
        if (self.searchString) {
            numberOfItems = [self.searchCreatedCategories count];
        } else {
            numberOfItems = [self.createdCategories count];
        }
    } else {
        if (self.searchString) {
            numberOfItems = [self.searchExistingCategories count];
        } else {
            numberOfItems = [self.existingCategories count];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRJGridCellID forIndexPath:indexPath];
    cell.backgroundView.backgroundColor = [[RJStyleManager sharedInstance] loadingImageBackgroundColor];
    cell.selectedColor = [[RJStyleManager sharedInstance] themeColor];
    cell.disableDuringLoading = NO;
    cell.mask = YES;
    
    if (indexPath.section == 0) {
        cell.title.text = [NSString stringWithFormat:@"Create \"%@\"", self.pendingCreatedCategory];
        cell.image.image = nil;
    } else if (indexPath.section == 1) {
        NSString *category = nil;
        if (self.searchString) {
            category = [self.searchCreatedCategories objectAtIndex:indexPath.item];
        } else {
            category = [self.createdCategories objectAtIndex:indexPath.item];
        }
        cell.title.text = category;
        cell.image.image = nil;
    } else if (indexPath.section == 2) {
        RJManagedObjectPostCategory *category = nil;
        if (self.searchString) {
            category = [self.searchExistingCategories objectAtIndex:indexPath.item];
        } else {
            category = [self.existingCategories objectAtIndex:indexPath.item];
        }
        cell.title.text = category.name;
        id image = category.image;
        if (image) {
            [cell updateWithImage:image formatName:kRJPostImageFormatCardSquare16BitBGR displaysLoadingIndicator:NO];
        } else {
            cell.image.image = nil;
        }
    }
    
    BOOL selected = [self shouldSelectCellAtIndexPath:indexPath];
    cell.selected = selected;
    if (selected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

#pragma mark - Private Instance Methods

- (void)updateSelectedSearchIndexes {
    [self.selectedExistingTagsSearchIndexes removeAllObjects];
    for (NSNumber *indexNumber in self.selectedExistingTagsIndexes) {
        RJManagedObjectPostCategory *existingCategory = [self.existingCategories objectAtIndex:[indexNumber integerValue]];
        NSUInteger indexInSearchCategories = [self.searchExistingCategories indexOfObject:existingCategory];
        if (indexInSearchCategories != NSNotFound) {
            [self.selectedExistingTagsSearchIndexes addObject:@(indexInSearchCategories)];
        }
    }
    
    [self.selectedCreatedTagsSearchIndexes removeAllObjects];
    for (NSNumber *indexNumber in self.selectedCreatedTagsIndexes) {
        NSString *createdCategory = [self.createdCategories objectAtIndex:[indexNumber integerValue]];
        NSUInteger indexInSearchCategories = [self.searchCreatedCategories indexOfObject:createdCategory];
        if (indexInSearchCategories != NSNotFound) {
            [self.selectedCreatedTagsSearchIndexes addObject:@(indexInSearchCategories)];
        }
    }
}

- (void)updateSearchResults {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", self.searchString];
    self.searchCreatedCategories = [self.createdCategories filteredArrayUsingPredicate:predicate];
    
    NSError *error = nil;
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = fetchRequest = [RJStore fetchRequestForAllCategoriesWithSearchString:self.searchString];
    self.searchExistingCategories = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching categories\n\n%@", [error localizedDescription]);
    }
    
    [self updateSelectedSearchIndexes];
}

- (void)addSelectedIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (self.searchString) {
            NSString *selectedCategory = [self.searchCreatedCategories objectAtIndex:indexPath.item];
            NSUInteger indexOfSelectedCategoryInCreatedCategories = [self.createdCategories indexOfObject:selectedCategory];
            [self.selectedCreatedTagsIndexes addObject:@(indexOfSelectedCategoryInCreatedCategories)];
        } else {
            [self.selectedCreatedTagsIndexes addObject:@(indexPath.item)];
        }
    } else if (indexPath.section == 2) {
        if (self.searchString) {
            RJManagedObjectPostCategory *selectedCategory = [self.searchExistingCategories objectAtIndex:indexPath.item];
            NSUInteger indexOfSelectedCategoryInExistingCategories = [self.existingCategories indexOfObject:selectedCategory];
            [self.selectedExistingTagsIndexes addObject:@(indexOfSelectedCategoryInExistingCategories)];
        } else {
            [self.selectedExistingTagsIndexes addObject:@(indexPath.item)];
        }
    }
}

- (void)removeSelectedIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (self.searchString) {
            NSString *selectedCategory = [self.searchCreatedCategories objectAtIndex:indexPath.item];
            NSUInteger indexOfSelectedCategoryInCreatedCategories = [self.createdCategories indexOfObject:selectedCategory];
            [self.selectedCreatedTagsIndexes removeObject:@(indexOfSelectedCategoryInCreatedCategories)];
        } else {
            [self.selectedCreatedTagsIndexes removeObject:@(indexPath.item)];
        }
    } else if (indexPath.section == 2) {
        if (self.searchString) {
            RJManagedObjectPostCategory *selectedCategory = [self.searchExistingCategories objectAtIndex:indexPath.item];
            NSUInteger indexOfSelectedCategoryInExistingCategories = [self.existingCategories indexOfObject:selectedCategory];
            [self.selectedExistingTagsIndexes removeObject:@(indexOfSelectedCategoryInExistingCategories)];
        } else {
            [self.selectedExistingTagsIndexes removeObject:@(indexPath.item)];
        }
    }
}

- (BOOL)shouldSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selected = NO;
    if (indexPath.section == 1) {
        if (self.searchString) {
            selected = [self.selectedCreatedTagsSearchIndexes containsObject:@(indexPath.item)];
        } else {
            selected = [self.selectedCreatedTagsIndexes containsObject:@(indexPath.item)];
        }
    } else if (indexPath.section == 2) {
        if (self.searchString) {
            selected = [self.selectedExistingTagsSearchIndexes containsObject:@(indexPath.item)];
        } else {
            selected = [self.selectedExistingTagsIndexes containsObject:@(indexPath.item)];
        }
    }
    return selected;
}

- (void)updateTitle {
    NSUInteger numTags = ([self.selectedExistingTagsIndexes count] + [self.selectedCreatedTagsIndexes count]);
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Tags", nil), @(numTags)];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame;
    [[notification userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(keyboardFrame), 0.0f);
    self.collectionView.scrollIndicatorInsets = insets;
    self.collectionView.contentInset = insets;
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIView *searchBar = self.searchBar;
    UIView *collectionView = self.collectionView;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:searchBar];
    [self.view addSubview:collectionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(searchBar, collectionView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar][collectionView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:views]];
}

- (instancetype)initWithInitiallySelectedExistingTags:(NSArray *)initiallySelectedExistingTags initiallySelectedCreatedTags:(NSArray *)initiallySelectedCreatedTags {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _createdCategories = [[NSMutableArray alloc] init];
        
        _selectedCreatedTagsIndexes = [[NSMutableArray alloc] init];
        _selectedExistingTagsIndexes = [[NSMutableArray alloc] init];
        
        _selectedCreatedTagsSearchIndexes = [[NSMutableArray alloc] init];
        _selectedExistingTagsSearchIndexes = [[NSMutableArray alloc] init];
        
        _initiallySelectedCreatedTags = initiallySelectedCreatedTags;
        _initiallySelectedExistingTags = initiallySelectedExistingTags;
        
        RJOverflowGridLayout *layout = [[RJOverflowGridLayout alloc] init];
        layout.sideLength = CGRectGetWidth([[UIScreen mainScreen] bounds])/3.0f;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.tintColor = [[RJStyleManager sharedInstance] tintBlueColor];
        _searchBar.delegate = self;
        
        [self fetchData];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.searchBar isFirstResponder]) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[RJGridCell class] forCellWithReuseIdentifier:kRJGridCellID];
    
    [self updateTitle];
}

@end
