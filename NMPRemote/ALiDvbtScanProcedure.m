//
//  ALiDvbtScanProcedure.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDvbtScanProcedure.h"
#import "ALiDemuxer.h"

#define LOCK_TIMEOUT    5
#define PAT_TIMEOUT     12
#define STEP_TIMEOUT    60

#define TUNER_PARAM_FEID    0
#define TUNER_PARAM_LVEL    1
#define TUNER_PARAM_LOCK    2
#define TUNER_PARAM_QUAL    3
#define TUNER_PARAM_FREQ    4


typedef enum {
    HTTP = 0,
    RTSP = 1
} Scheme;

typedef enum {
    WATCH = 1,
    EPG = 2,
    SCAN = 4
} Purpose;

typedef enum {
    PAT = 0x01,
    PMT = 0x02,
    SDT = 0x04
} TableType;

enum States {
    Idle = 0,
    Starting = 1,
    Stepping = 2,
    Parsing = 3
};

// TODO:
// - Test deallocation of session

@implementation ALiDvbtScanProcedure
{
    ALiRTSPSession *session;
    ALiDemuxer *demuxer;
    dispatch_queue_t scanProcessingQueue;
    ScanStatus previousState;
    NSLock *lock;
    BOOL changingFrequency;
    
    // Scan support variables
    double frequency;
    NSMutableDictionary *programs, *stepPrograms;
    
    // Step support variables
    NSMutableArray *scanPids;
    BOOL locked;
    NSTimer *lockTimer, *patTimer, *sessionTimer, *stepTimer;
    NSMutableArray *handlers;
    TableType tables;
    UInt32 currentSsrc;
}

- (NSString *)toUrl:(Scheme)scheme
               host:(NSString *)host
            purpose:(Purpose)purpose
{
    NSMutableString *url = [NSMutableString stringWithString:@""];
    
    
    // Create list of PIDS
    NSMutableArray *pids = [[NSMutableArray alloc] initWithCapacity:0];
    [pids addObject:@"0"];
    
    switch (purpose) {
        case EPG:
            break;
            
        case WATCH:
            break;
            
        case SCAN:
            // The default pids ...
            [pids addObject:@"16"];
            [pids addObject:@"17"];
            [pids addObject:@"18"];
            [pids addObject:@"20"];
            // ... plus the scanned pids
            for (NSString *pid in scanPids) {
                [pids addObject:pid];
            }
            break;
    }
    
    // Set url scheme
    switch (scheme) {
        case HTTP:
            [url appendString:@"http://"];
            break;
        case RTSP:
            [url appendString:@"rtsp://"];
    }
    
    // Set IP address
    [url appendString:host];
    
    // Set path
    if (session.status > IDLE) {
        [url appendFormat:@"/stream=%lu", (unsigned long)session.streamID];
    } else {
        [url appendString:@"/"];
    }
    
    // Set url query
    [url appendString:@"?"];
    [url appendFormat:@"freq=%f", frequency];
    [url appendString:@"&msys=dvbt"];
    [url appendString:@"&bw=8"];
    [url appendFormat:@"&pids=%@", [pids componentsJoinedByString:@","]];
    
//    NSLog(@"URL: %@", url);
    
    return url;
}

- (void)deleteSession
{
    session = nil;
}

- (void)startLockTimeoutTimer
{
//    NSLog(@"Start lock timeout timer!");
    dispatch_sync(dispatch_get_main_queue(), ^{
        lockTimer = [NSTimer scheduledTimerWithTimeInterval:LOCK_TIMEOUT target:self selector:@selector(lockTimeout) userInfo:nil repeats:FALSE];
    });
}

- (void)startPatTimeoutTimer
{
//    NSLog(@"Start PAT timeout timer!");
    dispatch_sync(dispatch_get_main_queue(), ^{
        patTimer = [NSTimer scheduledTimerWithTimeInterval:PAT_TIMEOUT target:self selector:@selector(patTimeout) userInfo:nil repeats:FALSE];
    });
}

- (void)startStepTimeout
{
    //    NSLog(@"Start step timeout timer!");
    dispatch_sync(dispatch_get_main_queue(), ^{
        stepTimer = [NSTimer scheduledTimerWithTimeInterval:STEP_TIMEOUT target:self selector:@selector(stepTimeout) userInfo:nil repeats:FALSE];
    });
}

