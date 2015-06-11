//
//  RJFeedsViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 3/11/15.
//
//

#import "RJCategoryViewController.h"
#import "RJCoreDataManager.h"
#import "RJFeedViewController.h"
#import "RJFeedsViewController.h"
#import "RJLoadingCell.h"
#import "RJProfileViewController.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import "RJTemplateManager.h"
@import CoreData.NSFetchRequest;

typedef NS_ENUM(NSUInteger, RJFeedsViewControllerSearchResultsSection) {
    kRJFeedsViewControllerSearchResultsSectionInstructions,
    kRJFeedsViewControllerSearchResultsSectionTags,
    kRJFeedsViewControllerSearchResultsSectionUsers,
    kRJFeedsViewControllerSearchResultsSectionPosts,
    kNumRJFeedsViewControllerSearchResultsSections
};

static NSString *const kRJFeedsViewControllerLoadingCell = @"RJFeedsViewControllerLoadingCell";
static NSString *const kRJFeedsViewControllerSearchResultsCell = @"RJFeedsViewControllerSearchResultsCell";


@interface RJFeedsViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) RJFeedViewController *viewController;

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UITableView *searchResultsTableView;

@property (nonatomic, assign, getter=isSearching) BOOL searching;

@property (nonatomic, strong) NSArray *searchResultsPosts;
@property (nonatomic, strong) NSArray *searchResultsTags;
@property (nonatomic, strong) NSArray *searchResultsUsers;

@end


@implementation RJFeedsViewController

@synthesize viewController = _viewController;

#pragma mark - Private Properties

- (RJFeedViewController *)viewController {
    if (!_viewController) {
        RJTemplateManagerType templateType = [[RJTemplateManager sharedInstance] type];
        switch (templateType) {
            case kRJTemplateManagerTypeClassifieds:
                _viewController = [[RJFeedViewController alloc] init];
                break;
            case kRJTemplateManagerTypeCommunity:
                _viewController = [[RJFeedViewController alloc] init];
                break;
        }
    }
    return _viewController;
}

#pragma mark - Private Instance Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame;
    [[notification userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGFloat tabBarHeight = CGRectGetHeight([[[self navigationController] navigationBar] bounds]);
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(keyboardFrame) - tabBarHeight, 0.0f);
    self.searchResultsTableView.scrollIndicatorInsets = insets;
    self.searchResultsTableView.contentInset = insets;
}

- (void)searchButtonPressed:(UIBarButtonItem *)button {
    [self updateNavigationItemForShowingSearchBar];
    [self.searchBar becomeFirstResponder];
}

- (void)updateNavigationItemForHidingSearchBar {
    self.navigationItem.title = [NSLocalizedString(@"Latest", nil) uppercaseString];
    self.navigationItem.titleView = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed:)];
}

- (void)updateNavigationItemForShowingSearchBar {
    self.title = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = self.searchBar;
}

#pragma mark - Private Instance Methods - Search Results Updating

- (void)updateInstructionsWithCategoriesCompletion:(BOOL)categoriesCompletion postsCompletion:(BOOL)postsCompletion usersCompletion:(BOOL)usersCompletion {
    if (categoriesCompletion && postsCompletion && usersCompletion) {
        self.searching = NO;
    }
}

- (void)updateCategoriesSearchResultsForString:(NSString *)text {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];;
    if (text && (text.length > 0)) {
        NSError *tagsError = nil;
        NSFetchRequest *tagsFetchRequest = [RJStore fetchRequestForAllCategoriesWithSearchString:text];
        self.searchResultsTags = [context executeFetchRequest:tagsFetchRequest error:&tagsError];
        if (tagsError) {
            NSLog(@"Error fetching search results tags\n\n%@", [tagsError localizedDescription]);
        }
    } else {
        self.searchResultsTags = nil;
    }
}

