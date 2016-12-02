//
//  NSData+AES256.h
//  security
//
//  Created by 辉仔 on 2016/11/28.
//  Copyright © 2016年 辉仔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
