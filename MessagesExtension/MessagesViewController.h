//
//  MessagesViewController.h
//  MessagesExtension
//
//  Created by 이재성 on 09/11/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <Messages/Messages.h>
#import "MDMakeMoodViewController.h"

@interface MessagesViewController : MSMessagesAppViewController <MDMessageDelegate>

@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;
- (IBAction)buttonTouchUp:(id)sender;
- (void)setLayout:(MSMessageTemplateLayout *)layout;

@end
