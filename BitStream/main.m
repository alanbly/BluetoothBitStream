//
//  main.m
//  BitStream
//
//  Created by Adam Woods-McCormick on 5/30/15.
//  Copyright (c) 2015 Rampant Stag Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bluetooth.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Bluetooth *bluetooth = [[Bluetooth alloc] init];
        [bluetooth start];
    }
    return 0;
}
