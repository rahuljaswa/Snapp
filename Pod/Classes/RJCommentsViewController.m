//
//  RJCommentsViewController.m
//  Community
//

#import "RJCommentCell.h"
#import "RJCommentsViewController.h"
#import "RJManagedObjectPost.h"
#import "RJStyleManager.h"
#import <ActionLabel/ActionLabel.h>
#import <ChatViewControllers/RJWriteChatView.h>


@implementation RJCommentsViewController

#pragma mark - Public Properties

- (void)setComments:(NSArray *)comments {
    if (_comments != comments) {
        _comments = comments;
        [self.tableView reloadData];
    }
}

#pragma mark - Private Instance Methods

- (void)sendButtonPressed:(UIButton *)button {
    NSString *text = self.writeChatView.commentView.text;
    if ([text length] > 0) {
        [self.writeChatView reset];
        if ([self.commentsDelegate respondsToSelector:@selector(commentsViewController:didPressSendButtonWithText:)]) {
            [self.commentsDelegate commentsViewController:self didPressSendButtonWithText:text];
        }
    }
}

#pragma mark - Private Protocols - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static RJCommentCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJCommentCell alloc] initWithFrame:CGRectZero];
        sizingCell.offsetForImageView = NO;
    });
    [sizingCell updateWithComment:[self.comments objectAtIndex:indexPath.row] blockForCreator:nil];
    return [sizingCell sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJCommentCell *cell = [[RJCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.offsetForImageView = NO;
    [cell updateWithComment:[self.comments objectAtIndex:indexPath.row] blockForCreator:^(RJManagedObjectUser *creator) {
        if ([self.commentsDelegate respondsToSelector:@selector(commentsViewController:didPressUser:)]) {
            [self.commentsDelegate commentsViewController:self didPressUser:creator];
        }
    }];
    return cell;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithPost:(RJManagedObjectPost *)post {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = [NSLocalizedString(@"Comments", nil) uppercaseString];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.writeChatView.commentView.font = styleManager.plainTextFont;
    self.writeChatView.sendButton.titleLabel.font = styleManager.boldTextFont;
    [self.writeChatView.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

@end
