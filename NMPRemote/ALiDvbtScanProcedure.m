//
//  ALiDvbtScanProcedure.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDvbtScanProcedure.h"
#import "ALiDemuxer.h"
#import "ALiProgram.h"

#define LOCK_TIMEOUT    3
#define PAT_TIMEOUT     10

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

@implementation ALiDvbtScanProcedure
{
    ALiRTSPSession *session;
    ALiDemuxer *demuxer;
    
    // Scan support variables
    double frequency;
    NSMutableDictionary *programs;
    
    // Step support variables
    NSMutableArray *scanPids;
    BOOL locked;
    NSTimer *lockTimer, *patTimer;
    NSMutableArray *handlers;
    TableType tables;
    UInt32 lastSsrc;
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
    if (session.status != IDLE) {
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
    [session teardown];
    session = nil;
}

- (void)startLockTimeoutTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Start lock timeout timer!");
        lockTimer = [NSTimer scheduledTimerWithTimeInterval:LOCK_TIMEOUT target:self selector:@selector(lockTimeout) userInfo:nil repeats:FALSE];
    });
}

- (void)startPatTimeoutTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Start PAT timeout timer!");
        patTimer = [NSTimer scheduledTimerWithTimeInterval:PAT_TIMEOUT target:self selector:@selector(patTimeout) userInfo:nil repeats:FALSE];
    });
}

- (void)killTimers
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (lockTimer != nil) {
            NSLog(@"Stop lock timeout timer!");
            [lockTimer invalidate];
            lockTimer = nil;
        }
        
        if (patTimer != nil) {
            NSLog(@"Stop PAT timeout timer!");
            [patTimer invalidate];
            patTimer = nil;
        }
    });
}

- (void)lockTimeout
{
//    NSLog(@"=========================================");
    NSLog(@"Lock timeout! (%f MHz)", frequency);
    [self step];
}

- (void)patTimeout
{
//    NSLog(@"=========================================");
    NSLog(@"PAT timeout! (%f MHz)", frequency);
    [self step];
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
    // If already locked do nothing
    if (locked)
        return;
    
    //    NSLog(@"=========================================");
    NSLog(@"Locked!");
    
    // Invalidate timers
    [self killTimers];
    
    // Set status as locked
    locked = YES;
    
    // Check if a PAT handler already exists and if not create one
    ALiPatHandler *patHandler = nil;
    for (ALiPidHandler *handler in handlers) {
        if ([handler isKindOfClass:[ALiPatHandler class]]) {
            patHandler = (ALiPatHandler *)handler;
            break;
        }
    }
    if (patHandler == nil) {
        patHandler = [[ALiPatHandler alloc] init];
        patHandler.delegate = self;
        [demuxer addPidHandler:0x0 handler:patHandler];
        [handlers addObject:patHandler];
    }
    
    // Attach all handlers
    [self attachHandlers];
    
    // Start PAT timeout timer if PAT has not been yet found
    if (!(tables & PAT)) {
        [self startPatTimeoutTimer];
    }
}

- (void)setUnlocked
{
    // If already unlocked do nothing
    if (!locked)
        return;
    
    //    NSLog(@"=========================================");
    NSLog(@"Unlocked!");
    
    // Invalidate timers
    [self killTimers];
    
    // Detach all handlers
    [self dettachHandlers];
    
    // Set status as unlocked
    locked = NO;
    
    // Re-launch lock timeout timer
    [self startLockTimeoutTimer];
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
    
//    NSLog(@"=========================================");
    if (allPmtTriggered && hasPmtHandler) {
        tables |= PMT;
    } else {
        if (!allPmtTriggered) {
            NSLog(@"Not all PMT have been seen yet!");
        }
        if (!hasPmtHandler) {
            NSLog(@"No PMT handlers created!");
        }
    }
    
    if (tables == (PAT | SDT | PMT)) {
        NSLog(@"Got all information");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self step];
        });
    } else {
        if (!(tables & PAT)) {
            NSLog(@"No PAT found!");
        }
        if (!(tables & SDT)) {
            NSLog(@"No SDT found!");
        }
    }
}

