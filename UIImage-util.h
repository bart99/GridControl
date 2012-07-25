//
//  UIImage-util.h
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 18..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (util)
+ (void)releaseCache;
+ (UIImage*)imageWithResourceFile:(NSString*)fileName;

// file's thumbnail
+ (void)removeAllThumbnailCache;
+ (NSString*)getCacheFilename:(NSString*)imageFilePath withPrefix:(NSString*)prefix;
+ (UIImage*)imageWithFileType:(NSString*)type;
+ (UIImage*)imageWithFolderType:(NSString*)type;
+ (UIImage*)thumbnailWithFile:(NSString*)filePath;
+ (UIImage*)cachedThumbnailWithFile:(NSString*)filePath;
+ (UIImage*)thumbnailWithImage:(NSString*)filePath image:(UIImage*)image;

// resized image
+ (UIImage*)loadCachedImage:(NSString*)filePath;
+ (void)saveCachedImage:(NSString*)filePath image:(UIImage*)_image;
+ (UIImage *)resizeImage:(UIImage*)image maxLength:(CGFloat)maxLength;

// rotate image
+ (UIImage *)rotateImage:(UIImage*)image ByOrientation:(UIImageOrientation)orientation;
+ (UIImage *)rotateImage:(UIImage*)image ByRadians:(CGFloat)radians;
+ (UIImage *)rotateImage:(UIImage*)image ByDegrees:(CGFloat)degrees;

@end
