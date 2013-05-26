//
//  NSTextField+Utils.m
//  SimplePasswordEvaluator
//
//  Created by Markus Færevaag on 25.05.13.
//  Copyright (c) 2013 Markus Færevaag. All rights reserved.
//

#import "NSTextField+Utils.h"

@implementation NSTextField (Utils)

- (void)formatByBinaryValue:(BOOL)bin
{
    self.stringValue = bin ? @"YES" : @"NO";
    self.textColor = bin ? [NSColor greenColor] : [NSColor redColor];
}

@end