- (void)updatePostsSearchResultsForString:(NSString *)text {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];;
    if (text && (text.length > 0)) {
        NSError *postsError = nil;
        NSFetchRequest *postsFetchRequest = [RJStore fetchRequestForAllPostsWithSearchString:text];
        self.searchResultsPosts = [context executeFetchRequest:postsFetchRequest error:&postsError];
        if (postsError) {
            NSLog(@"Error fetching search results posts\n\n%@", [postsError localizedDescription]);
        }
    } else {
        self.searchResultsPosts = nil;
    }
}

- (void)updateUsersSearchResultsForString:(NSString *)text {
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];;
    if (text && (text.length > 0)) {
        NSError *usersError = nil;
        NSFetchRequest *usersFetchRequest = [RJStore fetchRequestForAllUsersWithSearchString:text];
        self.searchResultsUsers = [context executeFetchRequest:usersFetchRequest error:&usersError];
        if (usersError) {
            NSLog(@"Error fetching search results users\n\n%@", [usersError localizedDescription]);
        }
    } else {
        self.searchResultsUsers = nil;
    }
}

- (void)updateSearchResultsForString:(NSString *)text {
    [self updatePostsSearchResultsForString:text];
    [self updateCategoriesSearchResultsForString:text];
    [self updateUsersSearchResultsForString:text];
    [self.searchResultsTableView reloadData];
}

