//
//  AppController.m
//  AF_Filter
//
//  Created by Jared Bruni on 10/20/13.
//  Copyright (c) 2013 Jared Bruni. All rights reserved.
//

#import "AppController.h"

int current_filter = 0;
int bytesPerSample = 0;
int bytesPerRow = 0;
int width = 0;
int height = 0;
int red = 0;
int green = 0;
int blue = 0;
int offset = 0;
int randomNumber = 0;

void changePixel(unsigned char *full_buffer, BOOL negate, NSInteger reverse, int i, int z, unsigned char *buffer, long pos, float *count) {
    switch(current_filter) {
    case 0:
        {
            float value = pos;
            buffer[0] = (unsigned char) value*buffer[0];
            buffer[1] = (unsigned char) value*buffer[1];
            buffer[2] = (unsigned char) value*buffer[2];
        }
        break;
    case 1:
        {
            
            float value = pos;
            buffer[0] = (unsigned char) value*buffer[0];
            buffer[1] = (unsigned char) (-value)*buffer[1];
            buffer[2] = (unsigned char) value*buffer[2];
        }
        break;
    case 2:
        {
            buffer[0] += buffer[0]*-pos;
            buffer[1] += buffer[1]*pos;
            buffer[2] += buffer[2]*-pos;
        }
        break;
    case 3:
        {
            int current_pos = pos*0.2f;
            buffer[0] = (i*current_pos)+buffer[0];
            buffer[2] = (z*current_pos)+buffer[2];
            buffer[1] = (current_pos*buffer[1]);
        }
        break;
    case 4:
        {
            int current_pos = pos*0.2f;
            buffer[0] = (z*current_pos)+buffer[0];
            buffer[1] = (i*current_pos)+buffer[1];
            buffer[2] = ((i+z)*current_pos)+buffer[2];
        }
        break;
    case 5:
        {
            int current_pos = pos*0.2f;
            buffer[0] = -(z*current_pos)+buffer[0];
            buffer[1] = -(i*current_pos)+buffer[1];
            buffer[2] = -((i+z)*current_pos)+buffer[2];
        }
        break;
            
    case 6:
    {
            int zq = z+1, iq = i+1;
            if(zq > height-1 || iq > width-1) return;
            unsigned char *temp = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            buffer[0] += (i*pos)+temp[0];
            buffer[1] += (z*pos)+temp[1];
            buffer[2] += (i/(z+1))+temp[2];
    }
    break;
    case 7:
        {
            unsigned char colv[4], cola[4];
            colv[0] = buffer[0];
            colv[1] = buffer[1];
            colv[2] = buffer[2];
            cola[0] = buffer[2];
            cola[1] = buffer[1];
            cola[2] = buffer[0];
            unsigned int alpha = (int)pos;
            unsigned int red_values[] = { colv[0]+cola[2], colv[1]+cola[1], colv[2]+cola[0], 0 };
            unsigned int green_values[] = { colv[2]+cola[0], colv[1]+cola[1], colv[0]+cola[2], 0 };
            unsigned int blue_values[] = { colv[1]+cola[1], colv[0]+cola[2], colv[2]+cola[0], 0 };
            unsigned char R = 0,G = 0,B = 0;
            for(unsigned int iq = 0; iq <= 2; ++iq) {
                R += red_values[iq];
                R /= 3;
                G += green_values[iq];
                G /= 3;
                B += blue_values[iq];
                B /= 3;
            }
            buffer[0] += alpha*R;
            buffer[1] += alpha*G;
            buffer[2] += alpha*B;
            
        }
        break;
        case 8:
        {
            unsigned char colv[4], cola[4];
            colv[0] = buffer[0];
            colv[1] = buffer[1];
            colv[2] = buffer[2];
            int iq = (width-i-1);
            int zq = (height-z-1);
            unsigned char *t = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);;
            cola[0] = t[0];
            cola[1] = t[1];
            cola[2] = t[2];
            unsigned int alpha = (int)pos;
            unsigned int red_values[] = { colv[0]+cola[2], colv[1]+cola[1], colv[2]+cola[0], 0 };
            unsigned int green_values[] = { colv[2]+cola[0], colv[1]+cola[1], colv[0]+cola[2], 0 };
            unsigned int blue_values[] = { colv[1]+cola[1], colv[0]+cola[2], colv[2]+cola[0], 0 };
            unsigned char R = 0,G = 0,B = 0;
            for(unsigned int iq = 0; iq <= 2; ++iq) {
                R += red_values[iq];
                R /= 3;
                G += green_values[iq];
                G /= 3;
                B += blue_values[iq];
                B /= 3;
            }
            buffer[0] += alpha*R;
            buffer[1] += alpha*G;
            buffer[2] += alpha*B;
        }
        break;
        case 9:
        {
            float alpha = pos;
            unsigned char colorz[3][3];
            colorz[0][0] = buffer[0];
            colorz[0][1] = buffer[1];
            colorz[0][2] = buffer[2];
            int total_r = colorz[0][0] +colorz[0][1]+colorz[0][2];
            total_r /= 3;
            total_r *= alpha;
            int iq = i+1;
            if(iq > width) return;
            int zq = z;
            unsigned char *temp = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            colorz[1][0] = temp[0];
            colorz[1][1] = temp[1];
            colorz[1][2] = temp[2];
            int total_g = colorz[1][0]+colorz[1][1]+colorz[1][2];
            total_g /= 3;
            total_g *= alpha;
            buffer[0] = (unsigned char)total_r;
            buffer[1] = (unsigned char)total_g;
            buffer[2] = (unsigned char)total_r+total_g*alpha;
            
        }
        break;
        case 10:
        {
            buffer[0] = ((i+z)*pos)/(i+z+1)+buffer[0]*pos;
            buffer[1] += ((i*pos)/(z+1))+buffer[1];
            buffer[2] += ((z*pos)/(i+1))+buffer[2];
       }
        break;
        case 11:
        {
            buffer[0] += (buffer[2]+(i*pos))/(pos+1);
            buffer[1] += (buffer[1]+(z*pos))/(pos+1);
            buffer[2] += buffer[0];
        }
        break;
        case 12:
        {
            buffer[0] += (i/(z+1))*pos+buffer[0];
            buffer[1] += (z/(i+1))*pos+buffer[1];
            buffer[2] += ((i+z)/(pos+1)+buffer[2]);
        }
        break;
        case 13:
        {
            buffer[0] += (pos*(i/(pos+1))+buffer[2]);
            buffer[1] += (pos*(z/(pos+1))+buffer[1]);
            buffer[2] += (pos*((i*z)/(pos+1)+buffer[0]));
        }
        break;
        case 14:
        {
            buffer[0] = ((i+z)*pos)/(i+z+1)+buffer[0]*pos;
            buffer[1] += (buffer[1]+(z*pos))/(pos+1);
            buffer[2] += ((i+z)/(pos+1)+buffer[2]);
        }
        break;
        case 15:
        {
            buffer[0] = (i%(z+1))*pos+buffer[0];
            buffer[1] = (z%(i+1))*pos+buffer[1];
            buffer[2] = (i+z%(pos+1))+buffer[2];
        }
        break;
        case 16:
        {
            unsigned int r = 0;
            r = (buffer[0]+buffer[1]+buffer[2])/3;
            buffer[0] += pos*r;
            buffer[1] += -(pos*r);
            buffer[2] += pos*r;
        }
        break;
        case 17:
        {
            unsigned long r = 0;;
            r = (buffer[0]+buffer[1]+buffer[2])/(pos+1);
            buffer[0] += r*pos;
            r = (buffer[0]+buffer[1]+buffer[2])/3;
            buffer[1] += r*pos;
            r = (buffer[0]+buffer[1]+buffer[2])/5;
            buffer[2] += r*pos;
        }
        break;
        case 18:
        {
            buffer[0] += 1+(sinf(pos))*z;
            buffer[1] += 1+(cosf(pos))*i;
            buffer[2] += (buffer[0]+buffer[1]+buffer[2])/3;
        }
        break;
        case 19:
        {
            buffer[0] += (buffer[2]-i)*(((pos+1)%15)+2);
            buffer[1] += (buffer[1]-z)*(((pos+1)%15)+2);
            buffer[2] += buffer[0]-(i+z)*(((pos+1)%15)+2);
        }
        break;
        case 20:
        {
            buffer[0] += (buffer[0]+buffer[1]-buffer[2])/3*pos;
            buffer[1] -= (buffer[0]-buffer[1]+buffer[2])/6*pos;
            buffer[2] += (buffer[0]-buffer[1]-buffer[2])/9*pos;
        }
        break;
        case 21:
        {
            int iq = i, zq = z+1;
            if(zq > height-2) return;
            unsigned char *temp = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            zq = z+2;
            if(zq > height-2) return;
            unsigned char *temp2 = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            int ir, ig, ib;
            ir = buffer[0]+temp[0]-temp2[0];
            ig = buffer[1]-temp[1]+temp2[1];
            ib = buffer[2]-temp[2]-temp2[2];
            if(z%2 == 0) {
                if(i%2 == 0) {
                    buffer[0] = ir+(0.5*pos);
                    buffer[1] = ig+(0.5*pos);
                    buffer[2] = ib+(0.5*pos);
                } else {
                    buffer[0] = ir+(1.5*pos);
                    buffer[1] = ig+(1.5*pos);
                    buffer[2] = ib+(1.5*pos);
                }
            } else {
                if(i%2 == 0) {
                    buffer[0] += ir+(0.1*pos);
                    buffer[1] += ig+(0.1*pos);
                    buffer[2] += ib+(0.1*pos);
                } else {
                    buffer[0] -= ir+(i*pos);
                    buffer[1] -= ig+(z*pos);
                    buffer[2] -= ib+(0.1*pos);
                }
            }
        }
        break;
        case 22:
        {
            if((i%2) == 0) {
                if((z%2) == 0) {
                    buffer[0] = 1-pos*buffer[0];
                    buffer[2] = (i+z)*pos;
                } else {
                    buffer[0] = pos*buffer[0]-z;
                    buffer[2] = (i-z)*pos;
                }
            } else {
                if((z%2) == 0) {
                    buffer[0] = pos*buffer[0]-i;
                    buffer[2] = (i-z)*pos;
                } else {
                    buffer[0] = pos*buffer[0]-z;
                    buffer[2] = (i+z)*pos;
                }
            }
        }
        break;
        case 23:
        {
            buffer[0] = buffer[0]+buffer[1]*2+pos;
            buffer[1] = buffer[1]+buffer[0]*2+pos;
            buffer[2] = buffer[2]+buffer[0]+pos;
            
        }
        break;
        case 24:
        {
            buffer[0] += buffer[2]+pos;
            buffer[1] += buffer[1]+pos;
            buffer[2] += buffer[0]+pos;
        }
        break;
        case 25:
        {
            buffer[0] += (buffer[2]*pos);
            buffer[1] += (buffer[0]*pos);
            buffer[2] += (buffer[1]*pos);
        }
            break;
        case 26:
        {
            buffer[0] += (buffer[2]*pos)+i;
            buffer[1] += (buffer[0]*pos)+z;
            buffer[2] += (buffer[1]*pos)+i-z;
        }
        break;
        case 27:
        {
            buffer[0] = (-buffer[2])+z;
            buffer[1] = (-buffer[0])+i;
            buffer[2] = (-buffer[1])+pos;
        }
        break;
        case 28:
        {
            buffer[0] = buffer[2]+(1+(i*z)/pos);
            buffer[1] = buffer[1]+(1+(i*z)/pos);
            buffer[2] = buffer[0]+(1+(i*z)/pos);
        }
        break;
        case 29:
        {
            int iq = i, zq = z+1;
            if(zq > height-2) return;
            unsigned char *temp = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            zq = z+2;
            if(zq > height-2) return;
            unsigned char *temp2 = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
          
            zq = z+3;
            if(zq > height-2) return;
            unsigned char *temp3 = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
            zq = z+4;
            if(zq > height-2) return;
            unsigned char *temp4 = (unsigned char*)full_buffer+(zq*bytesPerRow)+(iq*bytesPerSample);
         
            unsigned char col[4];
            
            col[0] = (temp[0]+temp2[0]+temp3[0]+temp4[0])/4;
            col[1] = (temp[1]+temp2[1]+temp3[1]+temp4[1])/4;
            col[2] = (temp[2]+temp2[2]+temp3[2]+temp4[2])/4;
            
            buffer[0] = col[0]*pos;
            buffer[1] = col[1]*pos;
            buffer[2] = col[2]*pos;
            
        }
        break;
        case 30:
        {
            
            double rad = 100.0;
            double degree = 0.01*pos;
            int x = (int)rad * cos(degree);
            int y = (int)rad * sin(degree);
            int z = (int)rad * tanf((float)degree);
            buffer[0] = buffer[0]+x;
            buffer[2] = buffer[1]+y;
            buffer[1] = buffer[1]+z;
            
        }
        break;
        case 31:
        {
            int average= (buffer[0]+buffer[1]+buffer[2]+1)/3;
            buffer[0] += buffer[2]+average*(pos);
            buffer[1] += buffer[0]+average*(pos);
            buffer[2] += buffer[1]+average*(pos);
        }
            break;
        case 32:
        {
            unsigned int value = 0;
            value  = ~buffer[0] + ~buffer[1] + ~buffer[2];
            value /= 2;
            buffer[0] = buffer[0]+value*pos;
            value /= 2;
            buffer[1] = buffer[1]+value*pos;
            value /= 2;
            buffer[2] = buffer[2]+value*pos;
            
        }
            break;
        case 33:
        {
            
            
            buffer[0] += *count*pos;
            buffer[1] += *count*pos;
            buffer[2] += *count*pos;
            
            *count += 0.00001f;
            if(*count > 255) *count = 0;
            
 

        }
            break;
        case 34:
        {
            buffer[0] += pos*(randomNumber+pos);
            buffer[1] += pos*(randomNumber+z);
            buffer[2] += pos*(randomNumber+i);
        }
            break;
        case 35:
        {
            buffer[0] += *count *z;
            buffer[1] += *count *pos;
            buffer[2] += *count *z;
            
            *count += 0.0000001f;
            
            
        }
            break;
        case 36:
        {
            buffer[0] += sinf(M_PI+pos)*pos;
            buffer[1] += cosf(M_PI+pos)*pos;
            buffer[2] += tanf(M_PI+pos)*pos;
        }
            break;
        case 37:
        {
            
        
            unsigned char buf[3] = { buffer[0], buffer[1], buffer[2] };
            buffer[0] = buf[2]+(pos*buffer[0]);
            buffer[1] = buf[1]+(pos*buffer[1]);
            buffer[2] = buf[0]+(pos*buffer[2]);
            
            
        }
            break;
        case 38:
        {
            unsigned char buf[3] = { buffer[0], buffer[1], buffer[2] };
            buffer[0] = (buf[0]*pos)+(buf[0]-buffer[2]);
            buffer[1] = (buf[1]*pos)+(buf[1]+buffer[1]);
            buffer[2] = (buf[2]*pos)+(buf[2]-buffer[0]);
      
        }
            break;
    }
    buffer[0] += red;
    buffer[1] += green;
    buffer[2] += blue;
    if(negate == YES) {
        buffer[0] = ~buffer[0];
        buffer[1] = ~buffer[1];
        buffer[2] = ~buffer[2];
    }
   
    unsigned char buf[3];
    buf[0] = buffer[0];
    buf[1] = buffer[1];
    buf[2] = buffer[2];
    
    switch(reverse) {
        case 0://normal
            break;
        case 1:
            buffer[0] = buf[2];
            buffer[1] = buf[1];
            buffer[2] = buf[0];
            break;
        case 2:
            buffer[0] = buf[1];
            buffer[1] = buf[2];
            buffer[2] = buf[0];
            break;
        case 3:
            buffer[0] = buf[2];
            buffer[1] = buf[0];
            buffer[2] = buf[1];
            break;
        case 4:
            buffer[0] = buf[1];
            buffer[1] = buf[0];
            buffer[2] = buf[2];
            break;
    }
}