- (void)killTimers
{
    [self killTimers:NO];
}

- (void)killTimers:(BOOL)all
{
    if (lockTimer != nil) {
//        NSLog(@"Stop lock timeout timer!");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [lockTimer invalidate];
        });
        lockTimer = nil;
    }
    
    if (patTimer != nil) {
//        NSLog(@"Stop PAT timeout timer!");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [patTimer invalidate];
        });
        patTimer = nil;
    }
    
    if ((stepTimer != nil) && all) {
//        NSLog(@"Stop step timeout timer!");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [stepTimer invalidate];
        });
        stepTimer = nil;
    }
}

- (void)lockTimeout
{
    // Check that we are not in the middle of an RTSP request
    if ((_scanStatus == SCAN_SETUP_REQUEST) ||
        (_scanStatus == SCAN_PLAY_REQUEST) ||
        (_scanStatus == SCAN_TEARDOWN_REQUEST)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            NSLog(@"- Post pone lock timeout!");
            [self lockTimeout];
        });
        return;
    }
    
    dispatch_async(scanProcessingQueue, ^{
        NSLog(@"- Lock timeout! (%f MHz)", frequency);
        
        // Update status
        [self updateState:SCAN_LOCK_TIMEOUT];
        
        [self step];
    });
}

- (void)patTimeout
{
    // Check that we are not in the middle of an RTSP request
    if ((_scanStatus == SCAN_SETUP_REQUEST) ||
        (_scanStatus == SCAN_PLAY_REQUEST) ||
        (_scanStatus == SCAN_TEARDOWN_REQUEST)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            NSLog(@"- Post pone PAT timeout!");
            [self patTimeout];
        });
        return;
    }
    
    dispatch_async(scanProcessingQueue, ^{
        NSLog(@"- PAT timeout! (%f MHz)", frequency);
        
        // Update status
        [self updateState:SCAN_PAT_TIMEOUT];
        
        [self step];
    });
}

- (void)stepTimeout
{
    // Check that we are not in the middle of an RTSP request
    if ((_scanStatus == SCAN_SETUP_REQUEST) ||
        (_scanStatus == SCAN_PLAY_REQUEST) ||
        (_scanStatus == SCAN_TEARDOWN_REQUEST)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            NSLog(@"- Post pone step timeout!");
            [self stepTimeout];
        });
        return;
    }
    
    dispatch_async(scanProcessingQueue, ^{
        NSLog(@"- Step timeout! (%f MHz)", frequency);
        
        // Update status
        [self updateState:SCAN_STEP_TIMEOUT];
        
        [self step];
    });
}

- (void)attachHandlers
{
    for (ALiPidHandler *handler in handlers) {
        [handler attach];
    }
}

- (void)dettachHandlers
{
    for (ALiPidHandler *handler in handlers) {
        [handler dettach];
    }
}

- (void)setLocked
{
    [self setLocked:NO];
}

- (void)setLocked:(BOOL)forced
{
    // If already locked do nothing
    if (locked && !forced)
        return;
    
    // Invalidate timers
    [self killTimers];
    
    // Set status as locked
    locked = YES;
    
    // Log
    NSLog(@"- Locked!");
    
    // Update status
    [self updateState:SCAN_LOCKED];
    
    // Check if a PAT handler already exists and if not create one
    ALiPatHandler *patHandler = nil;
    for (ALiPidHandler *handler in handlers) {
        if ([handler isKindOfClass:[ALiPatHandler class]]) {
            patHandler = (ALiPatHandler *)handler;
            break;
        }
    }
    if (patHandler == nil) {
//        NSLog(@"Creating a PAT handler!");
        patHandler = [[ALiPatHandler alloc] init];
        patHandler.delegate = self;
        [patHandler attach];
        [demuxer addPidHandler:0x0 handler:patHandler];
        [handlers addObject:patHandler];
    }
    
    // Attach all handlers
//    [self attachHandlers];
    
    // Check if we've already found the PAT
    if (tables & PAT) {
        [self updateState:SCAN_PAT_FOUND];
    } else {
        // Launch PAT timeout timer
        [self startPatTimeoutTimer];
    }
}

- (void)setUnlocked
{
    [self setUnlocked:NO];
}