#pragma mark - Private Protocols - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self updateNavigationItemForHidingSearchBar];
    [UIView animateWithDuration:0.3
                     animations:^{
        self.searchResultsTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.searchBar.text = nil;
        self.searching = NO;
        [self updateSearchResultsForString:nil];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searching = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kRJFeedsViewControllerSearchResultsSectionInstructions];
    [self.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    __block BOOL postsCompletion = NO;
    __block BOOL categoriesCompletion = NO;
    __block BOOL usersCompletion = NO;
    
    NSString *text = searchBar.text;
    
    [RJStore refreshAllPostsWithSearchString:text completion:^(BOOL success) {
        postsCompletion = YES;
        [self updateInstructionsWithCategoriesCompletion:categoriesCompletion postsCompletion:postsCompletion usersCompletion:usersCompletion];
        [self updatePostsSearchResultsForString:text];
        [self.searchResultsTableView reloadData];
    }];
    [RJStore refreshAllCategoriesWithSearchString:text completion:^(BOOL success) {
        categoriesCompletion = YES;
        [self updateInstructionsWithCategoriesCompletion:categoriesCompletion postsCompletion:postsCompletion usersCompletion:usersCompletion];
        [self updateCategoriesSearchResultsForString:text];
        [self.searchResultsTableView reloadData];
    }];
    [RJStore refreshAllUsersWithSearchString:text completion:^(BOOL success) {
        usersCompletion = YES;
        [self updateInstructionsWithCategoriesCompletion:categoriesCompletion postsCompletion:postsCompletion usersCompletion:usersCompletion];
        [self updateUsersSearchResultsForString:text];
        [self.searchResultsTableView reloadData];
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.3 animations:^{
        self.searchResultsTableView.alpha = 1.0f;
    }];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchResultsForString:searchText];
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumRJFeedsViewControllerSearchResultsSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    RJFeedsViewControllerSearchResultsSection searchResultsSection = section;
    switch (searchResultsSection) {
        case kRJFeedsViewControllerSearchResultsSectionInstructions:
            numberOfRows = 1;
            break;
        case kRJFeedsViewControllerSearchResultsSectionPosts:
            numberOfRows = [self.searchResultsPosts count];
            break;
        case kRJFeedsViewControllerSearchResultsSectionTags:
            numberOfRows = [self.searchResultsTags count];
            break;
        case kRJFeedsViewControllerSearchResultsSectionUsers:
            numberOfRows = [self.searchResultsUsers count];
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    RJFeedsViewControllerSearchResultsSection searchResultsSection = indexPath.section;
    switch (searchResultsSection) {
        case kRJFeedsViewControllerSearchResultsSectionInstructions: {
            if (self.isSearching) {
                RJLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:kRJFeedsViewControllerLoadingCell forIndexPath:indexPath];
                [loadingCell.spinner startAnimating];
                cell = loadingCell;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kRJFeedsViewControllerSearchResultsCell forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Type to find results locally. Press \"Search\" button to find all results.", nil);
            }
            cell.userInteractionEnabled = NO;
            break;
        }
        case kRJFeedsViewControllerSearchResultsSectionPosts: {
            cell = [tableView dequeueReusableCellWithIdentifier:kRJFeedsViewControllerSearchResultsCell forIndexPath:indexPath];
            cell.textLabel.text = [self.searchResultsPosts[indexPath.row] name];
            cell.userInteractionEnabled = YES;
            break;
        }
        case kRJFeedsViewControllerSearchResultsSectionTags: {
            cell = [tableView dequeueReusableCellWithIdentifier:kRJFeedsViewControllerSearchResultsCell forIndexPath:indexPath];
            cell.textLabel.text = [self.searchResultsTags[indexPath.row] name];
            cell.userInteractionEnabled = YES;
            break;
        }
        case kRJFeedsViewControllerSearchResultsSectionUsers: {
            cell = [tableView dequeueReusableCellWithIdentifier:kRJFeedsViewControllerSearchResultsCell forIndexPath:indexPath];
            cell.textLabel.text = [self.searchResultsUsers[indexPath.row] name];
            cell.userInteractionEnabled = YES;
            break;
        }
        default:
            break;
    }
    
    if (![cell isKindOfClass:[RJLoadingCell class]]) {
        cell.textLabel.font = [RJStyleManager sharedInstance].plainTextFont;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
    
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    
    UIViewController *viewController = nil;
    
    RJFeedsViewControllerSearchResultsSection searchResultsSection = indexPath.section;
    switch (searchResultsSection) {
        case kRJFeedsViewControllerSearchResultsSectionPosts:
            viewController = [[RJFeedViewController alloc] initWithPost:self.searchResultsPosts[indexPath.row]];
            break;
        case kRJFeedsViewControllerSearchResultsSectionTags:
            viewController = [[RJCategoryViewController alloc] initWithCategory:self.searchResultsTags[indexPath.row]];
            break;
        case kRJFeedsViewControllerSearchResultsSectionUsers:
            viewController = [[RJProfileViewController alloc] initWithUser:self.searchResultsUsers[indexPath.row]];
            break;
        default:
            break;
    }
    
    if (viewController) {
        [[self navigationController] pushViewController:viewController animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    
    RJFeedsViewControllerSearchResultsSection searchResultsSection = section;
    switch (searchResultsSection) {
        case kRJFeedsViewControllerSearchResultsSectionPosts:
            title = NSLocalizedString(@"Posts", nil);
            break;
        case kRJFeedsViewControllerSearchResultsSectionTags:
            title = NSLocalizedString(@"Tags", nil);
            break;
        case kRJFeedsViewControllerSearchResultsSectionUsers:
            title = NSLocalizedString(@"Users", nil);
            break;
        default:
            break;
    }
    return title;
}

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    [self.viewController fetchData];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [self.viewController reloadWithCompletion:completion];
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"feedIcon"] selectedImage:[UIImage imageNamed:@"feedIcon"]];
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.tintColor = [[RJStyleManager sharedInstance] tintBlueColor];
        _searchBar.showsCancelButton = YES;
        
        _searchResultsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJFeedsViewControllerSearchResultsCell];
        [_searchResultsTableView registerClass:[RJLoadingCell class] forCellReuseIdentifier:kRJFeedsViewControllerLoadingCell];
        _searchResultsTableView.dataSource = self;
        _searchResultsTableView.delegate = self;
        _searchResultsTableView.alpha = 0.0f;
        _searchResultsTableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.view addSubview:_searchResultsTableView];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self addChildViewController:self.viewController];
    UIView *childView = self.viewController.view;
    [self.view addSubview:childView];
    [self.viewController didMoveToParentViewController:self];
    
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(childView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self updateNavigationItemForHidingSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.searchResultsTableView.alpha != 0.0f) {
        [self.searchResultsTableView deselectRowAtIndexPath:[self.searchResultsTableView indexPathForSelectedRow] animated:YES];
        [self.searchBar becomeFirstResponder];
    }
}

@end
