//
//  UIImage-util.m
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 18..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>
#import <iconv.h>

#import "HaanDiskAppDelegate.h"
#import "UIImage-util.h"
#import "NSString-mime.h"
#import "UIDevice-util.h"
#import "ZipArchive.h"

#import "HancomViewer.h"

#include "hsp/hspapp.h"

#define DEVICE_SCALE 2

static NSMutableDictionary* s_imageCache = nil;
static NSMutableDictionary* s_thumbnailCache = nil;

@implementation UIImage (util)
+ (void)releaseCache {
	[s_imageCache release];
	s_imageCache = nil;
	
	[s_thumbnailCache release];
	s_thumbnailCache = nil;
}

+ (void)removeAllThumbnailCache
{
	[s_thumbnailCache removeAllObjects];
}

+ (NSString*)getCacheFilename:(NSString*)imageFilePath withPrefix:(NSString*)prefix
{
	NSString* relativePath = [HancomViewer relativePath:imageFilePath];
	NSString* item = [relativePath stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	
	NSString* cacheFilePath;

	if (prefix != nil) {
		cacheFilePath = [NSString stringWithFormat:@"%@/%@_%@", cacheDir, prefix, item];
	} else {
		cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheDir, item];
	}
	
	return cacheFilePath;
}

+ (UIImage*)imageWithResourceFile:(NSString*)fileName {
	if (s_imageCache == nil)
		s_imageCache = [[NSMutableDictionary alloc] init];

	UIImage *image = [s_imageCache objectForKey:fileName];
	
	if (image)
		return image;
	
	NSString *filePath = [NSString stringWithFormat:@"%@/images-viewer/%@", [[NSBundle mainBundle] resourcePath], fileName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		goto found;
	}
	
	filePath = [NSString stringWithFormat:@"%@/images-editor/%@", [[NSBundle mainBundle] resourcePath], fileName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		goto found;
	}
	
	filePath = [NSString stringWithFormat:@"%@/images/%@", [[NSBundle mainBundle] resourcePath], fileName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		goto found;
	}
	
	filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
	
found:
	image = [UIImage imageWithContentsOfFile:filePath];
	
	if (image != nil)
		[s_imageCache setObject:image forKey:fileName];

	return image;
}