- (void)setUnlocked:(BOOL)forced
{
    // If already unlocked do nothing
    if (!locked && !forced)
        return;
    
    // If forced it means the RTP reception is paused, thus, resume it
    [session resumeRTPReception];
    
    // Invalidate timers
    [self killTimers];
    
    // Set status as unlocked
    locked = NO;
    
    // Log
    NSLog(@"- Unlocked!");
    
    // Update status
    [self updateState:SCAN_UNLOCKED];
    
    // Detach all handlers
//    [self dettachHandlers];
    
    // Re-launch lock timeout timer
    [self startLockTimeoutTimer];
}

- (void)setReceivingNewStream
{
    // Log
    NSLog(@"- Receiving new stream!");
    
    // Update status
    [self updateState:SCAN_RX_NSTREAM];
    
    // Force set to unlock
    [self setUnlocked:YES];
}

- (void)checkDone
{
    bool allPmtTriggered = true, hasPmtHandler = false;

    // Check if each of the PMT handlers have been triggered
    for (ALiPidHandler *handler in handlers) {
        if ([handler isKindOfClass:[ALiPmtHandler class]]) {
            ALiPmtHandler *pmtHandler = (ALiPmtHandler *)handler;
            allPmtTriggered &= [pmtHandler triggered];
            hasPmtHandler = true;
        }
    }
    
    if (allPmtTriggered && hasPmtHandler) {
        tables |= PMT;
    } else {
        /*
        if (!allPmtTriggered) {
            NSLog(@"Not all PMT have been seen yet!");
        }
        if (!hasPmtHandler) {
            NSLog(@"No PMT handlers created!");
        }
        */
    }
    
    if (tables == (PAT | SDT | PMT)) {
        NSLog(@"- Got all information");
        
        // Update status
        [self updateState:SCAN_STEP_COMPLETE];
        
        // Save all channels we've found so far
        [self commitData];
        
        // Next step
        [self step];
    } else {
        /*
        if (!(tables & PAT)) {
            NSLog(@"No PAT found!");
        }
        if (!(tables & SDT)) {
            NSLog(@"No SDT found!");
        }
        */
    }
}

- (void)clearStepSupportVariables
{
    // Kill all runing timers
    [self killTimers:YES];
    
     // Deatach all handlers
//    [self dettachHandlers];
    
    // Remove all handlers from demuxer
    [demuxer removeAllPidHandlers];
    
    // Delete all handlers and clear handlers container
    [handlers removeAllObjects];
    
    // Reset SSRC
    currentSsrc = 0;
    
    // Clear scan pids container
    [scanPids removeAllObjects];
    
    // Force lock state to false
    locked = FALSE;
    
    // Clear tables found
    tables = 0;
    
    // Clear all programs that could have been found during step
    [stepPrograms removeAllObjects];
}

- (void)clearScanSupportVariables
{
    [self clearStepSupportVariables];
    
    // set initial frequency to 0
    frequency = 0;
    
    // Clear all programs that could have been found during scan
    [programs removeAllObjects];
}

- (void)commitData
{
    if (tables == (PAT | SDT | PMT)) { // We have all the information required for the listed programs
        // Notify delegate about each program found
        for (NSNumber *key in stepPrograms) {
            ALiProgram *program = [stepPrograms objectForKey:key];
            
            // Copy program to persisten programs dictionnary
            [programs setObject:program forKey:[NSNumber numberWithUnsignedInt:[program uid]]];
            
            // Make sure this program contains audio or video
            if (![program containsVideo] && ![program containsAudio])
                continue;
            
            // Notify UI that we found a program
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate foundProgram:self program:(ALiProgram *)program];
            });
        }
    }
    
    // Delete all potential temporary programs that where found
    [stepPrograms removeAllObjects];
}

- (void)requestSetup:(NSString *)url
{
    // Update status
    [self updateState:SCAN_SETUP_REQUEST];
    
    [session setup:url];
}

- (void)requestPlay
{
    [self requestPlay:session.url doChangeFrequency:NO];
}

- (void)requestPlay:(NSString *)url doChangeFrequency:(BOOL)doChangeFrequency
{
    // Update asking for new stream
    changingFrequency = doChangeFrequency;
    
    // Update status
    [self updateState:SCAN_PLAY_REQUEST];
    
    // Pause socket reception
    [session pauseReception];
    
    [session play:url];
}

