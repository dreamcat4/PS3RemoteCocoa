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

#import "SPBluetoothRemote.h"

NSString * const SPBluetoothRemoteWillConnect		= @"SPBluetoothRemoteWillConnect";
NSString * const SPBluetoothRemoteDidConnect		= @"SPBluetoothRemoteDidConnect";
NSString * const SPBluetoothRemoteDidDisconnect		= @"SPBluetoothRemoteDidDisconnect";


@interface SPBluetoothRemote(Private)

+ (IOBluetoothDevice *)_recentRemoteDevice;

- (void)_connect;
- (BOOL)_connectAsync;
- (BOOL)_connectControlAsync;
- (BOOL)_connectInterruptAsync;
- (void)_disconnect;

@end


@implementation SPBluetoothRemote(Private)

+ (IOBluetoothDevice *)_recentRemoteDevice {
	NSArray				*devices;
	IOBluetoothDevice	*device;
	
	devices = [IOBluetoothDevice recentDevices:0];
	
	for(device in devices) {
    if([[device name] isEqualToString:[self remoteName]])
			return device;
	}
	
	return NULL;
}



#pragma mark - 

- (void)_connect {
	if(![self _connectAsync])
		[self connectAfterDelay];
}



- (BOOL)_connectAsync {
	if(!_device)
		return NO;
	
	[_disconnectNotification unregister];
	_disconnectNotification = [_device registerForDisconnectNotification:self selector:@selector(bluetoothDeviceDidDisconnect:device:)];
	
	if(!_controlConnected && [[self class] needsControlChannel]) {
		if(![self _connectControlAsync])
			return NO;
	}

	if(!_interruptConnected && [[self class] needsInterruptChannel]) {
		if(![self _connectInterruptAsync])
			return NO;
	}
	
	return YES;
}



- (BOOL)_connectControlAsync {
	IOReturn		result;
	
	_controlCompleted = NO;
	
	if(_logging)
		NSLog(@"*** -[%@ _connectControlAsync]", [self class]);

	result = [_device openL2CAPChannelAsync:&_controlChannel withPSM:kBluetoothL2CAPPSMHIDControl delegate:self];
	
	return (result == kIOReturnSuccess);
}



- (BOOL)_connectInterruptAsync {
	IOReturn		result;

	_interruptCompleted = NO;
	
	if(_logging)
		NSLog(@"*** -[%@ _connectInterruptAsync]", [self class]);
	
	result = [_device openL2CAPChannelAsync:&_interruptChannel withPSM:kBluetoothL2CAPPSMHIDInterrupt delegate:self];
	
	return (result == kIOReturnSuccess);
}



- (void)_disconnect {
	NSLog(@"*** -[%@ _disconnect]", [self class]);

	if([self remoteShouldDisconnect]) {
		if(_controlConnected)
			[_controlChannel closeChannel];

		if(_interruptConnected)
			[_interruptChannel closeChannel];
		
		[_device closeConnection];
	} else {
		[self disconnectAfterDelay];
	}
}

@end



@implementation SPBluetoothRemote

+ (NSString *)remoteName {
	[self doesNotRecognizeSelector:_cmd];
	
	return NULL;
}



+ (BOOL)needsControlChannel {
	return NO;
}



+ (BOOL)needsInterruptChannel {
	return NO;
}



#pragma mark -

- (id)init {
	self = [super init];
  _logging = YES;
	_device = [[[self class] _recentRemoteDevice] retain];
	
	if(_device)
		[self connectAfterDelay];
	
	[IOBluetoothDevice registerForConnectNotifications:self selector:@selector(bluetoothDeviceDidConnect:device:)];

	return self;
}



- (void)dealloc {
	[_device release];
	
	[super dealloc];
}



#pragma mark -

- (void)connectAfterDelay {
	_connecting = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SPBluetoothRemoteWillConnect object:self];
	
	[self performSelectorOnce:@selector(_connect) afterDelay:1.0];
}



- (void)disconnectAfterDelay {
	[self performSelectorOnce:@selector(_disconnect) afterDelay:600.0];
}



- (BOOL)remoteShouldDisconnect {
	return NO;
}



- (void)remoteDidConnect {
	_connected = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SPBluetoothRemoteDidConnect object:self];
}



#pragma mark -

- (BOOL)isConnecting {
	return _connecting;
}



- (BOOL)isConnected {
	return _connected;
}



- (BOOL)hasDevice {
	return (_device != NULL);
}



#pragma mark -

- (void)l2capChannelOpenComplete:(IOBluetoothL2CAPChannel *)channel status:(IOReturn)status {
	BOOL		needsControl, needsInterrupt;
	
	if(channel == _controlChannel) {
		_controlCompleted = YES;
		_controlConnected = (status == kIOReturnSuccess);

		if(_logging)
			NSLog(@"*** -[%@ l2capChannelOpenComplete:status::] control %s", [self class], mach_error_string(status));
	}
	else if(channel == _interruptChannel) {
    // This message depends on what is happening during the connection and pairing.

    // Status code varies, depending on the situation. Have seen:
    //    interrupt (iokit/common) device not open, E00002CD
    //    interrupt (os/kern) successful, 0
    //    interrupt (os/kern) invalid argument, 4

		_interruptCompleted = YES;
    _interruptConnected = (status == kIOReturnSuccess);

		if(_logging)
			NSLog(@"*** -[%@ l2capChannelOpenComplete:status::]: interrupt %s, %X", [self class], mach_error_string(status), status);

	}
	
	needsControl	= [[self class] needsControlChannel];
	needsInterrupt	= [[self class] needsInterruptChannel];
	
	if((_controlCompleted || !needsControl) && (_interruptCompleted || !needsInterrupt)) {
		_connecting = NO;
		
		if((_controlConnected || !needsControl) && (_interruptConnected || !needsInterrupt))
			[self remoteDidConnect];
		else
			[self connectAfterDelay];
	}
}



- (void)l2capChannelData:(IOBluetoothL2CAPChannel *)channel data:(unsigned char *)buffer length:(size_t)length {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) connectDevice:(NSTimer *)timer {
	[self doesNotRecognizeSelector:_cmd];
}


- (void)bluetoothDeviceDidConnect:(IOBluetoothUserNotification *)notification device:(IOBluetoothDevice *)device {
	if([[device name] isEqualToString:[[self class] remoteName]]) {
		_logging = YES;
		
		NSLog(@"*** -[%@ bluetoothDeviceDidConnect:device::]: %@", [self class], [device name]);

		[device retain];
		[_device release];
		
		_device = device;
		
		[self connectAfterDelay];
	}
}



- (void)bluetoothDeviceDidDisconnect:(IOBluetoothUserNotification *)notification device:(IOBluetoothDevice *)device {
	if([[device name] isEqualToString:[[self class] remoteName]]) {
		_logging = YES;
		
		NSLog(@"*** -[%@ bluetoothDeviceDidDisconnect:device::]: %@", [self class], [device name]);
	
		_controlConnected = NO;
		_interruptConnected = NO;
		_connected = NO;
	
		[[NSNotificationCenter defaultCenter] postNotificationName:SPBluetoothRemoteDidDisconnect object:self];
	}
}

@end
