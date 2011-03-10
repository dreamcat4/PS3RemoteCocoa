/* $Id$ */

/*
 *  Copyright (c) 2008-2009 Axel Andersson
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPRemote.h"

// Bluetooth headers:
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothL2CAPChannel.h>
#import <IOBluetooth/objc/IOBluetoothDeviceInquiry.h>

// And mach_error_string() to lookup bluetooth status codes
#include <mach/mach_error.h>

extern NSString * const						SPBluetoothRemoteWillConnect;
extern NSString * const						SPBluetoothRemoteDidConnect;
extern NSString * const						SPBluetoothRemoteDidDisconnect;


@interface SPBluetoothRemote : SPRemote {
	IOBluetoothDevice						*_device;
  // IOBluetoothDeviceInquiry   *_inquiry;
	
	IOBluetoothL2CAPChannel					*_controlChannel;
	IOBluetoothL2CAPChannel					*_interruptChannel;
	
	IOBluetoothUserNotification				*_disconnectNotification;
	
	BOOL									_controlCompleted;
	BOOL									_controlConnected;
	BOOL									_interruptCompleted;
	BOOL									_interruptConnected;

	BOOL									_connected;
	BOOL									_connecting;
	
	BOOL									_logging;
}

+ (NSString *)remoteName;
+ (BOOL)needsControlChannel;
+ (BOOL)needsInterruptChannel;

- (void)connectAfterDelay;
- (void)disconnectAfterDelay;
- (BOOL)remoteShouldDisconnect;
- (void)remoteDidConnect;

- (BOOL)isConnecting;
- (BOOL)isConnected;
- (BOOL)hasDevice;

- (void) connectDevice:(NSTimer *)timer;

@end
