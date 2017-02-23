

#import <MAMapKit/MAMapKit.h>

typedef NS_ENUM(NSInteger, NaviPointAnnotationType)
{
    NaviPointAnnotationStart,
    NaviPointAnnotationWay,
    NaviPointAnnotationEnd
};

@interface NaviPointAnnotation : MAPointAnnotation

@property (nonatomic, assign) NaviPointAnnotationType navPointType;

@end
