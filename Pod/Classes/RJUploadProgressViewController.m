//
//  RJUploadProgressViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 3/21/15.
//
//

#import "RJUploadProgressCell.h"
#import "RJUploadProgressViewController.h"

static NSString *const kRJUploadProgressCellID = @"RJUploadProgressCellID";


@interface RJUploadProgressViewController ()

@end


@implementation RJUploadProgressViewController

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJUploadProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJUploadProgressCellID forIndexPath:indexPath];
    return cell;
}

#pragma mark - Public Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[RJUploadProgressCell class] forCellReuseIdentifier:kRJUploadProgressCellID];
}

@end
