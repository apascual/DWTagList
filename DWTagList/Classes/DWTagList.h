//
//  DWTagList.h
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSBadgeView/JSBadgeView.h>

@protocol DWTagListDelegate, DWTagViewDelegate;

@interface DWTagList : UIScrollView
{
    UIView      *view;
    NSArray     *textArray;
    NSArray     *badgeTextArray;
    CGSize      sizeFit;
    UIColor     *lblBackgroundColor;
}

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSInteger maxSelection;
@property (nonatomic) BOOL viewOnly;
@property (nonatomic) BOOL showTagMenu;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSArray *selectionArray;
@property (nonatomic, weak) id<DWTagListDelegate> tagDelegate;
@property (nonatomic, strong) UIColor *highlightedFontColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic) BOOL automaticResize;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat labelMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;
@property (nonatomic, assign) CGFloat minimumWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textShadowColor;
@property (nonatomic, assign) CGSize textShadowOffset;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) UIColor *badgeStrokeColor;
@property (nonatomic, strong) UIColor *badgeTextColor;
@property (nonatomic, strong) UIColor *badgeSelectedColor;
@property (nonatomic, strong) UIColor *badgeSelectedStrokeColor;
@property (nonatomic, strong) UIColor *badgeSelectedTextColor;

- (void)setTagBackgroundColor:(UIColor *)color;
- (void)setTagHighlightColor:(UIColor *)color;
- (void)setTags:(NSArray *)array;
- (void)setTags:(NSArray *)array withBadges:(NSArray *)badgeArray;
- (void)setTags:(NSArray *)array withBadges:(NSArray *)badgeArray withSelection:(NSArray *)selectedArray;
- (void)display;
- (CGSize)fittedSize;
- (void)scrollToBottomAnimated:(BOOL)animated;

@end

@interface DWTagView : UIView

@property (nonatomic, strong) UIButton              *button;
@property (nonatomic, strong) UILabel               *label;
@property (nonatomic, weak)   id<DWTagViewDelegate> delegate;
@property (nonatomic, strong) JSBadgeView           *badgeView;

- (void)updateWithString:(NSString*)text
                    font:(UIFont*)font
      constrainedToWidth:(CGFloat)maxWidth
                 padding:(CGSize)padding
            minimumWidth:(CGFloat)minimumWidth;
- (void)setLabelText:(NSString*)text;
- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setBorderColor:(CGColorRef)borderColor;
- (void)setBorderWidth:(CGFloat)borderWidth;
- (void)setTextColor:(UIColor*)textColor;
- (void)setTextShadowColor:(UIColor*)textShadowColor;
- (void)setTextShadowOffset:(CGSize)textShadowOffset;

@end


@protocol DWTagListDelegate <NSObject>

@optional

- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex group:(NSString *)groupIdentifier selected:(BOOL)selected;
- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex selected:(BOOL)selected;
- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex;
- (void)selectedTag:(NSString *)tagName;
- (void)tagListTagsChanged:(DWTagList *)tagList;
- (void)maxSelectionReached:(NSNumber *)maxSelection;

@end

@protocol DWTagViewDelegate <NSObject>

@required

- (void)tagViewWantsToBeDeleted:(DWTagView *)tagView;

@end
