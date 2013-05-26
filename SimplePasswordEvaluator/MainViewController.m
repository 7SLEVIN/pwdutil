//
//  MainViewController.m
//  SimplePasswordEvaluator
//
//  Created by Markus Færevaag on 25.05.13.
//  Copyright (c) 2013 Markus Færevaag. All rights reserved.
//

#import "MainViewController.h"
#import "NSTextField+Utils.h"

@interface MainViewController ()
@property (weak) IBOutlet NSTextField *inputField;
@property (weak) IBOutlet NSSecureTextField *secureField;
@property (weak) IBOutlet NSButton *showCheckbox;
@property (weak) IBOutlet NSTextField *qualityField;
@property (weak) IBOutlet NSLevelIndicator *levelIndicator;

@property (weak) IBOutlet NSTextField *containsNumbersLabel;
@property (weak) IBOutlet NSTextField *containsSymbolsLabel;
@property (weak) IBOutlet NSTextField *containsUpperLowerCaseLabel;
@property (weak) IBOutlet NSTextField *combinationsLabel;
@property (weak) IBOutlet NSTextField *lengthLabel;
@property (weak) IBOutlet NSTextField *maxBruteForceLabel;
@property (weak) IBOutlet NSTextField *minBruteForceLabel;

@property NSString *input;
@property double combinations;
@property BOOL containsNumbers;
@property BOOL containsSymbols;
@property BOOL containsUpperLowerCase;

@end

@implementation MainViewController

@synthesize inputField, qualityField, levelIndicator,
showCheckbox, input, containsNumbers, containsSymbols,
containsUpperLowerCase, containsUpperLowerCaseLabel,
combinations, minBruteForceLabel, maxBruteForceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self reset];
    }
    return self;
}
- (void)reset
{
    self.levelIndicator.intValue = 0;
    self.qualityField.stringValue = @"";
    self.containsNumbersLabel.stringValue = @"";
    self.containsSymbolsLabel.stringValue = @"";
    self.combinationsLabel.stringValue = @"";
    self.minBruteForceLabel.stringValue = @"";
    self.maxBruteForceLabel.stringValue = @"";
    self.lengthLabel.stringValue = @"";
}

- (void)updateUI
{
    // Contains
    [self.containsUpperLowerCaseLabel formatByBinaryValue:self.containsUpperLowerCase];
    [self.containsNumbersLabel formatByBinaryValue:self.containsNumbers];
    [self.containsSymbolsLabel formatByBinaryValue:self.containsSymbols];
    
    // Stats
    self.lengthLabel.stringValue = [NSString stringWithFormat:@"%lu",
                                    (unsigned long)self.inputField.stringValue.length];
    self.combinationsLabel.stringValue = [NSString stringWithFormat:@"%.2e", self.combinations];
    
    // Brute force
    NSString *minTime = [self relativeTimeFromSeconds:self.combinations/40000000000.0];
    NSString *maxTime = [self relativeTimeFromSeconds:self.combinations/10000000.0];
    self.minBruteForceLabel.stringValue = minTime;
    self.maxBruteForceLabel.stringValue = maxTime;
    
    // Quality
    NSArray *qualities = @[@"Horrible", @"Bad", @"Fair", @"Good", @"Excellent"];
    if ([minTime rangeOfString:@"years"].location != NSNotFound) {
        self.levelIndicator.intValue = 5;
        self.qualityField.stringValue = qualities[4];
    } else if ([minTime rangeOfString:@"months"].location != NSNotFound) {
        self.levelIndicator.intValue = 4;
        self.qualityField.stringValue = qualities[3];
    } else if ([minTime rangeOfString:@"days"].location != NSNotFound) {
        self.levelIndicator.intValue = 3;
        self.qualityField.stringValue = qualities[2];
    } else if ([minTime rangeOfString:@"hours"].location != NSNotFound) {
        self.levelIndicator.intValue = 2;
        self.qualityField.stringValue = qualities[1];
    } else {
        self.levelIndicator.intValue = 1;
        self.qualityField.stringValue = qualities[0];
    }
}

- (NSString *)relativeTimeFromSeconds:(double)seconds
{
    if (seconds < 1) {
        return [NSString stringWithFormat:@"Instantly"];
    } else if (seconds < 60) {
        return [NSString stringWithFormat:@"%.2f seconds", seconds];
    } else if (seconds < 3600) {
        return [NSString stringWithFormat:@"%.2f minutes", seconds/60];
    } else if (seconds < 86400) {
        return [NSString stringWithFormat:@"%.2f hours", seconds/3600];
    } else if (seconds < 2592000) {
        return [NSString stringWithFormat:@"%.2f days", seconds/86400];
    } else if (seconds < 31104000) {
        return [NSString stringWithFormat:@"%.2f months", seconds/2592000];
    } else {
        return [NSString stringWithFormat:@"%.2f years", seconds/2592000];
    }
    return nil;
}

// Show / hide text
- (IBAction)showChanged:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        [self.inputField setHidden:NO];
        [self.secureField setHidden:YES];
        self.inputField.stringValue = self.input;
        [self.inputField becomeFirstResponder];
        [[self.inputField currentEditor] moveToEndOfLine:nil];
    } else {
        [self.inputField setHidden:YES];
        [self.secureField setHidden:NO];
        self.secureField.stringValue = self.input;
        [self.secureField becomeFirstResponder];
        [[self.secureField currentEditor] moveToEndOfLine:nil];
    }
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    self.input = [[obj object] stringValue];
    
    if (self.input.length < 1) {
        [self reset];
        return;
    }
    
    [self eval];
}

- (void)eval
{
    NSUInteger possible = 0;
    NSUInteger length = self.input.length;
    
    // Contains letters
    BOOL lower = NO;
    BOOL upper = NO;
    if ([self.input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"]].location != NSNotFound) {
        possible += 26;
        lower = YES;
    }
    if ([self.input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"]].location != NSNotFound) {
        possible += 26;
        upper = YES;
    }
    self.containsUpperLowerCase = (lower && upper) ? YES : NO;

    // Contains numbers
    if ([self.input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890"]].location != NSNotFound) {
        possible += 10;
        self.containsNumbers = YES;
    } else {
        self.containsNumbers = NO;
    }
    
    // Contains symbols
    if ([self.input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"!\"#$%&'()*+,-./:;<=?@[\\]^_`{|}~"]].location != NSNotFound) {
        possible += 32;
        self.containsSymbols = YES;
    } else {
        self.containsSymbols = NO;
    }

    // Calculate
    self.combinations = pow(possible, length);

    // Update view
    [self updateUI];
}


@end
