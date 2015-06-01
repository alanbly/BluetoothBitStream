//
//  Bluetooth.h
//  BlueVid
//
//  Created by Adam Woods-McCormick on 5/26/15.
//  Copyright (c) 2015 Rampant Stag Software. All rights reserved.
//

#ifndef BlueVid_Bluetooth_h
#define BlueVid_Bluetooth_h

#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>

@interface Bluetooth : NSObject

- (BOOL) start;
- (void) stop;
- (void) newRFCOMMChannelOpened:(IOBluetoothUserNotification*)inNotification channel:(IOBluetoothRFCOMMChannel*)newChannel;
- (void) rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel;
- (void) rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
- (void) disconnect;
- (void) send:(char*)dataPointer length:(size_t)dataLength;


@end

#endif
