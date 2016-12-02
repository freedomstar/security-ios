//
//  RsaHelper.h
//  RsaEncryption
//
//  Created by ozgur sahin on 24/01/15.
//

#import <Foundation/Foundation.h>
#import "CryptoUtil.h"
#import "Base64.h"
#import "KeyHelper.h"

@interface RsaHelper : NSObject
@property(strong,nonatomic)NSString* publicTag;
@property(strong,nonatomic)NSString* privateTag;
-(void)createKey;
-(NSString*)getPublicKey;
-(NSString*)getExponent;
-(NSString*)encryptionWith:(NSString*) cipherText;
@end
