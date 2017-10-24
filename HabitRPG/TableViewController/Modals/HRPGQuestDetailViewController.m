//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGQuestDetailViewController.h"
#import "YYWebImage.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGQuestDetailViewController ()
@property UIImage *bossImage;
@property BOOL hasResponded;
@end

@implementation HRPGQuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.group.questKey != nil && ![self.group.questActive boolValue] &&
        self.user.participateInQuest == nil) {
        self.navigationItem.title = NSLocalizedString(@"Quest Invitation", nil);
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.title = NSLocalizedString(@"Quest Detail", nil);
        if ([self.group.questActive boolValue] &&
            [self.group.questLeader isEqualToString:self.user.id]) {
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Abort", nil);
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor red100];
        } else if ([self.group.questActive boolValue] ||
                   ![self.group.questLeader isEqualToString:self.user.id]) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

#pragma mark - Table view data source

- (BOOL)shouldShowResponseOptions {
    return (![self.isWorldQuest boolValue]) && self.group.questKey != nil &&
    ![self.group.questActive boolValue] && self.user.participateInQuest == nil && !self.hasResponded;
}

- (int)questDetailSection {
    return [self shouldShowResponseOptions] ? 1 : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self shouldShowResponseOptions]) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [self shouldShowResponseOptions]) {
        if ([self.hideAskLater boolValue]) {
            return 2;
        }
        return 3;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int questDetailSection = [self questDetailSection];
    if (indexPath.section == questDetailSection && indexPath.item == 0) {
        return [self.quest.text boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                              NSFontAttributeName : [UIFont
                                                  preferredFontForTextStyle:UIFontTextStyleHeadline]
                                          }
                                             context:nil]
                   .size.height +
               16;
    } else if (indexPath.section == questDetailSection && indexPath.item == 1) {
        if (self.bossImage.size.width*2 > self.viewWidth) {
            return ((self.viewWidth-20)/self.bossImage.size.width) * self.bossImage.size.height;
        } else {
            return self.bossImage.size.height*2;
        }
    } else if (indexPath.section == questDetailSection && indexPath.item == 2) {
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString
            stringWithFormat:
                @"<span style=\"font-family: Helvetica Neue; font-size: %ld;margin:0\">%@</span>",
                (long)[@(font.pointSize) integerValue], self.quest.notes];
        NSError *err;
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                  initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                       options:@{
                           NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType
                       }
            documentAttributes:nil
                         error:&err];
        return ceilf([attributedText boundingRectWithSize:CGSizeMake(300.0f, CGFLOAT_MAX)
                                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                                           NSStringDrawingUsesFontLeading)
                                                  context:nil]
                         .size.height) +
               60;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != [self questDetailSection]) {
        if (indexPath.section == 0 && indexPath.item == 0) {
            [[HRPGManager sharedManager] acceptQuest:self.group.id
                                  onSuccess:^() {
                                      self.hasResponded = YES;
                                      if (self.wasPushed) {
                                          [self.tableView reloadData];
                                      } else {
                                          [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  } onError:nil];
        } else if (indexPath.section == 0 && indexPath.item == 1) {
            [[HRPGManager sharedManager] rejectQuest:self.group.id
                                  onSuccess:^() {
                                      self.hasResponded = YES;
                                      if (self.wasPushed) {
                                          [self.tableView reloadData];
                                      } else {
                                          [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  } onError:nil];
        } else if (indexPath.section == 0 && indexPath.item == 2) {
            [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    if (indexPath.section == [self questDetailSection] && indexPath.item == 0) {
        cellIdentifier = @"titleCell";
    } else if (indexPath.section == [self questDetailSection] && indexPath.item == 1) {
        cellIdentifier = @"bossImageCell";
    } else if (indexPath.section == [self questDetailSection] && indexPath.item == 2) {
        cellIdentifier = @"descriptionCell";
    } else if (indexPath.section == 0 && indexPath.item == 0) {
        cellIdentifier = @"acceptCell";
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        cellIdentifier = @"rejectCell";
    } else if (indexPath.section == 0 && indexPath.item == 2) {
        cellIdentifier = @"asklaterCell";
    } else {
        cellIdentifier = @"titleCell";
    }

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (indexPath.section == [self questDetailSection] && indexPath.item == 0) {
        cell.textLabel.text = self.quest.text;
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else if (indexPath.section == [self questDetailSection] && indexPath.item == 1) {
        if (self.bossImage) {
            UIImageView *imageView = [cell viewWithTag:1];
            imageView.image = self.bossImage;

        } else {
            YYWebImageManager *manager = [YYWebImageManager sharedManager];
            __weak UIImageView *imageView = [cell viewWithTag:1];
            __weak HRPGQuestDetailViewController *weakSelf = self;
            [manager
                requestImageWithURL:[NSURL URLWithString:[NSString
                                                             stringWithFormat:@"https://"
                                                                              @"habitica-assets."
                                                                              @"s3.amazonaws.com/"
                                                                              @"mobileApp/images/"
                                                                              @"quest_%@.png",
                                                                              self.quest.key]]
                            options:0
                           progress:nil
                          transform:nil
                         completion:^(UIImage *_Nullable image, NSURL *_Nonnull url,
                                      YYWebImageFromType from, YYWebImageStage stage,
                                      NSError *_Nullable error) {
                             if (image) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     weakSelf.bossImage = image;
                                     imageView.image = weakSelf.bossImage;
                                     NSIndexPath *newIndexPath = indexPath;
                                     if ([weakSelf.tableView numberOfSections] <= indexPath.section) {
                                         newIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section-1];
                                     }
                                     [weakSelf.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                 });
                             }
                         }];
        }
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else if (indexPath.section == [self questDetailSection] && indexPath.item == 2) {
        UITextView *textView = [cell viewWithTag:1];
        NSError *err = nil;
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString
            stringWithFormat:
                @"<span style=\"font-family: Helvetica Neue; font-size: %ld;margin:0\">%@</span>",
                (long)[@(font.pointSize) integerValue], self.quest.notes];
        textView.attributedText = [[NSAttributedString alloc]
                  initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                       options:@{
                           NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                           NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)
                       }
            documentAttributes:nil
                         error:&err];
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    }
    return cell;
}

- (IBAction)forceQuestBegin:(id)sender {
    NSString *message;
    if ([self.group.questActive boolValue]) {
        message = NSLocalizedString(@"When you abort a quest, all progress will be lost and the "
                                    @"quest scroll will be put back into your inventory.",
                                    nil);
    } else {
        message = NSLocalizedString(
            @"Once a quest is started, no other party members can join the quest.", nil);
    }
    
    HabiticaAlertController *alertController = [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Are you sure?", nil) message:nil];
    [alertController addActionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel isMainAction:NO handler:nil];
    [alertController addActionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault isMainAction:YES handler:^(UIButton * _Nonnull button) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        __weak HRPGQuestDetailViewController *weakSelf = self;
        if ([self.group.questActive boolValue]) {
            [[HRPGManager sharedManager] abortQuest:self.group.id
                                          onSuccess:^() {
                                              [weakSelf.navigationController popViewControllerAnimated:YES];
                                          }
                                            onError:^(NSString *errorMessage) {
                                                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                            }];
        } else {
            [[HRPGManager sharedManager] forceStartQuest:self.group.id
                                               onSuccess:^() {
                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                               }
                                                 onError:^(NSString *errorMessage) {
                                                     weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                                 }];
        }
    }];
    
    [alertController show];
}

@end
