//
//  DNEvernoteUtil.m
//  ReaderStore
//
//  Created by HUANG CHEN CHERNG on 14/4/3.
//  Copyright (c) 2014年 DrawNews. All rights reserved.
//
//  DrawNews:
//      https://itunes.apple.com/us/app/drawnews-gtd-designed-rss/id695442462?mt=8
//

#import "TFHpple.h"
#import "NSString+HTML.h"
#import "CTidy.h"
#import "DNEvernoteUtil.h"

#define DN_DBG 0

@implementation DNEvernoteUtil

+ (DNEvernoteUtil*)sharedClient
{
    static DNEvernoteUtil* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DNEvernoteUtil alloc] init];
    });
    return _sharedClient;
}

//
//  instance APIs
//

- (DNEvernoteUtil*) init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    return self;
}

- (NSString*)convertToENML:(NSString*)html
{
    NSMutableDictionary* dumpedDict = [NSMutableDictionary new];

    NSError* error;
    NSString* xhtml = [[CTidy tidy] tidyHTMLString:html
                                          encoding:@"UTF8"
                                             error:&error];
    #if DN_DBG
    NSLog(@"xhtml:%@",xhtml);
    #endif

    // 1
    NSData *htmlData = [xhtml dataUsingEncoding:NSUTF8StringEncoding];

    // 2
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];

    // 3
    NSString *tutorialsXpathQueryString = @"//*";
    NSArray *elemArr = [parser searchWithXPathQuery:tutorialsXpathQueryString];

    // 4
    NSMutableString *enml = [NSMutableString new];
    [enml appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"];
    [enml appendFormat:@"<en-note>"];

    int num = [elemArr count];
    for (int i=0;i<num;i++) {
        TFHppleElement* element = [elemArr objectAtIndex:i];
        #if DN_DBG
        NSLog(@"element tag name(%d):%@",i,element.tagName);
        #endif
        [self __travHtmlNode:element withENML:enml withDumpedDict:dumpedDict];
    }

    [enml appendFormat:@"</en-note>"];
    return enml;
}

- (void)__travHtmlNode:(TFHppleElement*)element withENML:(NSMutableString*)enml withDumpedDict:(NSMutableDictionary*)dumpedDict
{
    if ([element.tagName isEqualToString:@"p"]) {
        NSArray* arr = [element children];
        [enml appendFormat:@"<p>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</p>"];
    }
    else if ([element.tagName isEqualToString:@"br"]) {
        #if DN_DBG
        NSLog(@"    br:%@",[[element firstChild] content]);
        #endif
        [enml appendFormat:@"<br></br>"];
    }
    else if ([element.tagName isEqualToString:@"strong"]) {
        #if DN_DBG
        NSLog(@"    strong:%@",[[element firstChild] content]);
        #endif
        [enml appendFormat:@"<strong>"];
        NSArray* arr = [element children];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</strong>"];
    }
    else if ([element.tagName isEqualToString:@"h1"]) {
        #if DN_DBG
        NSLog(@"    h1:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h1>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h1>"];
    }
    else if ([element.tagName isEqualToString:@"h2"]) {
        #if DN_DBG
        NSLog(@"    h2:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h2>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h2>"];
    }
    else if ([element.tagName isEqualToString:@"h3"]) {
        #if DN_DBG
        NSLog(@"    h3:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h3>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h3>"];
    }
    else if ([element.tagName isEqualToString:@"h4"]) {
        #if DN_DBG
        NSLog(@"    h4:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h4>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h4>"];
    }
    else if ([element.tagName isEqualToString:@"h5"]) {
        #if DN_DBG
        NSLog(@"    h5:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h5>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h5>"];
    }
    else if ([element.tagName isEqualToString:@"h6"]) {
        #if DN_DBG
        NSLog(@"    h6:%@",[[element firstChild] content]);
        #endif
        NSArray* arr = [element children];
        [enml appendFormat:@"<h6>"];
        for ( TFHppleElement *subElem in arr ) {
            [self __travHtmlNode:subElem withENML:enml withDumpedDict:dumpedDict];
        }
        [enml appendFormat:@"</h6>"];
    }
    else
    {
        [self __travHtmlLeaf:element withENML:enml withDumpedDict:dumpedDict];
    }
}

- (void)__travHtmlLeaf:(TFHppleElement*)element withENML:(NSMutableString*)enml withDumpedDict:(NSMutableDictionary*)dict
{
    if ([element.tagName isEqualToString:@"a"]) {
        #if DN_DBG
        NSLog(@"    href:%@",[element objectForKey:@"href"]);
        NSLog(@"    text:%@",[[element firstChild] content]);
        #endif
        NSString* lnk = [[element objectForKey:@"href"] stringByEncodingHTMLEntities];

        if (!lnk||[dict objectForKey:lnk]||[lnk rangeOfString:@"http"].location==NSNotFound) {
            return;
        }

        if ( [[element firstChild] content] ) {

            [enml appendFormat:@"<a href=\"%@\" target=\"_blank\">%@</a>",lnk,[[element firstChild] content]];
        }
        else
        {
            [enml appendFormat:@"<a href=\"%@\" target=\"_blank\"></a>",lnk];
        }
        [dict setObject:lnk forKey:lnk];
    }
    else if ([element.tagName isEqualToString:@"img"]) {
        #if DN_DBG
        NSLog(@"    src:%@",[element objectForKey:@"src"]);
        NSLog(@"    alt:%@",[element objectForKey:@"alt"]);
        #endif
        NSString* src = [[element objectForKey:@"src"] stringByEncodingHTMLEntities];

        if (!src||[dict objectForKey:src]||[src rangeOfString:@"http"].location==NSNotFound) {
            return;
        }

        if ( [element objectForKey:@"alt"] ) {
            [enml appendFormat:@"<img src=\"%@\" alt=\"%@\"></img>",src,[element objectForKey:@"alt"]];
        }
        else
        {
            [enml appendFormat:@"<img src=\"%@\"></img>",src];
        }
        [dict setObject:src forKey:src];
    }
    else if ([element.tagName isEqualToString:@"text"]) {
        #if DN_DBG
        NSLog(@"    text:%@",[element content]);
        #endif
        NSString* text = [element content];
        if (!text||[dict objectForKey:text]) {
            return;
        }
        [enml appendFormat:@"%@",text];
        [dict setObject:text forKey:text];
    }
}

@end
