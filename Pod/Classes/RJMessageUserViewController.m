//
//  RJMessageUserViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 3/1/15.
//
//

#import "RJManagedObjectPost.h"
#import "RJMessageUserViewController.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import <SZTextView/SZTextView.h>


@interface RJMessageUserViewController () <UITextViewDelegate>

@property (nonatomic, strong, readonly) SZTextView *textView;

@end


@implementation RJMessageUserViewController

@synthesize post = _post;
@synthesize textView = _textView;

#pragma mark - Public Properties

- (NSString *)text {
    return self.textView.text;
}

#pragma mark - Private Properties

- (SZTextView *)textView {
    if (!_textView) {
        _textView = [[SZTextView alloc] initWithFrame:CGRectZero];
        _textView.delegate = self;
        _textView.font = [[RJStyleManager sharedInstance] plainTextFont];
        _textView.tintColor = [[RJStyleManager sharedInstance] tintBlueColor];
        _textView.placeholder = NSLocalizedString(@"Send a message", nil);
    }
    return _textView;
}

#pragma mark - Private Instance Methods

- (void)doneButtonPressed:(UIButton *)button {
    [[RJParseUtils sharedInstance] createNewThreadForPost:self.post
                                           initialMessage:self.text
                                            remoteSuccess:nil];
    if ([self.delegate respondsToSelector:@selector(messageUserViewControllerDidPressDoneButton:)]) {
        [self.delegate messageUserViewControllerDidPressDoneButton:self];
    }
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardFrame;
    [keyboardInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    self.textView.textContainerInset = UIEdgeInsetsMake(20.0f, 10.0f, CGRectGetHeight(keyboardFrame) + 20.0f, 10.0f);
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPost:(RJManagedObjectPost *)post {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIView *textView = self.textView;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:textView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(textView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (![self.textView isFirstResponder]) {
        [self.textView becomeFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Re: %@", nil), self.post.name];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createButton"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:done animated:NO];
}

@end
