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

enum _SPPS3RemoteButton {
	SPPS3RemoteButton1						= 0x00,
	SPPS3RemoteButton2						= 0x01,
	SPPS3RemoteButton3						= 0x02,
	SPPS3RemoteButton4						= 0x03,
	SPPS3RemoteButton5						= 0x04,
	SPPS3RemoteButton6						= 0x05,
	SPPS3RemoteButton7						= 0x06,
	SPPS3RemoteButton8						= 0x07,
	SPPS3RemoteButton9						= 0x08,
	SPPS3RemoteButton0						= 0x09,
	SPPS3RemoteButtonEject					= 0x16,
	SPPS3RemoteButtonAudio					= 0x64,
	SPPS3RemoteButtonAngle					= 0x65,
	SPPS3RemoteButtonSubtitle				= 0x63,
	SPPS3RemoteButtonClear					= 0x0F,
	SPPS3RemoteButtonTime					= 0x28,
	SPPS3RemoteButtonRed					= 0x81,
	SPPS3RemoteButtonGreen					= 0x82,
	SPPS3RemoteButtonBlue					= 0x80,
	SPPS3RemoteButtonYellow					= 0x83,
	SPPS3RemoteButtonDisplay				= 0x70,
	SPPS3RemoteButtonTopMenu				= 0x1A,
	SPPS3RemoteButtonPopUpMenu				= 0x40,
	SPPS3RemoteButtonReturn					= 0x0E,
	SPPS3RemoteButtonOptions				= 0x5C,
	SPPS3RemoteButtonBack					= 0x5D,
	SPPS3RemoteButtonView					= 0x5F,
	SPPS3RemoteButtonX						= 0x5E,
	SPPS3RemoteButtonUp						= 0x54,
	SPPS3RemoteButtonDown					= 0x56,
	SPPS3RemoteButtonLeft					= 0x57,
	SPPS3RemoteButtonRight					= 0x55,
	SPPS3RemoteButtonEnter					= 0x0B,
	SPPS3RemoteButtonL1						= 0x5A,
	SPPS3RemoteButtonL2						= 0x58,
	SPPS3RemoteButtonL3						= 0x51,
	SPPS3RemoteButtonPS						= 0x43,
	SPPS3RemoteButtonSelect					= 0x50,
	SPPS3RemoteButtonStart					= 0x53,
	SPPS3RemoteButtonR1						= 0x5B,
	SPPS3RemoteButtonR2						= 0x59,
	SPPS3RemoteButtonR3						= 0x52,
	SPPS3RemoteButtonScanBackward			= 0x33,
	SPPS3RemoteButtonPlay					= 0x32,
	SPPS3RemoteButtonScanForward			= 0x34,
	SPPS3RemoteButtonPrevious				= 0x30,
	SPPS3RemoteButtonStop					= 0x38,
	SPPS3RemoteButtonNext					= 0x31,
	SPPS3RemoteButtonStepBackward			= 0x60,
	SPPS3RemoteButtonPause					= 0x39,
	SPPS3RemoteButtonStepForward			= 0x61
};
typedef enum _SPPS3RemoteButton				SPPS3RemoteButton;


@protocol SPPS3RemoteDelegate;

@interface SPPS3Remote : SPBluetoothRemote {
	id <SPPS3RemoteDelegate>				delegate;
	
	SPPS3RemoteButton						_lastHoldButton;
	NSTimeInterval							_lastHoldButtonTime;
	BOOL									_lastButtonSimulatedHold;

	BOOL									_delegatePS3RemotePressedButton;
	BOOL									_delegatePS3RemoteHeldButton;
	BOOL									_delegatePS3RemoteReleasedButton;
}

+ (SPPS3Remote *)sharedRemote;

- (void)setDelegate:(id <SPPS3RemoteDelegate>)delegate;
- (id <SPPS3RemoteDelegate>)delegate;

- (SPRemoteAction)actionForButton:(SPPS3RemoteButton)button inContext:(SPRemoteContext)context;

@end


@protocol SPPS3RemoteDelegate <NSObject>

- (BOOL)PS3RemoteShouldDisconnect:(SPPS3Remote *)remote;

@optional

- (void)PS3Remote:(SPPS3Remote *)remote pressedButton:(SPPS3RemoteButton)button;
- (void)PS3Remote:(SPPS3Remote *)remote heldButton:(SPPS3RemoteButton)button;
- (void)PS3RemoteReleasedButton:(SPPS3Remote *)remote;

@end