+ (UIImage*)imageWithFileType:(NSString*)type {
	if (s_thumbnailCache == nil)
		s_thumbnailCache = [[NSMutableDictionary alloc] init];
	
	UIImage *image = nil;
	NSString *imageFilePath = nil;
	
	if (type == nil)
		type = @"generic";
	
	image = [s_thumbnailCache objectForKey:type];
	if (image)
		return image;
	
	if ([type isEqualToString:@"key.zip"] || [type isEqualToString:@"key"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/key.png", [[NSBundle mainBundle] resourcePath]];
	} else if ([type isEqualToString:@"numbers.zip"] || [type isEqualToString:@"numbers"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/numbers.png", [[NSBundle mainBundle] resourcePath]];
	} else if ([type isEqualToString:@"pages.zip"] || [type isEqualToString:@"pages"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/pages.png", [[NSBundle mainBundle] resourcePath]];
	} else if ([type isEqualToString:@"rtfd.zip"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/rtfd.png", [[NSBundle mainBundle] resourcePath]];
	} else if ([type isEqualToString:@"mp4"] ||
			   [type isEqualToString:@"3gp"] ||
			   [type isEqualToString:@"mov"] ||
			   [type isEqualToString:@"mpv"] ||
			   [type isEqualToString:@"avi"] ||
			   [type isEqualToString:@"m4v"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/movie.png", [[NSBundle mainBundle] resourcePath]];
	} else if ([type isEqualToString:@"mp3"] ||
			   [type isEqualToString:@"aiff"] ||
			   [type isEqualToString:@"wav"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/audio.png", [[NSBundle mainBundle] resourcePath]];
	} else {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/%@.png", [[NSBundle mainBundle] resourcePath], [type lowercaseString]];
	}
	
	BOOL iconFound = NO;
	if (imageFilePath) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
			iconFound = YES;
		} else {
			iconFound = NO;
		}
	}
	
	if (iconFound == NO)
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/generic.png", [[NSBundle mainBundle] resourcePath]];
	
	image = [UIImage imageWithContentsOfFile:imageFilePath];
	if (image != nil) {
		[s_thumbnailCache setObject:image forKey:type];
	}
	
	return image;
}

+ (UIImage*)imageWithFolderType:(NSString*)type
{
	if (s_thumbnailCache == nil)
		s_thumbnailCache = [[NSMutableDictionary alloc] init];
	
	UIImage *image = nil;
	NSString *imageFilePath = nil;
	
	if (type == nil)
		type = @"generic";
	
	image = [s_thumbnailCache objectForKey:type];
	if (image)
		return image;
	
	if ([type isEqualToString:@"system_folder"]) {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/folder.png", [[NSBundle mainBundle] resourcePath]];
	} else {
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/%@.png", [[NSBundle mainBundle] resourcePath], type];
	}
	
	BOOL iconFound = NO;
	if (imageFilePath) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
			iconFound = YES;
		} else {
			iconFound = NO;
		}
	}
	
	if (iconFound == NO)
		imageFilePath = [NSString stringWithFormat:@"%@/file-icons/generic.png", [[NSBundle mainBundle] resourcePath]];
	
	image = [UIImage imageWithContentsOfFile:imageFilePath];
	if (image != nil) {
		[s_thumbnailCache setObject:image forKey:type];
	}
	
	return image;
}

#pragma mark mp3, video, image, hwp, pdf, txt

+ (UIImage*)thumbnailWithFile:(NSString*)filePath
{
	Settings* settings = [Settings sharedSettings];
	if (settings.useThumbnail == NO)
		return nil;
	
	if (s_thumbnailCache == nil)
		s_thumbnailCache = [[NSMutableDictionary alloc] init];
	
	UIImage *image = [s_thumbnailCache objectForKey:filePath];
	if (image != nil)
		return image;

	NSString* cacheFile = [UIImage getCacheFilename:filePath withPrefix:nil];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
		NSDate *fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
		if (attributes != nil) {
			fileDate = [attributes fileModificationDate];
		}
		
		NSDate *cachedFileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFile error:nil];
		if (attributes != nil) {
			cachedFileDate = [attributes fileModificationDate];
		}
		
		if ([cachedFileDate compare:fileDate] == NSOrderedDescending) {
			image = [UIImage imageWithContentsOfFile:cacheFile];
			[s_thumbnailCache setObject:image forKey:filePath];
			return image;
		}
	}
	
	if ([filePath isMp3]) {
		AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
		NSArray *metadata = [asset commonMetadata];
		for ( AVMetadataItem* item in metadata ) {
			NSString *key = [item commonKey];
			//NSString *value = [item stringValue];
			
			//NSLog(@"displayMusic : key = %@, value = %@", key, value);
			
			if( [key isEqualToString:@"artwork"] ) {
				if ([[item value] isKindOfClass:[NSDictionary class]]) {
					NSDictionary *imageDic = (NSDictionary *)[item value];
					
					if ([imageDic objectForKey:@"data"] != nil) {
						NSData *imageData = [imageDic objectForKey:@"data"];
						image = [UIImage imageWithData:imageData];
						
						if (image != nil) {
							
							CGFloat imageWidth = image.size.width;
							CGFloat imageHeight = image.size.height;
							
							CGFloat scale;
							CGFloat deviceScale = DEVICE_SCALE;
							
							if (imageWidth > imageHeight) {
								scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageWidth;
							} else {
								scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageHeight;
							}
							
							CGRect drawingRect;
							drawingRect.size.width = imageWidth * scale;
							drawingRect.size.height = imageHeight * scale;
							drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
							drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
							
							CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
							
							UIGraphicsBeginImageContext(imageSize);
							[image drawInRect:drawingRect];
							image = UIGraphicsGetImageFromCurrentImageContext();
							UIGraphicsEndImageContext();
						}
					}
				}
			}
			
		}
	}
	
	if ([filePath isVideo]) {
		// AVAssetImageGenerator
		AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil]; 
		AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
		imageGenerator.appliesPreferredTrackTransform = YES;
		
		// calc midpoint time of video
		Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
		CMTime midpoint = CMTimeMakeWithSeconds(fmin(10.0, durationSeconds / 2), 600); 
		
		// get the image from 
		NSError *error = nil; 
		CMTime actualTime;
		CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
		
		if (halfWayImage != NULL) {
			size_t imageWidth = CGImageGetWidth (halfWayImage);
			size_t imageHeight = CGImageGetHeight(halfWayImage);
			
			CGSize drawingSize;
			
			CGFloat scale = FILE_TABLE_CELL_HEIGHT * DEVICE_SCALE / imageHeight ;
			if (scale < 1.0) {
				drawingSize = CGSizeMake(imageWidth * scale, imageHeight * scale);
			} else {
				drawingSize = CGSizeMake(imageWidth, imageHeight);
			}
			
			UIGraphicsBeginImageContext(drawingSize);
			CGContextRef context = UIGraphicsGetCurrentContext();
			
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, 0, -drawingSize.height);
			CGContextDrawImage(context, CGRectMake(0.0, 0.0, drawingSize.width, drawingSize.height), halfWayImage);
			image = UIGraphicsGetImageFromCurrentImageContext();
			
			UIGraphicsEndImageContext();
			CGImageRelease(halfWayImage);
		}
		
		// release 
		[imageGenerator release];
		[asset release];
	}
	
	if ([filePath isHwp]) {
		size_t length;
		void* pData = HspAppDupHwpPreviewData([filePath UTF8String], &length);
		NSData* data = [NSData dataWithBytesNoCopy:pData length:(NSUInteger)length];
		
		if (data != nil)
			image = [UIImage imageWithData:(NSData *)data];
		
		if (image != nil) {
			size_t imageWidth = image.size.width;
			size_t imageHeight = image.size.height;
			
			CGFloat scale;
			CGFloat deviceScale = DEVICE_SCALE;
			
			if (imageWidth > imageHeight) {
				scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageWidth;
			} else {
				scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageHeight;
			}
			
			CGRect drawingRect;
			drawingRect.size.width = imageWidth * scale;
			drawingRect.size.height = imageHeight * scale;
			drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
			drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
			
			CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
			
			UIGraphicsBeginImageContext(imageSize);
			[image drawInRect:drawingRect];
			
			CGContextRef context = UIGraphicsGetCurrentContext();

			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetLineWidth(context, 1.0);
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, drawingRect.origin.x, drawingRect.origin.y);
			CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y);
			CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + drawingRect.size.height);
			CGContextAddLineToPoint(context, drawingRect.origin.x, drawingRect.origin.y + drawingRect.size.height);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathStroke);
			
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
	}
	
	if ([filePath isShow]) {
		ZipArchive* za = [[[ZipArchive alloc] init] autorelease];
		za.fileEncoding = [Settings fileEncoding];
		[za UnzipOpenFile:filePath];
		
		NSData *data = [za extractStream:@"docProps/thumbnail.jpeg"];
		
		if (data != nil)
			image = [UIImage imageWithData:(NSData *)data];
		
		if (image != nil) {
			size_t imageWidth = image.size.width;
			size_t imageHeight = image.size.height;
			
			CGFloat scale;
			CGFloat deviceScale = DEVICE_SCALE;
			
			if (imageWidth > imageHeight) {
				scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageWidth;
			} else {
				scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageHeight;
			}
			
			CGRect drawingRect;
			drawingRect.size.width = imageWidth * scale;
			drawingRect.size.height = imageHeight * scale;
			drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
			drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
			
			CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
			
			UIGraphicsBeginImageContext(imageSize);
			[image drawInRect:drawingRect];
			
			CGContextRef context = UIGraphicsGetCurrentContext();
			
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetLineWidth(context, 1.0);
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, drawingRect.origin.x, drawingRect.origin.y);
			CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y);
			CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + drawingRect.size.height);
			CGContextAddLineToPoint(context, drawingRect.origin.x, drawingRect.origin.y + drawingRect.size.height);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathStroke);
			
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
	}
	
	if ([filePath isPdf]) {
		
		CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath]);
		if (documentRef == NULL)
			return NULL;
		
		CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
		if (pageRef == NULL) {
			CGPDFDocumentRelease(documentRef);
			return NULL;
		}
		
		CGRect mBox = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
		CGRect cBox = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
		CGPoint leftTop = CGPointMake(MAX(mBox.origin.x, cBox.origin.x), MAX(mBox.origin.y, cBox.origin.y));
		CGPoint rightBottom = CGPointMake(MIN(mBox.size.width + mBox.origin.x, cBox.size.width + cBox.origin.x), MIN(mBox.size.height + mBox.origin.y, cBox.size.height + cBox.origin.y));
		
		// pdf rect
		CGRect r = CGRectMake(leftTop.x, leftTop.y, rightBottom.x - leftTop.x, rightBottom.y - leftTop.y);
		
		int angle = CGPDFPageGetRotationAngle(pageRef);
		CGAffineTransform matrix;
		int maxX = 0, minX = 0, maxY = 0, minY = 0;
		
		if (angle % 360) {
			matrix = CGAffineTransformMakeRotation(-(CGFloat)angle * M_PI / 180);
			
			CGPoint p[4];
			
			p[0].x = r.origin.x;
			p[0].y = r.origin.y;
			p[1].x = r.size.width + r.origin.x;
			p[1].y = r.origin.y;
			p[2].x = r.origin.x;
			p[2].y = r.size.height + r.origin.y;
			p[3].x = r.size.width + r.origin.x;
			p[3].y = r.size.height + r.origin.y;
			
			p[0] = CGPointApplyAffineTransform(p[0], matrix);
			p[1] = CGPointApplyAffineTransform(p[1], matrix);
			p[2] = CGPointApplyAffineTransform(p[2], matrix);
			p[3] = CGPointApplyAffineTransform(p[3], matrix);
			
			maxX = MAX(MAX(p[0].x, p[1].x), MAX(p[2].x, p[3].x));
			minX = MIN(MIN(p[0].x, p[1].x), MIN(p[2].x, p[3].x));
			maxY = MAX(MAX(p[0].y, p[1].y), MAX(p[2].y, p[3].y));
			minY = MIN(MIN(p[0].y, p[1].y), MIN(p[2].y, p[3].y));
			
			int wid = abs(maxX - minX);
			int ht = abs(maxY - minY);
			
			r = CGRectMake(0, 0, wid, ht);
		}
		
		CGFloat x = r.origin.x;
		CGFloat y = r.origin.y;
		
		size_t imageWidth = r.size.width;
		size_t imageHeight = r.size.height;
		
		CGFloat scale;
		CGFloat deviceScale = DEVICE_SCALE;
		
		if (imageWidth > imageHeight) {
			scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageWidth;
		} else {
			scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageHeight;
		}
		
		CGRect drawingRect;
		drawingRect.size.width = imageWidth * scale;
		drawingRect.size.height = imageHeight * scale;
		drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
		drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
		
		CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
		UIGraphicsBeginImageContext(imageSize);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSaveGState(context);
		
		CGContextClipToRect(context, drawingRect);
		CGContextTranslateCTM(context, drawingRect.origin.x, drawingRect.size.height + drawingRect.origin.y);
		
		CGContextScaleCTM(context, 1.0, -1.0);

		CGContextScaleCTM(context, scale, scale);
		CGContextTranslateCTM(context, -x, -y);
		
		if (angle % 360) {
			CGContextTranslateCTM(context, -minX, -minY);
			CGContextRotateCTM(context, -angle * M_PI / 180);
		}
		
		CGContextDrawPDFPage(context, pageRef);
		
		CGContextRestoreGState(context);

		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		CGContextSetLineWidth(context, 1.0);
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, drawingRect.origin.x, drawingRect.origin.y);
		CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y);
		CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + drawingRect.size.height);
		CGContextAddLineToPoint(context, drawingRect.origin.x, drawingRect.origin.y + drawingRect.size.height);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathStroke);
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		CGPDFDocumentRelease(documentRef);
	}
	
	if ([filePath isTxt]) {
		// reading one page
		iconv_t cd = iconv_open("UTF-8", [settings.defaultTextEncoding UTF8String]);
		if (cd == (iconv_t)-1) {
			return nil;
		}
		
#define IN_BUF_SIZE 7864 //	(1024 * 768) / (10 * 10)
#define OUT_BUF_SIZE (IN_BUF_SIZE * 3)
		
		char inBuf[IN_BUF_SIZE];
		char outBuf[OUT_BUF_SIZE];
		
		FILE *fp = fopen([filePath UTF8String], "r");
		if (fp == NULL) {
			iconv_close(cd);
			return nil;
		}
		
		char *inbuf = NULL, *outbuf = NULL;
		size_t inbytesleft, outbytesleft;
		size_t nread;
		inbytesleft = 0;
		
		nread = fread(inBuf, 1, IN_BUF_SIZE, fp);
		if (nread == 0)
			return nil;
		
		memset(outBuf, 0, OUT_BUF_SIZE);
		
		inbuf = inBuf;
		inbytesleft = nread;
		outbuf = outBuf;
		outbytesleft = OUT_BUF_SIZE;
		
		size_t res;
		int errorCount = 0;
		do {
			res = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
			if (res == (size_t)-1) {
				if (errno == E2BIG) {
					break;
				} if (errno == EINVAL) {
					if (inbytesleft > 10) {
						inbuf++;
						inbytesleft--;
					} else {
						break;
					}
				} if (errno == EILSEQ) {
					inbuf++;
					inbytesleft--;
					errorCount++;
				} else {
					inbuf++;
					inbytesleft--;
				}
				
				if (errorCount > 20) {
					fclose(fp);
					iconv_close(cd);
					return nil;
				}
			}
		} while (res == (size_t)-1);
		
		fclose(fp);
		iconv_close(cd);
		
		NSString *text = [NSString stringWithUTF8String:outBuf];
		
		// autoAlign
		if (settings.autoAlign == YES) {
			NSUInteger length = [text length];
			unichar *dest = malloc(sizeof(unichar) * length * 1.3);
			
			NSUInteger idx = 0;
			NSUInteger cnt = 0;
			bool lineBreak = false;
			
			while(idx < length) {
				switch([text characterAtIndex:idx]) {
					case '.':
					case '!':
					case '?':
					case '"':
					case '\'':
					case ']':
					case '}':
					case ')':
					case '>':
					case ';':
					case ':':
					case 0x1d20: // ”
						dest[cnt++] = [text characterAtIndex:idx++];
						
						if (idx < length) {
							if ([text characterAtIndex:idx] == '\r') {
								idx++;
								if (idx < length && [text characterAtIndex:idx] == '\n') {
									idx++;
								}
								
								// 구두점 다음의 newline 처리함
								dest[cnt++] = '\n';
								if (settings.insertSpace)
									dest[cnt++] = ' ';
							} else if ([text characterAtIndex:idx] == '\n') {
								dest[cnt++] = '\n';
								if (settings.insertSpace)
									dest[cnt++] = ' ';
							}
						}
						break;
					case '\r':
						idx++;
						if (idx < length) {
							if ([text characterAtIndex:idx] == '\n') {
								idx++;
							}
						}
						lineBreak = true;
						break;
					case '\n':
						idx++;
						lineBreak = true;
						break;
					default:
						if (lineBreak) {
							// 문단 시작을 검사
							if ([text characterAtIndex:idx] == ' ' || [text characterAtIndex:idx] == '\t') {
								dest[cnt++] = '\n';
							}
							
							if ([text characterAtIndex:idx] == '\'' || [text characterAtIndex:idx] == '"') {
								dest[cnt++] = '\n';
							}
							
							if (settings.insertSpace)
								dest[cnt++] = ' ';
							
							lineBreak = false;	
						}
						
						dest[cnt++] = [text characterAtIndex:idx++];
						break;
				}
			}
			
			dest[cnt] = '\0';
			
			text = [NSString stringWithCharacters:dest length:cnt];
			
			free(dest);
		}
		
		// drawing one page
		CGFloat textFontSize = [settings.defaultTextFontSize intValue];
		CTFontRef textFont = CTFontCreateWithName((CFStringRef)settings.textViewFontName, textFontSize, NULL);
		CGColorRef textColor = [Settings textColor:settings.textViewColor].CGColor;
		CGColorRef backgroundColor = [Settings backgroundColor:settings.textViewColor].CGColor;
									  
		CTTextAlignment _textAlignment = kCTJustifiedTextAlignment;
		CTLineBreakMode _lineBreakMode = (settings.wordWrap) ? kCTLineBreakByWordWrapping : kCTLineBreakByCharWrapping;
		CGFloat _firstLineHeadIndent = 0.0;
		CGFloat _spacing = textFontSize;
		CGFloat _topSpacing = 0.0;
		CGFloat _lineSpacing = 5.0;
		
		CFIndex theNumberOfSettings = 6;
		CTParagraphStyleSetting theSettings[6] =
		{
			{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
			{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
			{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &_firstLineHeadIndent },
			{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_spacing },
			{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &_topSpacing },
			{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &_lineSpacing }
		};
		
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
		
		CGSize pageSize;
		if ([UIDevice iPad]) {
			pageSize = CGSizeMake(768.0, 1024.0);
		} else {
			pageSize = CGSizeMake(320.0, 480.0);
		}
		
		size_t imageWidth = pageSize.width;
		size_t imageHeight = pageSize.height;
		
		CGFloat scale;
		CGFloat deviceScale = DEVICE_SCALE;
		
		if (imageWidth > imageHeight) {
			scale = FILE_TABLE_CELL_HEIGHT * deviceScale / pageSize.width;
		} else {
			scale = FILE_TABLE_CELL_HEIGHT * deviceScale / pageSize.height;
		}
		
		CGRect drawingRect;
		drawingRect.size.width = imageWidth * scale;
		drawingRect.size.height = imageHeight * scale;
		drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
		drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
		
		CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
		
		UIGraphicsBeginImageContext(imageSize);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSaveGState(context);
		
		CGContextSetFillColorWithColor(context, backgroundColor);
		CGContextFillRect(context, drawingRect);

		CGContextTranslateCTM(context, drawingRect.origin.x, 0.0);
		
		CGContextScaleCTM(context, scale, scale);

		CGContextTranslateCTM(context, 0.0, pageSize.height);
		CGContextScaleCTM(context, 1.0, -1.0);

		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									(id)textFont, (NSString *)kCTFontAttributeName,
									(id)textColor, (NSString *)kCTForegroundColorAttributeName,
									(id)paragraphStyle, (NSString *)kCTParagraphStyleAttributeName, nil];
		NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
		
		CGMutablePathRef path = CGPathCreateMutable();
		
		if ([UIDevice iPad]) {
			CGPathAddRect(path, NULL, CGRectMake(30.0, 30.0, pageSize.width - 60.0, pageSize.height - 60.0));
		} else {
			CGPathAddRect(path, NULL, CGRectMake(10.0, 10.0, pageSize.width - 20.0, pageSize.height - 20.0));
		}
		
		@synchronized([[UIApplication sharedApplication] delegate])
		{
			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
			CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
			CTFrameDraw(frame, context);
			CFRelease(frame);
			CFRelease(framesetter);
		}
		
		CFRelease(path);
		[attributedString release];
		
		CFRelease(paragraphStyle);
		CFRelease(textFont);
		
		CGContextRestoreGState(context);
		
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		CGContextSetLineWidth(context, 1.0);
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, drawingRect.origin.x, drawingRect.origin.y);
		CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y);
		CGContextAddLineToPoint(context, drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + drawingRect.size.height);
		CGContextAddLineToPoint(context, drawingRect.origin.x, drawingRect.origin.y + drawingRect.size.height);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathStroke);
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	if (image != nil) {
		// save cache image
		NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
		[imageData writeToFile:cacheFile atomically:YES];
		
		[s_thumbnailCache setObject:image forKey:filePath];
	}
	
	return image;
}

