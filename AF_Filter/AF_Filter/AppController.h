//
//  AppController.h
//  AF_Filter
//
//  Created by Jared Bruni on 10/20/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject {
    IBOutlet NSImageView *image_view;
    IBOutlet NSSlider *slider, *slider_red, *slider_green, *slider_blue;
    IBOutlet NSTextField *slider_pos, *slider_red_pos, *slider_green_pos, *slider_blue_pos;
    NSImage *current_image;
    IBOutlet NSPopUpButton *filter_selector;
    IBOutlet NSButton *check_box, *reverse_box, *opposite_dir;
    IBOutlet NSPopUpButton *rgb_box;
}

- (IBAction) selectImage: (id) sender;
- (IBAction) saveImage: (id) sender;
- (IBAction) changePosition: (id) sender;
- (NSImage *) applyFilter: (long) pos;
- (IBAction) changeSlider: (id) sender;
- (IBAction) changeFilter: (id) sender;
- (IBAction) copyToClipboard: (id) sender;
- (IBAction) setAsSource: (id) sedner;
- (IBAction) setPasteboardAsSource: (id) sender;
- (IBAction) shareAF_Filter: (id) sender;
- (IBAction) sliderEnter: (id) sender;
@end