- (void)requestOptions
{
    dispatch_async(scanProcessingQueue, ^{
        [session options];
    });
}

- (void)requestTeardown
{
    // Update status
    [self updateState:SCAN_TEARDOWN_REQUEST];
    
    // Stop timer that maintains session alive
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sessionTimer != nil) {
            [sessionTimer invalidate];
            sessionTimer = nil;
        }
    });
    
    [session teardown];
}

- (NSString *)statusToString:(ScanStatus)status
{
    switch (status) {
        case SCAN_IDLE:
            return @"SCAN_IDLE";
            break;
        case SCAN_START_REQUEST:
            return @"SCAN_START_REQUEST";
            break;
        case SCAN_STEP_REQUEST:
            return @"SCAN_STEP_REQUEST";
            break;
            
        case SCAN_STOP_REQUEST:
            return @"SCAN_STOP_REQUEST";
            break;
        case SCAN_TEARDOWN_REQUEST:
            return @"SCAN_TEARDOWN_REQUEST";
            break;
        case SCAN_TEARDOWN_DONE:
            return @"SCAN_TEARDOWN_DONE";
            break;
            
        case SCAN_SETUP_REQUEST:
            return @"SCAN_SETUP_REQUEST";
            break;
        case SCAN_SETUP_DONE:
            return @"SCAN_SETUP_DONE";
            break;
            
        case SCAN_LOCK_TIMEOUT:
            return @"SCAN_LOCK_TIMEOUT";
            break;
        case SCAN_PAT_TIMEOUT:
            return @"SCAN_PAT_TIMEOUT";
            break;
        case SCAN_STEP_TIMEOUT:
            return @"SCAN_STEP_TIMEOUT";
            break;
            
        case SCAN_PLAY_REQUEST:
            return @"SCAN_PLAY_REQUEST";
            break;
        case SCAN_PLAY_DONE:
            return @"SCAN_PLAY_DONE";
            break;
        case SCAN_RX_NSTREAM:
            return @"SCAN_RX_NSTREAM";
            break;
            
        case SCAN_UNLOCKED:
            return @"SCAN_UNLOCKED";
            break;
        case SCAN_LOCKED:
            return @"SCAN_LOCKED";
            break;
        case SCAN_PAT_FOUND:
            return @"SCAN_PAT_FOUND";
            break;
        case SCAN_PMT_FOUND:
            return @"SCAN_PMT_FOUND";
            break;
        case SCAN_SDT_FOUND:
            return @"SCAN_SDT_FOUND";
            break;
        case SCAN_STEP_COMPLETE:
            return @"SCAN_STEP_COMPLETE";
            break;
    }
}

