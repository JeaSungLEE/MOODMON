//
//  MessagesViewController.h
//  MessagesExtension
//
//  Created by 이재성 on 09/11/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <Messages/Messages.h>
#import "MDNewMoodViewController.h"

@interface MessagesViewController : MSMessagesAppViewController
@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;
- (IBAction)buttonTouchUp:(id)sender;

@end
