//
//  RJCreateSkeletonUserViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 4/23/15.
//
//

#import "RJCreateSkeletonUserViewController.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface RJCreateSkeletonUserViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextField *textField;

@end


@implementation RJCreateSkeletonUserViewController

#pragma mark - Private Protocols - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Instance Methods

- (void)buttonPressed:(UIButton *)button {
    if (self.textField.text && self.imageView.image) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Creating user...", nil)];
        [[RJParseUtils sharedInstance] createNewUserWithName:self.textField.text image:self.imageView.image remoteSuccess:^(BOOL succeeded) {
            self.textField.text = nil;
            self.imageView.image = nil;
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
            if (succeeded && [self.delegate respondsToSelector:@selector(createSkeletonUserViewControllerDidCreateUser:)]) {
                [self.delegate createSkeletonUserViewControllerDidCreateUser:self];
            }
        }];
    } else {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Image and name required", nil)];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Public Instance Methods

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIView *button = self.button;
    UIView *imageView = self.imageView;
    UIView *textField = self.textField;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];
    [self.view addSubview:imageView];
    [self.view addSubview:textField];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(button, textField, imageView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[textField]-40-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[imageView(50)]-40-[textField(40)]-40-[button(40)]" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:imageView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:button
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _button.clipsToBounds = YES;
        _button.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 15.0f, 10.0f, 15.0f);
        _button.layer.borderColor = [UIColor whiteColor].CGColor;
        _button.layer.cornerRadius = 5.0f;
        _button.layer.borderWidth = 2.0f;
        [_button setTitle:NSLocalizedString(@"Create User", nil) forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitleColor:styleManager.themeColor forState:UIControlStateHighlighted];
        [_button setBackgroundImage:[UIImage imageWithColor:styleManager.themeColor] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _imageView.layer.cornerRadius = 5.0f;
        _imageView.layer.borderWidth = 2.0f;
        
        UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [_imageView addGestureRecognizer:recognizer];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.rightViewMode = UITextFieldViewModeAlways;
        _textField.tintColor = [UIColor whiteColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.layer.borderColor = [UIColor whiteColor].CGColor;
        _textField.layer.cornerRadius = 5.0f;
        _textField.layer.borderWidth = 2.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[RJStyleManager sharedInstance] themeColor];
    self.title = [NSLocalizedString(@"Create User", nil) uppercaseString];
}

@end