- (void)updateState:(ScanStatus)status
{
//    fprintf(stderr, "- %d -> %d -\n", _scanStatus, status);
    if ((_scanStatus == SCAN_PLAY_REQUEST) && (status == SCAN_STEP_COMPLETE)) {
        NSLog(@"Special case I don't understand yet");
    }
    
    if ((status == SCAN_STEP_TIMEOUT) || (_scanStatus == SCAN_STEP_TIMEOUT) || (status == SCAN_STOP_REQUEST)) {
        // This is an exception let it go
        // ...
    } else {
        
        // Check if it is allowed to come from the current state to the requested state
        switch (_scanStatus) {
            case SCAN_IDLE:
                NSAssert(status == SCAN_START_REQUEST,
                         @"Trying to go from SCAN_IDLE to %@", [self statusToString:status]);
                break;
            case SCAN_START_REQUEST:
                NSAssert(status == SCAN_SETUP_REQUEST,
                         @"Trying to go from SCAN_START_REQUEST to %@", [self statusToString:status]);
                break;
            case SCAN_STEP_REQUEST:
                NSAssert((status == SCAN_PLAY_REQUEST) || (status == SCAN_STOP_REQUEST),
                         @"Trying to go from SCAN_STEP_REQUEST to %@", [self statusToString:status]);
                break;
                
            case SCAN_STOP_REQUEST:
                NSAssert(status == SCAN_TEARDOWN_REQUEST,
                         @"Trying to go from SCAN_STOP_REQUEST to %@", [self statusToString:status]);
                break;
            case SCAN_TEARDOWN_REQUEST:
                NSAssert(status == SCAN_TEARDOWN_DONE,
                         @"Trying to go from SCAN_TEARDOWN_REQUEST to %@", [self statusToString:status]);
                break;
            case SCAN_TEARDOWN_DONE:
                NSAssert(status == SCAN_IDLE,
                         @"Trying to go from SCAN_TEARDOWN_DONE to %@", [self statusToString:status]);
                break;
                
            case SCAN_SETUP_REQUEST:
                NSAssert(status == SCAN_SETUP_DONE,
                         @"Trying to go from SCAN_SETUP_REQUEST to %@", [self statusToString:status]);
                break;
            case SCAN_SETUP_DONE:
                NSAssert(status == SCAN_PLAY_REQUEST,
                         @"Trying to go from SCAN_SETUP_DONE to %@", [self statusToString:status]);
                break;
                
            case SCAN_LOCK_TIMEOUT:
                NSAssert(status == SCAN_STEP_REQUEST,
                         @"Trying to go from SCAN_LOCK_TIMEOUT to %@", [self statusToString:status]);
                break;
            case SCAN_PAT_TIMEOUT:
                NSAssert(status == SCAN_STEP_REQUEST,
                         @"Trying to go from SCAN_PAT_TIMEOUT to %@", [self statusToString:status]);
                break;
                
            case SCAN_PLAY_REQUEST:
                NSAssert(status == SCAN_PLAY_DONE,
                         @"Trying to go from SCAN_PLAY_REQUEST to %@", [self statusToString:status]);
                break;
            case SCAN_PLAY_DONE:
                NSAssert((status == SCAN_RX_NSTREAM) || (status == SCAN_UNLOCKED),
                         @"Trying to go from SCAN_PLAY_DONE to %@", [self statusToString:status]);
                break;
            case SCAN_RX_NSTREAM:
                NSAssert(status == SCAN_UNLOCKED,
                         @"Trying to go from SCAN_PLAY_DONE to %@", [self statusToString:status]);
                break;
                
            case SCAN_UNLOCKED:
                NSAssert((status == SCAN_LOCKED) || (status == SCAN_LOCK_TIMEOUT) || (status == SCAN_PAT_FOUND) || (status == SCAN_STEP_COMPLETE),
                         @"Trying to go from SCAN_UNLOCKED to %@", [self statusToString:status]);
                break;
            case SCAN_LOCKED:
                NSAssert((status == SCAN_UNLOCKED) || (status == SCAN_PAT_FOUND) || (status == SCAN_PAT_TIMEOUT) || (status == SCAN_STEP_COMPLETE),
                         @"Trying to go from SCAN_LOCKED to %@", [self statusToString:status]);
                break;
            case SCAN_PAT_FOUND:
                NSAssert((status == SCAN_STEP_COMPLETE) || (status == SCAN_PLAY_REQUEST) || (status == SCAN_UNLOCKED) || (status == SCAN_PAT_FOUND),
                         @"Trying to go from SCAN_PAT_FOUND to %@", [self statusToString:status]);
                break;
            case SCAN_PMT_FOUND:
                break;
            case SCAN_SDT_FOUND:
                break;
            case SCAN_STEP_COMPLETE:
                NSAssert(status == SCAN_STEP_REQUEST,
                         @"Trying to go from SCAN_STEP_COMPLETE to %@", [self statusToString:status]);
                break;
                
            default:
                break;
        }
        
    }
    
    // Log
//    NSLog(@"Status: %@", [self statusToString:status]);
    
    // Assign new status
    _scanStatus = status;
}





- (void)dealloc
{
    // Release RTSP session
    session = nil;
}

- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency
{
    // Create and init scan processing queue
    scanProcessingQueue = dispatch_queue_create("com.tw.ali.scan", NULL);
    
    return [self initWithServer:server
                 startFrequency:startFrequency
                  stepFrequency:stepFrequency
                  stopFrequency:stopFrequency
                processingQueue:scanProcessingQueue];
}

- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency
     processingQueue:(dispatch_queue_t)processingQueue
{
    // Set processing queue
    scanProcessingQueue = processingQueue;
    
    // Init previous state
    previousState = SCAN_IDLE;
    
    // Init session lock
    lock = [[NSLock alloc] init];
    
    // Init asking for new stream indicator
    changingFrequency = YES;
    
    // Set the server
    _server = server;
    
    // Set start frequency
    _startFrequency = startFrequency;
    
    // Set step frequency
    _stepFrequency = stepFrequency;
    
    // Set stop frequency
    _stopFrequency = stopFrequency;
    
    // Init step status
    _scanStatus = SCAN_IDLE;
    
    // Init RTSP session
    session = [[ALiRTSPSession alloc] initWithServer:_server
                                                 url:@""
                                       delegateQueue:scanProcessingQueue
                                        rtcpDelegate:self
                                         rtpDelegate:self];
    session.delegate = self;
    
    // Set frequency
    frequency = 0.0;
    
    // Init programs dictionaries
    stepPrograms = [[NSMutableDictionary alloc] initWithCapacity:0];
    programs = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Init scan pids array
    scanPids = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Init locked status
    locked = NO;
    
    // Init lock timer
    lockTimer = nil;
    
    // Init PAT timer
    patTimer = nil;
    
    // Init session timer
    sessionTimer = nil;
    
    // Init handlers array
    handlers = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Init demuxer
    demuxer = [[ALiDemuxer alloc] init];
    
    // Init tables
    tables = 0;
    
    // Init SSRC
    currentSsrc = 0;
    
    return self;
}

- (void)start
{
    dispatch_async(scanProcessingQueue, ^{
        
        // Update status
        [self updateState:SCAN_START_REQUEST];
        
        // Reset all scan support variables
        [self clearScanSupportVariables];
        
        // Initialize with start frequency
        frequency = _startFrequency;
        
        NSLog(@"=========================================");
        NSLog(@"Frequency: %f", frequency);
        
        // Get current url
        NSString *url = [self toUrl:RTSP host:_server.device.address purpose:SCAN];
        
        // Setup session
        [self requestSetup:url];
        
        // Start step timeout timer
        [self startStepTimeout];
    });
}

- (void)stop
{
    dispatch_async(scanProcessingQueue, ^{
        
        // Update status
        [self updateState:SCAN_STOP_REQUEST];
        
        // Request the session to be teared down
        [self requestTeardown];
    });
}

- (void)step
{
    dispatch_async(scanProcessingQueue, ^{
        
        // Pause RTP & RTCP reception
        [session pauseReception];
        
        // Update status
        [self updateState:SCAN_STEP_REQUEST];
        
        // Clear step variables
        [self clearStepSupportVariables];
        
        // Increment frequency
        frequency += _stepFrequency;
        
        // If current frequency is bigger than stop frequency then it is time to stop
        if (frequency > _stopFrequency) {
            NSLog(@"=========================================");
            NSLog(@"Scan done");
            NSLog(@"=========================================");
            
            // Notify delegate than scan is done however user of scan class will have to wait for scan to be stopped
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate done:self];
            });
            
            // We're done so stop scan
            [self stop];
            
            return;
        }
        
        NSLog(@"=========================================");
        NSLog(@"Frequency: %f", frequency);
        
        // Get current url
        NSString *url = [self toUrl:RTSP host:_server.device.address purpose:SCAN];
        
        // Start playing new URL
        [self requestPlay:url doChangeFrequency:YES];
        
        // Start step timeout timer
        [self startStepTimeout];
        
    });
}

#pragma mark - RTSP Session Delegate

- (void)sessionSetup:(ALiRTSPSession *)sess
{
//    NSLog(@"Session setup!");
    
    // Update status
    [self updateState:SCAN_SETUP_DONE];
    
    // Start timer to maintain session alive
    dispatch_async(dispatch_get_main_queue(), ^{
        sessionTimer = [NSTimer scheduledTimerWithTimeInterval:sess.sessionTimeout
                                                        target:self
                                                      selector:@selector(requestOptions)
                                                      userInfo:nil
                                                       repeats:YES];
    });
    
    // Start playing the session
    [self requestPlay:sess.url doChangeFrequency:YES];
}

- (void)sessionPlaying:(ALiRTSPSession *)sess
{
//    NSLog(@"Session playing!");
    
    // Update status
    [self updateState:SCAN_PLAY_DONE];
    
    // Start reception of RTCP packets
    [session resumeRTCPReception];
    
    // If not asking for a new stream then just go to unlock state
    if (!changingFrequency) {
        // Force set to unlock
        [self setUnlocked:YES];
    }
}

- (void)sessionOptionsDone:(ALiRTSPSession *)sess
{
//    NSLog(@"Session options done!");
}

