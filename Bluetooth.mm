//
//  Bluetooth.h
//  BlueVid
//
//  Created by Adam Woods-McCormick on 5/26/15.
//  Copyright (c) 2015 Rampant Stag Software. All rights reserved.
//

#import "Bluetooth.h"
#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>

@implementation Bluetooth

NSString *mPath;
BluetoothRFCOMMChannelID *mServerChannelID;
BluetoothSDPServiceRecordHandle *mServerHandle;
IOBluetoothUserNotification *mIncomingChannelNotification;
IOBluetoothRFCOMMChannel *mChannel;
NSString *mListener;

-(BOOL) start
{
    NSString* dictionaryPath = mPath;
    NSMutableDictionary* sdpEntries = [NSMutableDictionary dictionaryWithContentsOfFile:dictionaryPath];
    
    if (sdpEntries != nil)
    {
        [sdpEntries setObject:@"My Service" forKey:@"0100 - ServiceName*"];
        
        IOBluetoothSDPServiceRecord* serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:sdpEntries];
        [serviceRecord getRFCOMMChannelID:mServerChannelID];
        [serviceRecord getServiceRecordHandle:mServerHandle];

        mIncomingChannelNotification = [IOBluetoothRFCOMMChannel
                                        registerForChannelOpenNotifications:self
                                        selector:@selector(newRFCOMMChannelOpened:channel:)
                                        withChannelID:*mServerChannelID
                                        direction:kIOBluetoothUserNotificationChannelDirectionIncoming];
        return TRUE;
    }
    return FALSE;
}


-(void) stop
{
    if (mServerHandle != 0)
    {
        IOBluetoothRemoveServiceWithRecordHandle(*mServerHandle);
    }
    
    if (mIncomingChannelNotification != nil)
    {
        [mIncomingChannelNotification unregister];
        mIncomingChannelNotification = nil;
    }
    
    mServerChannelID = 0;
}


-(void) newRFCOMMChannelOpened:(IOBluetoothUserNotification*)inNotification channel:(IOBluetoothRFCOMMChannel*)newChannel
{
    if (newChannel != nil && [newChannel isIncoming] && [newChannel getChannelID] == *mServerChannelID)
    {
        mChannel = newChannel;
//        [mChannel retain];

        if ( [mChannel setDelegate:self] == kIOReturnSuccess )
        {
            if (mListener != nil)
            {
                NSLog(@"newRFCOMMChannelOpened -> onConnected");
            }
        }
        else
        {
//            [mChannel release];
            mChannel = nil;
        }
    }
}


- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel;
{
    NSLog(@"rfcommChannelClosed");
}


- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
{
    NSLog(@"rfcommChannelData");
}


-(void) disconnect
{
    if (mChannel != nil)
    {
        // And closes the channel:
        [mChannel closeChannel];
        
        // We do not need the channel anymore:
//        [mChannel release];
        mChannel = nil;
    }
}


-(void) send:(char*)dataPointer length:(size_t)dataLength
{
    if (mChannel != nil)
    {
        size_t				numBytesRemaining;
        IOReturn			result;
		BluetoothRFCOMMMTU	rfcommChannelMTU;
		
		numBytesRemaining = dataLength;
		result = kIOReturnSuccess;
		
		// Get the RFCOMM Channel's MTU.  Each write can only contain up to the MTU size
		// number of bytes.
		rfcommChannelMTU = [mChannel getMTU];
		
		// Loop through the data until we have no more to send.
		while ( ( result == kIOReturnSuccess ) && ( numBytesRemaining > 0 ) )
		{
			// finds how many bytes I can send:
			size_t numBytesToSend = ( ( numBytesRemaining > rfcommChannelMTU ) ? rfcommChannelMTU :  numBytesRemaining );
			
			// This method won't return until the buffer has been passed to the Bluetooth hardware to be sent to the remote device.
			// Alternatively, the asynchronous version of this method could be used which would queue up the buffer and return immediately.
			result = [mChannel writeSync:dataPointer length:numBytesToSend];
			
			// Updates the position in the buffer:
			numBytesRemaining -= numBytesToSend;
			dataPointer += numBytesToSend;
		}
		
        // We are successful only if all the data was sent:
        if ( ( numBytesRemaining == 0 ) && ( result == kIOReturnSuccess ) )
		{
            //return TRUE;
		}
    }
}


@end
