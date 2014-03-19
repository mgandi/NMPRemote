//
//  ALiPlaybackTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 19/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPlaybackTableViewController.h"

@interface ALiPlaybackTableViewController ()

@end

@implementation ALiPlaybackTableViewController
{
    NSArray *urls;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    urls = @[@"http://playready.directtaps.net/smoothstreaming/SSWSS720H264/SuperSpeedway_720.ism/Manifest",
             @"http://ecn.channel9.msdn.com/o9/content/smf/smoothcontent/elephantsdream/Elephants_Dream_1024-h264-st-aac.ism/manifest",
             @"http://live.iphone.redbull.de.edgesuite.net/webtvHD.m3u8",
             @"http://media.ndr.de/progressive/2013/0518/TV-20130518-2147-1142.hq.mp4",
             @"http://www.tv2next.com/code/streams/bugfixing/tri849x_v242_audio/gaga-720p.mp4",
             @"http://webtvstreaming.redbull.com/videodownload/webtv/710858724001/710858724001_1587406593001_MI201109140183-video-newsroom-hd-1080-p29-97-channelSelectionT0C0-T0C1.mp4"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    [self.dongle playback:_urlTextField.text];
}

- (IBAction)stop:(id)sender
{
    [_dongle stopPlayback];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
        return;
    
    
    // Deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Replace text of URL
    _urlTextField.text = (urls)[indexPath.row];
}

@end