- (void)sessionTeardowned:(ALiRTSPSession *)sess
{
//    NSLog(@"Session teared down!");
    
    // Update status
    [self updateState:SCAN_TEARDOWN_DONE];
    
    // Cleanning scan support variables
    [self clearScanSupportVariables];
    
    // Notify delegate than the scan is now stopped
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate stopped:self];
    });
}

- (void)error:(NSString *)errorMessage
{
}

#pragma mark - RTCP Socket Delegate

- (void)reportAvailable:(ALiRTCPSocket *)rtcpSocket report:(ALiRTCPReport *)report
{
    // Check if we are in a status that allows us to receive data
    if (_scanStatus < SCAN_PLAY_DONE)
        return;
    
    // Extract data array from report
    NSArray *tunerData = [[report.arguments objectForKey:@"tuner"] componentsSeparatedByString:@","];
    
    /*
    NSLog(@"#########################################");
    NSLog(@"RTCP Report");
    NSLog(@"SSRC: %u", report.ssrc);
    NSLog(@"RTP time stamp: %u", report.rtpTimeStamp);
    NSLog(@"NTP time stamp: %llu", report.ntpTimeStamp);
    NSLog(@"Front end ID: %d", [tunerData[TUNER_PARAM_FEID] intValue]);
    NSLog(@"Lock status: %d", [tunerData[TUNER_PARAM_LOCK] boolValue]);
    NSLog(@"Signal level: %d", [tunerData[TUNER_PARAM_LVEL] intValue]);
    NSLog(@"Signal quality: %d", [tunerData[TUNER_PARAM_QUAL] intValue]);
    NSLog(@"Frequency: %d", [tunerData[TUNER_PARAM_FREQ] intValue]);
    */
    
    // if changingFrequency is set then check if we are receiving the new stream
    if (changingFrequency) {
        if (frequency != [tunerData[TUNER_PARAM_FREQ] intValue])
            return;
        
        // From now on we are receiving the new stream
        changingFrequency = NO;
        
        // Assign current ssrc value
        currentSsrc = report.ssrc;
        
        // Update status
        [self setReceivingNewStream];
        
        return;
    }
    
    // Check if we are in a status that allows us to receive data
    if (_scanStatus < SCAN_RX_NSTREAM)
        return;
    
    // Ignore packets that do not belong to current SSRC
    if (currentSsrc != report.ssrc) {
//        NSLog(@"Packet does not belong to current SSRC -> ignored!");
        return;
    }
    
    // check on lock status
    if ([tunerData[TUNER_PARAM_LOCK] boolValue] && !locked)
        [self setLocked];
    else if (![tunerData[TUNER_PARAM_LOCK] boolValue] && locked)
        [self setUnlocked];
}

#pragma mark - RTP Socket Delegate

- (void)packetsAvailable:(ALiRTPSocket *)socket packets:(NSArray *)packets header:(const RtpHeader *)header
{
    // Check if we are in a status that allows us to receive data
    if (_scanStatus < SCAN_LOCKED)
        return;
    
    // Ignore packets that do not belong to current SSRC
    if (currentSsrc != header->ssrc) {
//        NSLog(@"Packet does not belong to current SSRC -> ignored!");
        return;
    }
    
    // Check that the array contains packets
    if (![packets count])
        return;
    
//    NSLog(@"Time stamp: %u", CFSwapInt32(header->ts));
    
    // Push packets to demuxer
    [demuxer push:packets];
}

#pragma mark - PAT, SDT, PMT Handler Delegates

