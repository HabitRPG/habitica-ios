//
//  HRPGInboxChatViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGInboxChatViewController.h"
#import "UIViewController+Markdown.h"
#import "HRPGFlagInformationOverlayView.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"
#import "NSString+Emoji.h"

@interface HRPGInboxChatViewController ()

@property CGFloat viewWidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property id<InboxMessagesDataSourceProtocol> datasource;
@end

@implementation HRPGInboxChatViewController

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasource = [InboxMessagesDataSourceInstantiator instantiateWithOtherUserID: self.userID];
    self.datasource.otherUsername = self.username;
    self.datasource.tableView = self.tableView;
    self.datasource.viewController = self;
    
    self.viewWidth = self.view.frame.size.width;
    
    UINib *nib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChatMessageCell"];
    
    if (self.isPresentedModally) {
        [self.navigationItem setRightBarButtonItems:@[self.doneBarButton] animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.profileBarButton] animated:NO];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.backgroundColor = [ObjcThemeWrapper windowBackgroundColor];
    
    [self.textView registerMarkdownFormattingSymbol:@"**" withTitle:@"Bold"];
    [self.textView registerMarkdownFormattingSymbol:@"*" withTitle:@"Italics"];
    [self.textView registerMarkdownFormattingSymbol:@"~~" withTitle:@"Strike"];

    self.textView.placeholder = objcL10n.writeAMessage;
    self.textInputbar.maxCharCount = [[[ConfigRepository alloc] init] integerWithVariable:ConfigVariableMaxChatLength];
    self.textInputbar.charCountLabelNormalColor = [UIColor gray400];
    self.textInputbar.charCountLabelWarningColor = [UIColor red50];
    self.textInputbar.charCountLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    self.textInputbar.textView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
    self.textInputbar.textView.placeholderColor = ObjcThemeWrapper.dimmedTextColor;
    self.textInputbar.textView.textColor = ObjcThemeWrapper.primaryTextColor;
    
    self.hrpgTopHeaderNavigationController.shouldHideTopHeader = true;
    self.hrpgTopHeaderNavigationController.hideNavbar = false;
}

- (void)setTitleWithUsername:(NSString * _Nullable)displayName {
    if (displayName) {
        self.navigationItem.title = [objcL10n writeToUsername: displayName];
    } else {
        self.navigationItem.title = objcL10n.writeMessage;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] scrollView:self.scrollView scrolledToPosition:0];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    if (self.textView.text.length > (self.textInputbar.maxCharCount * 0.95)) {
        self.textInputbar.charCountLabelNormalColor = [UIColor yellow5];
    } else {
        self.textInputbar.charCountLabelNormalColor = [UIColor gray400];
    }
}

- (void)didPressRightButton:(id)sender {
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    [self.datasource sendMessageWithMessageText:self.textView.text];
    [super didPressRightButton:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        UserProfileViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userID = self.userID;
        userProfileViewController.username = self.displayName;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = true;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = false;
    [super scrollViewDidEndDecelerating:scrollView];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
