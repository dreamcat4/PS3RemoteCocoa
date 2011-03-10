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

#import "SPPS3Remote.h"

@interface SPPS3Remote(Private)

- (void)_handleButton:(unsigned char)button;

@end


@implementation SPPS3Remote(Private)

- (void)_handleButton:(unsigned char)button {
  // this is called from +l2capChannelData:data:length:
	if(button != 0xFF) {
		_lastHoldButton = button;
		_lastHoldButtonTime = [NSDate timeIntervalSinceReferenceDate];
		
		[self performSelector:@selector(_handleSimulatedHoldButton:) 
				   withObject:[NSNumber numberWithDouble:_lastHoldButtonTime]
				   afterDelay:0.3];

		if(_delegatePS3RemotePressedButton)
			[delegate PS3Remote:self pressedButton:button];
	} else {
		if(_lastButtonSimulatedHold) {
			_lastHoldButton = 0;
			_lastButtonSimulatedHold = NO;
		} else {
			_lastHoldButton = 0;
		}
		
		if(_delegatePS3RemoteReleasedButton)
			[delegate PS3RemoteReleasedButton:self];
	}
}



- (void)_handleSimulatedHoldButton:(id)time {
	if(_lastHoldButton > 0 && _lastHoldButtonTime == [time doubleValue]) {
		_lastButtonSimulatedHold = YES;

		if(_delegatePS3RemoteHeldButton)
			[delegate PS3Remote:self heldButton:_lastHoldButton];
	}
}

@end



@implementation SPPS3Remote

// The name of the Bluetooth device we are matching against
+ (NSString *)remoteName {
	return @"BD Remote Control";
}



+ (BOOL)needsInterruptChannel {
	return YES;
}



#pragma mark -

// Global object as we create only 1 class instance representing our PS3 BD Remote
+ (SPPS3Remote *)sharedRemote {
	static SPPS3Remote		*sharedRemote;
	
	if(!sharedRemote)
		sharedRemote = [[self alloc] init];
	
	return sharedRemote;
}



#pragma mark -

- (void)remoteDidConnect {
	[self disconnectAfterDelay];
	
	[super remoteDidConnect];
}



- (BOOL)remoteShouldDisconnect {
	return [delegate PS3RemoteShouldDisconnect:self];
}



#pragma mark -

// Point to our hooks in the SPApplicationController.m
- (void)setDelegate:(id <SPPS3RemoteDelegate>)aDelegate {
	delegate = aDelegate;
	
	_delegatePS3RemotePressedButton		= [delegate respondsToSelector:@selector(PS3Remote:pressedButton:)];
	_delegatePS3RemoteHeldButton		= [delegate respondsToSelector:@selector(PS3Remote:heldButton:)];
	_delegatePS3RemoteReleasedButton	= [delegate respondsToSelector:@selector(PS3RemoteReleasedButton:)];
}



- (id <SPPS3RemoteDelegate>)delegate {
	return delegate;
}



#pragma mark -

// Lookup table for key mappings
- (SPRemoteAction)actionForButton:(SPPS3RemoteButton)button inContext:(SPRemoteContext)context {
	switch(button) {
		case SPPS3RemoteButtonEject:
			return SPRemoteEject;
			break;
			
		case SPPS3RemoteButtonAudio:
			return SPRemoteCycleAudioTracks;
			break;
			
		case SPPS3RemoteButtonSubtitle:
			return SPRemoteCycleSubtitleTracks;
			break;
			
		case SPPS3RemoteButtonTime:
		case SPPS3RemoteButtonDisplay:
			return SPRemoteDisplayTime;
			break;
			
		case SPPS3RemoteButtonTopMenu:
			if(context == SPRemoteDrillView)
				return SPRemoteHideDrillView;
			else if(context == SPRemoteFullscreenPlayer)
				return SPRemoteCloseFullscreenMovie;
			else
				return SPRemoteShowDrillView;
			break;
			
		case SPPS3RemoteButtonPopUpMenu:
			return SPRemoteShowHUD;
			break;
			
		case SPPS3RemoteButtonReturn:
		case SPPS3RemoteButtonBack:
		case SPPS3RemoteButtonX:
			return SPRemoteBack;
			break;
			
		case SPPS3RemoteButtonUp:
			return SPRemoteUp;
			break;
			
		case SPPS3RemoteButtonDown:
			return SPRemoteDown;
			break;
			
		case SPPS3RemoteButtonLeft:
			return SPRemoteLeft;
			break;
			
		case SPPS3RemoteButtonRight:
			return SPRemoteRight;
			break;
			
		case SPPS3RemoteButtonEnter:
			return SPRemoteEnter;
			break;
			
		case SPPS3RemoteButtonScanBackward:
			return SPRemoteScanBackward;
			break;
			
		case SPPS3RemoteButtonPlay:
			return SPRemotePlay;
			break;
			
		case SPPS3RemoteButtonScanForward:
			return SPRemoteScanForward;
			break;
			
		case SPPS3RemoteButtonPrevious:
			return SPRemotePrevious;
			break;
			
		case SPPS3RemoteButtonStop:
			return SPRemoteStop;
			break;
			
		case SPPS3RemoteButtonNext:
			return SPRemoteNext;
			break;
			
		case SPPS3RemoteButtonStepBackward:
			return SPRemoteStepBackward;
			break;
			
		case SPPS3RemoteButtonPause:
			return SPRemotePause;
			break;
			
		case SPPS3RemoteButtonStepForward:
			return SPRemoteStepForward;
			break;
		
		default:
			return SPRemoteDoNothing;
			break;
	}
	
	return SPRemoteDoNothing;
}

  // it seems we cant connect to the bd remote in this way
  // because the bd remote will normally be powered-down