- (void)foundPAT:(ALiPatHandler *)patHandler
{
    // Invalidate runing timers
    [self killTimers];
    
    // Log
    NSLog(@"+ Found a PAT for TS ID %d! @ %f MHz", patHandler.originalNetworkID, frequency);
    
    // Go through all PMTs to test if any of them has already been found
    BOOL hasDuplicate = NO;
    for (NSNumber *key in patHandler.programs) {
        ALiPatProgram *program = [patHandler.programs objectForKey:key];
        UInt32 uid = [program uid];
//        NSLog(@"UID: 0x%08x", uid);
        ALiProgram *tmp = [programs objectForKey:[NSNumber numberWithUnsignedInt:uid]];
        if (tmp != nil) {
            NSLog(@"| Duplicate %d PID 0x%04x (%d)", program.number, program.pid, program.pid);
            hasDuplicate = YES;
        }
    }
    if (hasDuplicate) {
        NSLog(@"- The PAT contains duplicated programs dismiss it!");
        return;
    }
    
    // Go through all PMTs
    for (NSNumber *key in patHandler.programs) {
        ALiPatProgram *program = [patHandler.programs objectForKey:key];
        NSLog(@"| %d PID 0x%04x (%d)", program.number, program.pid, program.pid);
        if (program.number) {
            // Create a program for each PMT
            ALiProgram *prgm = [[ALiProgram alloc] initWithFrequency:frequency
                                                           bandwidth:8
                                                                tsId:patHandler.originalNetworkID
                                                              number:program.number
                                                                 pid:program.pid];
            [stepPrograms setObject:prgm forKey:[NSNumber numberWithUnsignedShort:prgm.number]];
            
            // Create a PMT handler for each PMT
            ALiPmtHandler *pmtHandler = [[ALiPmtHandler alloc] initWithProgramNumber:program.number];
            [pmtHandler attach];
            pmtHandler.delegate = self;
            [demuxer addPidHandler:program.pid handler:pmtHandler];
            [handlers addObject:pmtHandler];
            
            // Add PID to scan PIDs
            [scanPids addObject:[NSString stringWithFormat:@"%d", program.pid]];
        }
    }
    
    // Remove PAT handler from handlers list and demuxer
    [patHandler dettach];
    [demuxer removePidHandler:patHandler];
//    [handlers removeObject:patHandler];
    
    // Update status
    [self updateState:SCAN_PAT_FOUND];
    
    // Take notes that we found a PAT
    tables |= PAT;

    // A PAT was found so we can create an sdt handler
    ALiSdtHandler *sdtHandler = [[ALiSdtHandler alloc] initWithWhichTs:CurrentTs];
    [sdtHandler attach];
    sdtHandler.delegate = self;
    [demuxer addPidHandler:0x11 handler:sdtHandler];
    [handlers addObject:sdtHandler];
    
    // Update RTSP request with the new PIDs
    [self requestPlay:[self toUrl:RTSP host:_server.device.address purpose:SCAN] doChangeFrequency:NO];

    [self checkDone];
}

- (void)foundSDT:(ALiSdtHandler *)sdtHandler
{
    // Remove PMT handler from handlers list and demuxer
    [sdtHandler dettach];
    [demuxer removePidHandler:sdtHandler];
//    [handlers removeObject:sdtHandler];
    
    // Log
    NSLog(@"+ Found an SDT!");
    
    // Take notes that we found an SDT
    tables |= SDT;
    
    // Update information for each program
    for (NSNumber *key in sdtHandler.services) {
        ALiSdtService *service = [sdtHandler.services objectForKey:key];
        ALiProgram *program = [stepPrograms objectForKey:[NSNumber numberWithUnsignedShort:service.serviceId]];
        if (program != nil) {
            program.serviceProviderName = service.serviceProviderName;
            program.serviceName = service.serviceName;
            NSLog(@"| %@", program.serviceName);
        } else {
            NSLog(@"| Missing program associated to %@", service.serviceName);
        }
    }
    
    [self checkDone];
}

- (void)foundPMT:(ALiPmtHandler *)pmtHandler
{
    // Remove PMT handler from handlers list and demuxer
    [pmtHandler dettach];
    [demuxer removePidHandler:pmtHandler];
//    [handlers removeObject:pmtHandler];
    
    // Extract corresponding program
    ALiProgram *program = [stepPrograms objectForKey:[NSNumber numberWithUnsignedShort:pmtHandler.programNumber]];
    
    // Log
    NSLog(@"+ Found a PMT %d 0x%04x (%d)!", program.number, program.pid, program.pid);
    
    // Update information for each program
    if (program != nil) {
        program.pcrPid = pmtHandler.pcrPid;
        for (NSNumber *key in pmtHandler.elementaryStreams) {
            ALiPmtElementaryStream *es = [pmtHandler.elementaryStreams objectForKey:key];
            [program.elementaryStreams setObject:es forKey:[NSNumber numberWithUnsignedShort:es.pid]];
            NSLog(@"| PID 0x%04x (%d) - %d", es.pid, es.pid, es.type);
        }
    }
    
    [self checkDone];
}

@end
