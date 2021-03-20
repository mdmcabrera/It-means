#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Detected language from text recognition. */
NS_SWIFT_NAME(TextRecognizedLanguage)
@interface MLKTextRecognizedLanguage : NSObject

/**
 *  The [BCP 47 language tag](https://tools.ietf.org/rfc/bcp/bcp47.txt), such as, `"en-US"` or
 * `"sr-Latn"`.
 */
@property(nonatomic, readonly, nullable) NSString *languageCode;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
