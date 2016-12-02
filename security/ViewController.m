//
//  ViewController.m
//  security
//
//  Created by 辉仔 on 2016/11/25.
//  Copyright © 2016年 辉仔. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import <Security/Security.h>
#import "RsaHelper.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *TextField;
@property (weak, nonatomic) IBOutlet UILabel *concent;
@property(strong,nonatomic)RsaHelper* rsaHelper;
@property(strong,nonatomic) NSString* aesKey;
@property(strong,nonatomic) NSString* aesIv;
@property(strong,nonatomic)  GCDAsyncSocket * asyncSocket;
@property BOOL isRsaVerify;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isRsaVerify=false;
    
    //创建rsa加密／解密对象
    self.rsaHelper=[[RsaHelper alloc]init];
    [self.rsaHelper createKey];
    [self registerForKeyboardNotifications];
    
    //创建socket对象并连接服务器
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.asyncSocket.delegate=self;
    [self.asyncSocket connectToHost:self.ip onPort:[self.port integerValue] error:nil];
    [self.asyncSocket readDataWithTimeout:1000 tag:0];
    
    //向服务器发送rsa公钥
    NSString* publicKey=[[NSString alloc]initWithFormat:@"<RSAKeyValue><Modulus>%@</Modulus><Exponent>%@</Exponent></RSAKeyValue>",[self.rsaHelper getPublicKey],[self.rsaHelper getExponent]];
    NSData* publicKeyData=[publicKey dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:publicKeyData withTimeout:5 tag:0];
}

//发送按钮监听
- (IBAction)send:(id)sender
{
    if (![self.TextField.text isEqual:@""])
    {
        NSData* concentTextData=[self.TextField.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSData* encryptedData=[RNEncryptor encryptData:concentTextData withSettings:kRNCryptorAES256Settings password:self.aesKey error:&error];
        [self.asyncSocket writeData:encryptedData withTimeout:5 tag:0];
        NSLog(@"%@",[encryptedData base64EncodedString]);
    }
}


//退出编辑
- (IBAction)exitEdit:(id)sender
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 键盘事件
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomLayoutConstraint.constant=kbSize.height;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.bottomLayoutConstraint.constant=0;
}



#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* cipherText=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.isRsaVerify==false)
    {
        //接收加密过的aes密钥并解密记录下来
        self.aesKey=[self.rsaHelper encryptionWith:cipherText];
        self.isRsaVerify=true;
        [self.asyncSocket readDataWithTimeout:1000 tag:0];
        self.concent.text=[self.concent.text stringByAppendingString:@" \n链接成功"];
    }
    else
    {
        //解密aes的加密信息并显示出来
        NSError *error;
        NSData*   decryptData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:self.aesKey error:&error];
        NSString* message=[[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding];
        self.concent.text=[self.concent.text stringByAppendingFormat:@" \n%@", message];
        [self.asyncSocket readDataWithTimeout:1000 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.concent sizeToFit];
    [self.concent layoutIfNeeded];
}




@end
