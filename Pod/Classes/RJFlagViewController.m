//
//  RJFlagViewController.m
//  Community
//

#import "RJFlagViewController.h"
#import "RJManagedObjectFlag.h"
#import "RJStyleManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kRJFlagViewControllerCellID = @"RJFlagViewControllerCellID";

typedef NS_ENUM(NSUInteger, FlagSection) {
    kFlagSectionDontLike,
    kFlagSectionScamSpam,
    kFlagSectionRisk,
    kFlagSectionInappropriate,
    kFlagSectionIntellectualProperty,
    kNumFlagSections
};

typedef NS_ENUM(NSUInteger, InappropriateRow) {
    kInappropriateRowIllegal,
    kInappropriateRowViolent,
    kInappropriateRowPornographic,
    kInappropriateRowHateful,
    kNumInappropriateRows
};

typedef NS_ENUM(NSUInteger, RiskRow) {
    kRiskRowSelfHarm,
    kRiskRowHarassment,
    kRiskRowPrivacy,
    kNumRiskRows
};


@implementation RJFlagViewController

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumFlagSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfRows = 0;
    
    FlagSection flagSection = section;
    switch (flagSection) {
        case kFlagSectionDontLike:
            numberOfRows = 1;
            break;
        case kFlagSectionScamSpam:
            numberOfRows = 1;
            break;
        case kFlagSectionRisk:
            numberOfRows = kNumRiskRows;
            break;
        case kFlagSectionInappropriate:
            numberOfRows = kNumInappropriateRows;
            break;
        case kFlagSectionIntellectualProperty:
            numberOfRows = 1;
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJFlagViewControllerCellID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    
    FlagSection flagSection = section;
    switch (flagSection) {
        case kFlagSectionDontLike:
            title = NSLocalizedString(@"I don't like this post", nil);
            break;
        case kFlagSectionScamSpam:
            title = NSLocalizedString(@"Spam", nil);;
            break;
        case kFlagSectionRisk:
            title = NSLocalizedString(@"Risk to poster or others", nil);
            break;
        case kFlagSectionInappropriate:
            title = NSLocalizedString(@"Inappropriate content", nil);
            break;
        case kFlagSectionIntellectualProperty:
            title = NSLocalizedString(@"Intellectual property", nil);;
            break;
        default:
            break;
    }
    
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFlagSectionDontLike) {
        return;
    }

    RJManagedObjectFlagReason flagReason;
    
    FlagSection flagSection = indexPath.section;
    switch (flagSection) {
        case kFlagSectionDontLike:
            break;
        case kFlagSectionScamSpam:
            flagReason = RJManagedObjectFlagReasonSpamScam;
            break;
        case kFlagSectionRisk: {
            RiskRow riskRow = indexPath.row;
            switch (riskRow) {
                case kRiskRowSelfHarm:
                    flagReason = RJManagedObjectFlagReasonSelfHarm;
                    break;
                case kRiskRowHarassment:
                    flagReason = RJManagedObjectFlagReasonHarassment;
                    break;
                case kRiskRowPrivacy:
                    flagReason = RJManagedObjectFlagReasonPrivacy;
                    break;
                default:
                    break;
            }
            break;
        }
        case kFlagSectionInappropriate: {
            InappropriateRow inappropriateRow = indexPath.row;
            switch (inappropriateRow) {
                case kInappropriateRowIllegal:
                    flagReason = RJManagedObjectFlagReasonIllegal;
                    break;
                case kInappropriateRowViolent:
                    flagReason = RJManagedObjectFlagReasonViolent;
                    break;
                case kInappropriateRowPornographic:
                    flagReason = RJManagedObjectFlagReasonPornography;
                    break;
                case kInappropriateRowHateful:
                    flagReason = RJManagedObjectFlagReasonHateful;
                    break;
                default:
                    break;
            }
            break;
        }
        case kFlagSectionIntellectualProperty:
            flagReason = RJManagedObjectFlagReasonIntellectualProperty;
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(flagViewController:didSelectReason:)]) {
        [self.delegate flagViewController:self didSelectReason:flagReason];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static UITableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGFLOAT_MAX);
        sizingCell = [[UITableViewCell alloc] initWithFrame:frame];
    });
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    [sizingCell layoutIfNeeded];
    
    CGFloat labelHeight = [sizingCell.textLabel sizeThatFits:CGSizeMake(CGRectGetWidth(sizingCell.textLabel.bounds), CGFLOAT_MAX)].height;
    CGFloat verticalPadding =  20.0f;
    
    return (labelHeight + verticalPadding);
}

#pragma mark - Private Instance Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosureIndicator"]];
    
    FlagSection flagSection = indexPath.section;
    switch (flagSection) {
        case kFlagSectionDontLike:
            cell.textLabel.text = NSLocalizedString(@"You can block users and prevent their posts from showing up in your feed by visiting their profile and clicking the \"Block User\" button", nil);
            cell.accessoryView = nil;
            break;
        case kFlagSectionScamSpam:
            cell.textLabel.text = NSLocalizedString(@"Spam or a scam and is not useful to the community", nil);
            cell.accessoryView = disclosureIndicator;
            break;
        case kFlagSectionRisk: {
            RiskRow riskRow = indexPath.row;
            switch (riskRow) {
                case kRiskRowSelfHarm:
                    cell.textLabel.text = NSLocalizedString(@"Contains or suggests self-harm (suicidal behavior, anorexia, etc.)", nil);
                    cell.accessoryView = disclosureIndicator;
                    break;
                case kRiskRowHarassment:
                    cell.textLabel.text = NSLocalizedString(@"Contains harrassing or bullying content", nil);
                    cell.accessoryView = disclosureIndicator;
                    break;
                case kRiskRowPrivacy:
                    cell.textLabel.text = NSLocalizedString(@"Violates physical, intellectual or emotional privacy", nil);
                    cell.accessoryView = disclosureIndicator;
                    break;
                default:
                    break;
            }
            break;
        }
        case kFlagSectionInappropriate: {
            InappropriateRow inappropriateRow = indexPath.row;
            switch (inappropriateRow) {
                case kInappropriateRowIllegal:
                    cell.textLabel.text = NSLocalizedString(@"Displays illegal behavior (e.g. drug usage)", nil);
                    
                    break;
                case kInappropriateRowViolent:
                    cell.textLabel.text = NSLocalizedString(@"Displays or promotes violence", nil);
                    cell.accessoryView = disclosureIndicator;
                    break;
                case kInappropriateRowPornographic:
                    cell.textLabel.text = NSLocalizedString(@"Contains pornographic material", nil);
                    break;
                case kInappropriateRowHateful:
                    cell.textLabel.text = NSLocalizedString(@"Contains hateful language or imagery", nil);
                    break;
                default:
                    break;
            }
            break;
        }
        case kFlagSectionIntellectualProperty:
            cell.textLabel.text = NSLocalizedString(@"Violates intellectual property of another person or entity", nil);
            break;
        default:
            break;
    }
    
    cell.textLabel.font = [[RJStyleManager sharedInstance] plainTextFont];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    
    if (indexPath.section == kFlagSectionDontLike) {
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryView = disclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithPost:(RJManagedObjectPost *)post {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJFlagViewControllerCellID];
    self.title = [NSLocalizedString(@"Flag Post", nil) uppercaseString];
}

@end