+ (UIImage*)cachedThumbnailWithFile:(NSString*)filePath
{
	if (s_thumbnailCache != nil) {
		return [s_thumbnailCache objectForKey:filePath];
	}
	
	return nil;
}

+ (UIImage*)thumbnailWithImage:(NSString*)filePath image:(UIImage*)_image
{
	Settings* settings = [Settings sharedSettings];
	if (settings.useThumbnail == NO)
		return nil;
	
	UIImage* result;
	result = [s_thumbnailCache objectForKey:filePath];
	if (result != nil)
		return result;
	
	NSString* cacheFile = [UIImage getCacheFilename:filePath withPrefix:nil];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
		NSDate *fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
		if (attributes != nil) {
			fileDate = [attributes fileModificationDate];
		}
		
		NSDate *cachedFileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFile error:nil];
		if (attributes != nil) {
			cachedFileDate = [attributes fileModificationDate];
		}
		
		if ([cachedFileDate compare:fileDate] == NSOrderedDescending) {
			result = [UIImage imageWithContentsOfFile:cacheFile];
			[s_thumbnailCache setObject:result forKey:filePath];
			return result;
		}
	}
	
	size_t imageWidth = _image.size.width;
	size_t imageHeight = _image.size.height;
	
	CGFloat scale;
	CGFloat deviceScale = DEVICE_SCALE;
	
	if (imageWidth > imageHeight) {
		scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageWidth;
	} else {
		scale = FILE_TABLE_CELL_HEIGHT * deviceScale / imageHeight;
	}
	
	CGRect drawingRect;
	drawingRect.size.width = imageWidth * scale;
	drawingRect.size.height = imageHeight * scale;
	drawingRect.origin.x = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.width) / 2.0;
	drawingRect.origin.y = (FILE_TABLE_CELL_HEIGHT * deviceScale - drawingRect.size.height) / 2.0;
	
	CGSize imageSize = CGSizeMake(FILE_TABLE_CELL_HEIGHT * deviceScale, FILE_TABLE_CELL_HEIGHT * deviceScale);
	
	UIGraphicsBeginImageContext(imageSize);
	[_image drawInRect:drawingRect];
	
	result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (result != nil) {
		// save cache image
		NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(result)];
		[imageData writeToFile:cacheFile atomically:YES];
		
		[s_thumbnailCache setObject:result forKey:filePath];
	}

	return result;
}