@implementation AppController

- (IBAction) selectImage: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories: NO];
    [panel setCanChooseFiles: YES];
    NSArray *types = [NSArray arrayWithObjects: @"jpg", @"png", nil];
    [panel setAllowedFileTypes: types];
    if([panel runModal]) {
        NSString *file_url = [[[panel URLs] objectAtIndex: 0] path];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:file_url];
        [image_view setImage: image];
        current_image = image;
        [self changePosition:self];
    }
}

- (void) awakeFromNib {
    current_image = nil;
}

- (IBAction) saveImage: (id) sender {
    if(current_image == nil) return;
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
    NSArray *arr = [NSArray arrayWithObject: @"jpg"];
    [panel setAllowedFileTypes:arr];
    if(![panel runModal]) {
        return;
    }
    NSString *fileName = [[panel URL] path];
    NSImage *image = [image_view image];
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

- (IBAction) changePosition: (id) sender {
    if(current_image == nil) return;
    long slider__pos = [slider integerValue];
    current_filter = (int)[filter_selector indexOfSelectedItem];
    NSImage *image = [self applyFilter: slider__pos];
    [image_view setImage: image];
    NSString *slider_Pos = [NSString stringWithFormat: @"%d", (int)slider__pos];
    [slider_pos setStringValue: slider_Pos];
    
}

- (NSImage *) applyFilter: (long) pos {
    CGImageRef CGImage = [current_image CGImageForProposedRect:nil context:nil hints:nil];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];
    int moveOver = (int)[rep bitsPerPixel] / [rep bitsPerSample];
    unsigned char *buffer = [rep bitmapData];
    unsigned char *full_buffer = buffer;
    bytesPerSample = moveOver;
    bytesPerRow = (int)[rep bytesPerRow];
    width = (int)rep.size.width;
    height = (int)rep.size.height;
    red = (int) [slider_red integerValue];
    green = (int) [slider_green integerValue];
    blue = (int) [slider_blue integerValue];
    offset = (int)pos;
    randomNumber = rand()%255;
    BOOL negate = [check_box integerValue] == 0 ? NO : YES;
    NSInteger rev = [rgb_box indexOfSelectedItem];
    BOOL order = [opposite_dir integerValue] == 0 ? YES : NO;
    float count = 0;
    for(unsigned int z = 0; z < rep.size.height; ++z) {
        for(unsigned int i = 0; i < rep.size.width; ++i) {
            if(order == YES) {
                changePixel(full_buffer,negate,rev,i,z,buffer,pos, &count);
                buffer += moveOver;
            } else {
                changePixel(full_buffer,negate,rev,width-i-1,height-z-1,buffer,pos, &count);
                buffer += moveOver;
            }
        }
    }
    NSImage *img = [[NSImage alloc] initWithCGImage:[rep CGImage] size:NSMakeSize(rep.size.width, rep.size.height)];
    return img;
}

