//
//  RJUserPickerViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 4/23/15.
//
//

#import "RJCoreDataManager.h"
#import "RJManagedObjectImage.h"
#import "RJManagedObjectUser.h"
#import "RJStore.h"
#import "RJUserImageCacheEntity.h"
#import "RJUserPickerViewController.h"
#import "RJViewControllerDataSourceProtocol.h"
#import "UIImageView+RJAdditions.h"

static NSString *const kRJUserPickerViewControllerCellID = @"RJUserPickerViewControllerCellID";


@interface RJUserPickerViewController () <RJViewControllerDataSourceProtocol>

@property (nonatomic, strong, readonly) RJManagedObjectUser *initiallySelectedUser;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSArray *users;

@end


@implementation RJUserPickerViewController

#pragma mark - Public Properties

- (RJManagedObjectUser *)selectedUser {
    if (self.selectedIndexPath) {
        return [self.users objectAtIndex:self.selectedIndexPath.row];
    } else {
        return nil;
    }
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJManagedObjectUser *user = self.users[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJUserPickerViewControllerCellID forIndexPath:indexPath];
    cell.textLabel.text = user.name;
    UIImage *placeholder = [UIImage imageNamed:@"userPlaceholderPicture80x80"];
    if (user.image) {
        NSURL *url = [NSURL URLWithString:user.image.imageURL];
        NSString *objectID = [[user.image.objectID URIRepresentation] absoluteString];
        RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url objectID:objectID];
        [cell.imageView setImageEntity:entity formatName:kRJUserImageFormatCard16BitBGR80x80 placeholder:placeholder];
    } else {
        cell.imageView.image = placeholder;
    }
    cell.accessoryView = nil;
    
    if ([self.selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.tintColor = [UIColor lightGrayColor];
    if (self.selectedIndexPath) {
        UITableViewCell *previouslySelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        previouslySelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.selectedIndexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self updateTitle];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSError *error = nil;
    NSManagedObjectContext *context = [[RJCoreDataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [RJStore fetchRequestForAllUsers];
    self.users = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching objects\n\n%@", [error localizedDescription]);
    }
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllUsers:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Private Instance Methods

- (void)cancelButtonPressed:(UIBarButtonItem *)barButtonItem {
    if ([self.delegate respondsToSelector:@selector(userPickerViewControllerDidCancel:)]) {
        [self.delegate userPickerViewControllerDidCancel:self];
    }
}

- (void)doneButtonPressed:(UIBarButtonItem *)barButtonItem {
    if ([self.delegate respondsToSelector:@selector(userPickerViewControllerDidFinish:)]) {
        [self.delegate userPickerViewControllerDidFinish:self];
    }
}

#pragma mark - Private Instance Methods

- (void)updateTitle {
    if (self.selectedIndexPath) {
        self.title = [[self.users objectAtIndex:self.selectedIndexPath.row] name];
    } else {
        self.title = NSLocalizedString(@"Select Creator", nil);
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithInitiallySelectedUser:(RJManagedObjectUser *)user {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initiallySelectedUser = user;
        
        [self fetchData];
        
        if (_initiallySelectedUser) {
            NSUInteger indexOfInitiallySelectedUser = [self.users indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                RJManagedObjectUser *user = obj;
                return [user.objectID isEqual:_initiallySelectedUser.objectID];
            }];
            if (indexOfInitiallySelectedUser != NSNotFound) {
                self.selectedIndexPath = [NSIndexPath indexPathForRow:indexOfInitiallySelectedUser inSection:0];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJUserPickerViewControllerCellID];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelButton"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancel animated:NO];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createButton"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:done animated:NO];
    
    self.navigationItem.title = [NSLocalizedString(@"Create", nil) uppercaseString];
    
    [self reloadWithCompletion:nil];
    [self updateTitle];
}

@end
