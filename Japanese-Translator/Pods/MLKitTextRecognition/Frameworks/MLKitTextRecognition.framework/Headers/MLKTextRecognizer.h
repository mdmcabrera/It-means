#import <Foundation/Foundation.h>

@class MLKText;
@class MLKVisionImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * The callback to invoke when the text recognition completes.
 *
 * @param text Recognized text in the image or `nil` if there was an error.
 * @param error The error or `nil`.
 */
typedef void (^MLKTextRecognitionCallback)(MLKText *_Nullable text, NSError *_Nullable error)
    NS_SWIFT_NAME(TextRecognitionCallback);

/** A text recognizer that recognizes text in an image. */
NS_SWIFT_NAME(TextRecognizer)
@interface MLKTextRecognizer : NSObject

/**
 * Returns a text recognizer.
 *
 * @return A text recognizer.
 */
+ (instancetype)textRecognizer NS_SWIFT_NAME(textRecognizer());

/** Unavailable. Use the class method. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Processes the given image for text recognition.
 *
 * @param image The image to process.
 * @param completion Handler to call back on the main queue when text recognition completes.
 */
- (void)processImage:(MLKVisionImage *)image
          completion:(MLKTextRecognitionCallback)completion NS_SWIFT_NAME(process(_:completion:));

/**
 * Returns text results in the given image or `nil` if there was an error. The text recognition is
 * performed synchronously on the calling thread.
 *
 * @discussion It is advised to call this method off the main thread to avoid blocking the UI. As a
 *     result, an `NSException` is raised if this method is called on the main thread.
 * @param image The image to get results in.
 * @param error An optional error parameter populated when there is an error getting results.
 * @return Text results in the given image or `nil` if there was an error.
 */
- (nullable MLKText *)resultsInImage:(MLKVisionImage *)image error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
