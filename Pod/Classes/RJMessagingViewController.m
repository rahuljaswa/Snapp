//
//  RJMessagingViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 2/28/15.
//
//

#import "RJCommentCell.h"
#import "RJCoreDataManager.h"
#import "RJManagedObjectPost.h"
#import "RJManagedObjectThread.h"
#import "RJMessagingViewController.h"
#import "RJParseUtils.h"
#import "RJProfileViewController.h"
#import "RJStore.h"
#import "RJStyleManager.h"
#import <ChatViewControllers/RJWriteChatView.h>

static NSString *const kRJMessagingViewControllerCellID = @"RJMessagingViewControllerCellID";


@interface RJMessagingViewController ()

@property (nonatomic, strong, readonly) RJManagedObjectThread *thread;

@property (nonatomic, strong) NSArray *messages;

@end


@implementation RJMessagingViewController

#pragma mark - Private Properties

- (void)setMessages:(NSArray *)messages {
    if (_messages != messages) {
        _messages = messages;
        [self.tableView reloadData];
    }
}

#pragma mark - Public Protocols - RJViewControllerDataSourceProtocol

- (void)fetchData {
    NSArray *unsortedPosts = [self.thread.messages allObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    self.messages = [unsortedPosts sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [RJStore refreshAllMessagesForThread:self.thread completion:^(BOOL success) {
        if (success) {
            [self fetchData];
            [self.tableView reloadData];
        }
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJCommentCell *cell = [[RJCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRJMessagingViewControllerCellID];
    cell.offsetForImageView = NO;
    [cell updateWithMessage:[self.messages objectAtIndex:indexPath.row] blockForSender:^(RJManagedObjectUser *sender) {
        RJProfileViewController *profileViewController = [[RJProfileViewController alloc] initWithUser:sender];
        [[self navigationController] pushViewController:profileViewController animated:YES];
    }];
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static RJCommentCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJCommentCell alloc] initWithFrame:CGRectZero];
        sizingCell.offsetForImageView = NO;
    });
    [sizingCell updateWithMessage:[self.messages objectAtIndex:indexPath.row] blockForSender:nil];
    return [sizingCell sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
}

#pragma mark - Private Instance Methods

- (void)refreshControlTriggered:(UIRefreshControl *)control {
    [self reloadWithCompletion:^(BOOL success) {
        [control endRefreshing];
    }];
}

- (void)sendButtonPressed:(UIButton *)button {
    [[RJParseUtils sharedInstance] insertNewMessage:nil inThread:self.thread remoteSuccess:nil];
    [self fetchData];
    [self.tableView reloadData];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithThread:(RJManagedObjectThread *)thread {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _thread = thread;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[RJParseUtils sharedInstance] markThreadAsRead:self.thread remoteSuccess:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[RJCommentCell class] forCellReuseIdentifier:kRJMessagingViewControllerCellID];
    
    self.title = [self.thread.post.name uppercaseString];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.writeChatView.commentView.font = styleManager.plainTextFont;
    self.writeChatView.sendButton.titleLabel.font = styleManager.boldTextFont;
    [self.writeChatView.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.layer.zPosition = -1;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self fetchData];
    [self reloadWithCompletion:nil];
}

@end
