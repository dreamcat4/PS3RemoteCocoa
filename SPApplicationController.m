/* $Id$ */

/*
 *  Copyright (c) 2007-2009 Axel Andersson
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

#import "SPApplicationController.h"

// #import "SPAppleRemote.h"
#import "SPPS3Remote.h"
// #import "SPWiiRemote.h"


static SPApplicationController			*SPSharedApplicationController;


@interface SPApplicationController(Private)

// - (void)_update;
- (SPRemoteContext)_remoteContext;
- (void)_handleRemoteAction:(SPRemoteAction)action;

@end


@implementation SPApplicationController(Private)


//- (void)_update {
//}

#pragma mark -

- (SPRemoteContext)_remoteContext {

	id					delegate;
	
	delegate = [[NSApp keyWindow] delegate];
	
	return SPRemoteNone;
}



- (void)_handleRemoteAction:(SPRemoteAction)action {
	id						delegate;

  // this is where we can put a breakpoint
  // or handle a successful key press event

	delegate = [[NSApp keyWindow] delegate];
	
	NSLog(@"*** SPPS3Remote: Key %2X pressed.", action);
	switch(action) {
		case SPRemoteDoNothing:
			break;
		
		case SPRemoteUp:
			break;
		
		case SPRemoteDown:
			break;
		
		case SPRemoteRight:
			break;
		
		case SPRemoteLeft:
			break;
		
		case SPRemoteEnter:
			break;
		
		case SPRemotePlay:
			break;
		
		case SPRemotePlayOrPause:
			break;
		
		case SPRemotePause:
			break;
		
		case SPRemoteStop:
			break;
		
		case SPRemoteNext:
			break;
		
		case SPRemotePrevious:
			break;
		
		case SPRemoteBack:
			break;
			
		case SPRemoteScanForward:
			break;
		
		case SPRemoteScanBackward:
			break;
		
		case SPRemoteStepForward:
			break;
		
		case SPRemoteStepBackward:
			break;
		
		case SPRemoteCycleSubtitleTracks:
			break;
		
		case SPRemoteCycleAudioTracks:
			break;
		
		case SPRemoteEject:
			break;
		
		case SPRemoteShowHUD:
			break;
			
		case SPRemoteDisplayTime:
			break;
		
		case SPRemoteShowDrillView:
			break;
		
		case SPRemoteHideDrillView:
			break;
		
		case SPRemoteCloseFullscreenMovie:
			break;
	}
}



@end



@implementation SPApplicationController

+ (SPApplicationController *)applicationController {
	return SPSharedApplicationController;
}

@synthesize window;

#pragma mark -

- (void)awakeFromNib {

	SPSharedApplicationController = self;
	
//	[[SPAppleRemote sharedRemote] setDelegate:self];
	[[SPPS3Remote sharedRemote] setDelegate:self];
//	[[SPWiiRemote sharedRemote] setDelegate:self];
  
//	[self _update];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
//	[[SPAppleRemote sharedRemote] startListening];
	_activated = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
	id		delegate;
	delegate = [[NSApp keyWindow] delegate];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
}


#pragma mark -

- (BOOL)PS3RemoteShouldDisconnect:(SPPS3Remote *)remote {
	return false;
}



- (void)PS3Remote:(SPPS3Remote *)remote pressedButton:(SPPS3RemoteButton)button {
	SPRemoteAction		action;
	
//	if([NSApp isActive]) {
	if( true ) {
		action = [[SPPS3Remote sharedRemote] actionForButton:button inContext:[self _remoteContext]];
		
		[self _handleRemoteAction:action];

		_holdingPS3RemoteButton = NO;
	}
}



- (void)PS3Remote:(SPPS3Remote *)remote heldButton:(SPPS3RemoteButton)button {
	if([NSApp isActive]) {
		_holdingPS3RemoteButton = YES;
		
		[self performSelector:@selector(holdPS3RemoteButton:) 
				   withObject:[NSNumber numberWithInt:button]];
	}
}



- (void)holdPS3RemoteButton:(NSNumber *)button {
	SPRemoteAction		action;
	
	if([NSApp isActive] && _holdingPS3RemoteButton) {
		action = [[SPPS3Remote sharedRemote] actionForButton:[button intValue] inContext:[self _remoteContext]];
		
		[self _handleRemoteAction:action];
		 
		[self performSelector:@selector(holdPS3RemoteButton:) 
				   withObject:button
				   afterDelay:0.05];
	}
}



- (void)PS3RemoteReleasedButton:(SPPS3Remote *)remote {
	if([NSApp isActive])
		_holdingPS3RemoteButton = NO;
}


@end