- (void)clearStepSupportVariables
{
    // Kill all runing timers
    [self killTimers];
    
     // Deatach all handlers
    [self dettachHandlers];
    
    // Remove all handlers from demuxer
    [demuxer removeAllPidHandlers];
    
    // Delete all handlers and clear handlers container
    [handlers removeAllObjects];
    
    // Commit temporary data if any
    //    [self commitData];
    
    // Update SSRC
    lastSsrc = currentSsrc;
    currentSsrc = 0;
    
    // Clear scan pids container
    [scanPids removeAllObjects];
    
    // Force lock state to false
    locked = FALSE;
    
    // Clear tables found
    tables = 0;
}

- (void)clearScanSupportVariables
{
    [self clearStepSupportVariables];
    
    // set initial frequency to 0
    frequency = 0;
    
    // Clear all programs that could have been found
    [programs removeAllObjects];
}


- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency
{
    // Set the server
    _server = server;
    
    // Set start frequency
    _startFrequency = startFrequency;
    
    // Set step frequency
    _stepFrequency = stepFrequency;
    
    // Set stop frequency
    _stopFrequency = stopFrequency;
    
    // Init RTSP session
    session = nil;
    
    // Set frequency
    frequency = 0.0;
    
    // Init programs dictionary
    programs = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Init scan pids array
    scanPids = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Init locked status
    locked = NO;
    
    // Init lock timer
    lockTimer = nil;
    
    // Init PAT timer
    patTimer = nil;
    
    // Init handlers array
    handlers = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Init demuxer
    demuxer = [[ALiDemuxer alloc] init];
    
    // Init tables
    tables = 0;
    
    // Init SSRC referer
    lastSsrc = 0;
    currentSsrc = 0;
    
    return self;
}

- (void)start
{
    [self clearScanSupportVariables];
    [self step];
}

- (void)stop
{
    [self deleteSession];
    [self killTimers];
    [self clearScanSupportVariables];
}

- (void)step
{
    // Clear step variables
    [self clearStepSupportVariables];
    
    // Compute current frequency
    if (frequency == 0.0) { // Initialize with start frequency
        frequency = _startFrequency;
    } else { // Increment frequency
        frequency += _stepFrequency;
    }
    
    // If current frequency is bigger than stop frequency then it is time to stop
    if (frequency > _stopFrequency) {
        [self stop];
        return;
    }
    
    
    NSLog(@"=========================================");
    NSLog(@"Frequency: %f", frequency);
    
    // Get current url
    NSString *url = [self toUrl:RTSP host:_server.device.address purpose:SCAN];
    
    // If session is nil create it
    if (session == nil) {
        session = [[ALiRTSPSession alloc] initWithServer:_server url:url rtcpDelegate:self rtpDelegate:self];
        session.delegate = self;
        [session setup];
    } else {
        [session play:url];
    }
}

#pragma mark - RTSP Session Delegate

- (void)sessionSetup:(ALiRTSPSession *)sess
{
    // Start playing the session
    [session play];
}

- (void)sessionPlaying:(ALiRTSPSession *)sess
{
    // Launch lock timeout timer
    [self startLockTimeoutTimer];
}

- (void)sessionTeardowned:(ALiRTSPSession *)sess
{
}

- (void)error:(NSString *)errorMessage
{
}

#pragma mark - RTCP Socket Delegate

