//
//  HRPGQuestDetailController.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 08/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestDetailController.h"

@interface HRPGQuestDetailController ()

@end

@implementation HRPGQuestDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger height = 0;
    if (indexPath.section == 0 && indexPath.item == 0) {
        height = [self.quest.text boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                            }
                                               context:nil].size.height + 22;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        height = [self.quest.notes boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                             }
                                                context:nil].size.height - 30;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.item == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
        cell.textLabel.text = self.quest.text;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        NSError *err = nil;
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString stringWithFormat:@"<span style=\"font-family: Helvetica Neue; font-size: %ld\">%@</span>", (long) [[NSNumber numberWithFloat:font.pointSize] integerValue], self.quest.notes];
        label.attributedText = [[NSAttributedString alloc]
                initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                     options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
          documentAttributes:nil
                       error:&err];
    }

    return cell;
}


@end