- (IBAction) changeSlider: (id) sender {
    int slider1 = (int) [slider_red integerValue];
    int slider2 = (int) [slider_green integerValue];
    int slider3 = (int) [slider_blue integerValue];
    NSString *text1 = [NSString stringWithFormat: @"%d", slider1];
    NSString *text2 = [NSString stringWithFormat: @"%d", slider2];
    NSString *text3 = [NSString stringWithFormat: @"%d", slider3];
    [slider_red_pos setStringValue: text1];
    [slider_green_pos setStringValue: text2];
    [slider_blue_pos setStringValue: text3];
    [self changePosition: self];
}

- (IBAction) changeFilter: (id) sender {
    [self changePosition:self];
}

- (IBAction) copyToClipboard: (id) sender {
    NSImage *image = [image_view image];
    if(image != nil) {
        NSPasteboard *board = [NSPasteboard generalPasteboard];
        [board clearContents];
        NSArray *arr = [NSArray arrayWithObject:image];
        [board writeObjects:arr];
    }
}

- (IBAction) setAsSource: (id) sender {
    current_image = [image_view image];
    [self changeFilter: self];
}

- (IBAction) setPasteboardAsSource: (id) sender {
    NSPasteboard *board = [NSPasteboard generalPasteboard];
    NSArray *cls = [NSArray arrayWithObject: [NSImage class]];
    NSDictionary *dict = [NSDictionary dictionary];
    BOOL ok = [board canReadObjectForClasses:cls options:dict];
    if(ok) {
        NSArray *array = [board readObjectsForClasses:cls options:dict];
        NSImage *image = [array objectAtIndex: 0];
        current_image = image;
        [self changePosition:self];
    }
}

- (IBAction) shareAF_Filter: (id) sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.facebook.com/sharer/sharer.php?u=lostsidedead.com/blog/?index=126"]];
}

- (IBAction) sliderEnter: (id) sender {
    NSString *text = [slider_pos stringValue];
    int slide_pos = atoi([text UTF8String]);
    NSString *conversionText = [NSString stringWithFormat:@"%d", slide_pos];
    [slider setIntegerValue:slide_pos];
    [slider_pos setStringValue: conversionText];
    [self changePosition:self];
}

@end


