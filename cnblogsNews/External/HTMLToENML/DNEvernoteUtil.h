//
//  DNEvernoteUtil.h
//  ReaderStore
//
//  Created by HUANG CHEN CHERNG on 14/4/3.
//  Copyright (c) 2014年 DrawNews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNEvernoteUtil : NSObject

+ (DNEvernoteUtil *)sharedClient;

- (NSString*) convertToENML:(NSString*)html;

@end
