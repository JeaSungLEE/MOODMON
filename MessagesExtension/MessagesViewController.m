//
//  MessagesViewController.m
//  MessagesExtension
//
//  Created by 이재성 on 09/11/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MessagesViewController.h"



@interface MessagesViewController ()

@end

@implementation MessagesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    //imessage뷰가 크기가 바뀔때 불러지는 메서드에서
    //compact는 imessage가 작아질때 expanded는 커질때 VC전환시키기
    if(presentationStyle == MSMessagesAppPresentationStyleCompact){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(presentationStyle == MSMessagesAppPresentationStyleExpanded){
        MDMakeMoodViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"newMoodmonVC"];
        [VC setDelegate:self];
        //델리게이트로 메세지 값 받아옴.
        [self presentViewController:VC animated:YES completion:nil];
    }
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {

}

- (IBAction)buttonTouchUp:(id)sender {
    [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
}


-(void)setLayout:(MSMessageTemplateLayout *)layout{
    //IMessage 레이아웃 잡는부분
    MSConversation *conversation = [self activeConversation];
    MSMessage *message = [[MSMessage alloc]init];
    message.layout = layout;
    [conversation insertMessage:message completionHandler:nil];
    [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
}
@end