+ (UIImage*)loadCachedImage:(NSString*)filePath
{
	NSString* cacheFile = [UIImage getCacheFilename:filePath withPrefix:@"CachedImage"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
		NSDate *fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
		if (attributes != nil) {
			fileDate = [attributes fileModificationDate];
		}
		
		NSDate *cachedFileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFile error:nil];
		if (attributes != nil) {
			cachedFileDate = [attributes fileModificationDate];
		}
		
		if ([cachedFileDate compare:fileDate] == NSOrderedDescending) {
			return [UIImage imageWithContentsOfFile:cacheFile];
		}
	}
	
	return nil;
}

+ (void)saveCachedImage:(NSString*)filePath image:(UIImage*)_image
{
	NSString* cacheFile = [UIImage getCacheFilename:filePath withPrefix:@"CachedImage"];
	
	// save cache image
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(_image)];
	[imageData writeToFile:cacheFile atomically:YES];
}



CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180.f;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180.f / M_PI;};

+ (UIImage *)rotateImage:(UIImage*)image ByOrientation:(UIImageOrientation)orientation
{
	switch (orientation) {
		case UIImageOrientationUp:
			return image;
		case UIImageOrientationDown:
			return [UIImage rotateImage:image ByDegrees:180.f];
		case UIImageOrientationLeft:
			return [UIImage rotateImage:image ByDegrees:270.f];
		case UIImageOrientationRight:
			return [UIImage rotateImage:image ByDegrees:90.f];
			
		default:
			return image;
	}
}

+ (UIImage *)rotateImage:(UIImage*)image ByRadians:(CGFloat)radians
{
	return [UIImage rotateImage:image ByDegrees:RadiansToDegrees(radians)];
}

+ (UIImage *)rotateImage:(UIImage*)image ByDegrees:(CGFloat)degrees
{   
	// calculate the size of the rotated view's containing box for our drawing space
	CGSize orgSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, orgSize.width, orgSize.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	[rotatedViewBox release];
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-orgSize.width / 2, -orgSize.height / 2, orgSize.width, orgSize.height), [image CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (UIImage *)resizeImage:(UIImage*)image maxLength:(CGFloat)maxLength
{
	CGSize orgSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));

	CGFloat length = MAX(orgSize.width, orgSize.height);
	
	if (length <= maxLength)
		return image;
	
	CGFloat scale = maxLength / length;
	CGSize newSize = CGSizeMake(orgSize.width * scale, orgSize.height * scale);
	
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;	
}


@end