// - (void) connectDevice:(NSTimer *)timer
// {
//   // no success whilst BD remote is sleeping
//   // static BluetoothDeviceAddress ps3_remote_addr = { { 0x00,0x24,0x33,0x4e,0xe8,0xc7 } };
//   // 
//   // _device = [IOBluetoothDevice withAddress:&ps3_remote_addr];
//   // 
//   // if ([_device openL2CAPChannelSync:&_controlChannel withPSM:17 delegate:self] != kIOReturnSuccess)
//   //  NSLog(@"could not open L2CAP channel _controlChannel");
//   // 
//   // if ([_device openL2CAPChannelSync:&_interruptChannel withPSM:19 delegate:self] != kIOReturnSuccess)
//   //    NSLog(@"could not open L2CAP channel _interruptChannel");
// 
//   // no success - it didnt return vv
//   // if ([self isConnected] || _inquiry) return;
//   // _inquiry = [[IOBluetoothDeviceInquiry alloc] initWithDelegate:self];
//   // [_inquiry start];
// 
// // #ifdef DEBUG
// //  NSLog(@"Searching for device...");
// // #endif 
// }

// no success - it didnt trigger
// - (void) deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry*)sender device:(IOBluetoothDevice*)foundDevice
// {
//  if ([[foundDevice name] isEqualToString:@"BD Remote Control"]) 
//  {
// #ifdef DEBUG
//    NSLog(@"Found Wii device, initializing...");
// #endif
// 
//    // Found device, retain it in memory and end the search
//    [self initializeDevice:foundDevice];
//    [sender stop];
//  }
// }

// - (void) deviceInquiryComplete:(IOBluetoothDeviceInquiry*)sender error:(IOReturn)error aborted:(BOOL)aborted
// {
// #ifdef DEBUG
//  NSLog(@"Device inquiry completed.");
// #endif
// 
//  [_inquiry release];
//  _inquiry = nil;
// }

// no success - didnt trigger
// - (bool) initializeDevice:(IOBluetoothDevice*)foundDevice
// {
//   // [self stopDevice];
//  
//  if ([foundDevice openConnection] != kIOReturnSuccess) 
//  {
//    NSLog(@"could not open the connection...");
//    return NO;
//  }
//  
//   if ([foundDevice performSDPQuery:nil] != kIOReturnSuccess)
//   {
//    NSLog(@"could not perform SDP Query...");
//    return NO;
//   }
//  
//   if ([foundDevice openL2CAPChannelSync:&_controlChannel withPSM:17 delegate:self] != kIOReturnSuccess)
//   {
//    NSLog(@"could not open L2CAP channel _controlChannel");
//    //_controlChannel = nil;
//    //[foundDevice closeConnection];
//    return NO;
//   }  
//  
//  if ([foundDevice openL2CAPChannelSync:&_interruptChannel withPSM:19 delegate:self] != kIOReturnSuccess){
//    NSLog(@"could not open L2CAP channel _interruptChannel");
//  //  _interruptChannel = nil;
//     // [_interruptChannel closeChannel];
//     // [foundDevice closeConnection];
//    return NO;
//  }
//  
//  // Retain the device in memory
//  _device = [foundDevice retain];
//   // [_controlChannel retain];
//  [_interruptChannel  retain];
//  
//  return YES;
// }


#pragma mark -

- (void)l2capChannelData:(IOBluetoothL2CAPChannel *)channel data:(unsigned char *)buffer length:(size_t)length {
	if(length != 13) {
		NSLog(@"*** SPPS3Remote: Unrecognized data received from remote: %@",
			[NSData dataWithBytes:buffer length:length]);
		
		return;
	}

	NSLog(@"*** SPPS3Remote: Keypress Data received from the remote.");

// (whilst in sleep mode) Im not sure how Sony handles this in the PS3.

// Here we receive the keypress data over an opened L2CAP control channel.
// We normally receive 2 data messages for each 1 full key press -
// 1 message for key press "down" + 1 message for key press up / "release"

// So therefore my suspicion is that the initial key press "down" event which sends the
// interrupt (l2capChannelOpenComplete) NTF is used to wake up the control channel. Or to make
// a brand new control channel. Im not sure how this happens for the BD Remote.

// Then by the time the control channel is awake, it may have missed out on the "key down" event,
// but might be ready in enough time to receive the  user's "key released" event.
// or at least the second full key press.

// However I really have no idea if this is the case. Because for my situation the connection is 
// never re-established. Instead, Mac OS "Pairing Request" window appears, the wake up goes wrong.

	[self _handleButton:buffer[5]];

	[self disconnectAfterDelay];
}

@end