- (void)reportAvailable:(ALiRTCPSocket *)rtcpSocket report:(ALiRTCPReport *)report
{
    static ALiRTCPReport *lastReport;
    
    NSArray *tunerData = [[report.arguments objectForKey:@"tuner"] componentsSeparatedByString:@","];
    
    // Make sure that we don't treat packet from previous frequency
    // TODO: Find a way to base it on SSRC
    if (frequency != [tunerData[TUNER_PARAM_FREQ] intValue]) {
//        NSLog(@"=========================================");
//        NSLog(@"RTCP Report from last SSRC (%d) -> ignored!", report.ssrc);
    }
    
    // Print report and assign current reoprt to last report
    if (report == lastReport) {
    } else {
//        NSLog(@"=========================================");
//        NSLog(@"RTCP Report");
//        NSLog(@"SSRC: %d", report.ssrc);
//        NSLog(@"Front end ID: %d", [tunerData[TUNER_PARAM_FEID] intValue]);
//        NSLog(@"Lock status: %d", [tunerData[TUNER_PARAM_LOCK] boolValue]);
//        NSLog(@"Signal level: %d", [tunerData[TUNER_PARAM_LVEL] intValue]);
//        NSLog(@"Signal quality: %d", [tunerData[TUNER_PARAM_QUAL] intValue]);
//        NSLog(@"Frequency: %d", [tunerData[TUNER_PARAM_FREQ] intValue]);
        lastReport = report;
    }
    
    // check on lock status
    if ([tunerData[TUNER_PARAM_LOCK] boolValue] && !locked)
        [self setLocked];
    else if (![tunerData[TUNER_PARAM_LOCK] boolValue] && locked)
        [self setUnlocked];
}

#pragma mark - RTP Socket Delegate

- (void)packetsAvailable:(ALiRTPSocket *)socket packets:(NSArray *)packets ssrc:(const UInt32)ssrc
{
    if (currentSsrc == 0) {
        if (lastSsrc == ssrc) {
//            NSLog(@"=========================================");
//            NSLog(@"Packet from last SSRC (%d) -> ignored!", ssrc);
            return;
        } else
            currentSsrc = ssrc;
    }
    [demuxer push:packets];
}

#pragma mark - PAT, SDT, PMT Handler Delegeates

- (void)discontinuity:(ALiPidHandler *)pidHandler
{
}

- (void)foundPAT:(ALiPatHandler *)patHandler
{
//    NSLog(@"=========================================");
    NSLog(@"Found a PAT for TS ID %d! @ %f MHz", patHandler.originalNetworkID, frequency);
    
    // Invalidate runing timers
    [self killTimers];
    
    // Take notes that we found a PAT
    tables |= PAT;

    // A PAT was found so we can create an sdt handler
    ALiSdtHandler *sdtHandler = [[ALiSdtHandler alloc] initWithWhichTs:CurrentTs];
    [sdtHandler attach];
    sdtHandler.delegate = self;
    [demuxer addPidHandler:0x11 handler:sdtHandler];
    [handlers addObject:sdtHandler];

    // Go through all PMT
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
            [programs setObject:prgm forKey:[NSNumber numberWithUnsignedShort:prgm.number]];
            
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
    
    // Update RTSP request with the new PIDs
    [session play:[self toUrl:RTSP host:_server.device.address purpose:SCAN]];

    [self checkDone];
}

- (void)foundSDT:(ALiSdtHandler *)sdtHandler
{
//    NSLog(@"=========================================");
    NSLog(@"Found an SDT!");
    
    // Take notes that we found an SDT
    tables |= SDT;
    
    // Update information for each program
    for (NSNumber *key in sdtHandler.services) {
        ALiSdtService *service = [sdtHandler.services objectForKey:key];
        ALiProgram *program = [programs objectForKey:[NSNumber numberWithUnsignedShort:service.serviceId]];
        if (program != nil) {
            program.serviceProviderName = service.serviceProviderName;
            program.serviceName = service.serviceName;
            NSLog(@"%@", program.serviceName);
        }
    }
    
    [self checkDone];
}

- (void)foundPMT:(ALiPmtHandler *)pmtHandler
{
//    NSLog(@"=========================================");
    NSLog(@"Found an PMT!");
    
    // Update information for each program
    ALiProgram *program = [programs objectForKey:[NSNumber numberWithUnsignedShort:pmtHandler.programNumber]];
    if (program != nil) {
        program.pcrPid = pmtHandler.pcrPid;
        for (NSNumber *key in pmtHandler.elementaryStreams) {
            ALiPmtElementaryStream *es = [pmtHandler.elementaryStreams objectForKey:key];
            [program.elementaryStreams setObject:es forKey:[NSNumber numberWithUnsignedShort:es.type]];
        }
    }
    
    [self checkDone];
}

@end
