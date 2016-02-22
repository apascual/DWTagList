//
//  DWTagList.m
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 5.0f
#define LABEL_MARGIN_DEFAULT 18.0f
#define BOTTOM_MARGIN_DEFAULT 13.0f
#define FONT_FACE @"HelveticaNeue-Light"
#define FONT_SIZE_DEFAULT 13.0f
#define FONT_HIGHLIGHTED_COLOR [UIColor whiteColor]
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 10.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.00]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor clearColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 0.0f)
#define BORDER_COLOR [UIColor colorWithRed:205.0f/255.0f green:218.0f/255.0f blue:226.0f/255.0f alpha:1.0f]
#define BORDER_WIDTH 0.0f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:35.0f/255.0f green:136.0f/255.0f blue:190.0f/255.0f alpha:1.0f]
#define DEFAULT_AUTOMATIC_RESIZE NO
#define DEFAULT_SHOW_TAG_MENU NO
#define BADGE_COLOR [UIColor colorWithRed:35.0f/255.0f green:136.0f/255.0f blue:190.0f/255.0f alpha:1.0f]
#define BADGE_TEXT_COLOR [UIColor whiteColor]
#define BADGE_STROKE_COLOR [UIColor colorWithRed:245.0f/255.0f green:243.0f/255.0f blue:234.0f/255.0f alpha:1.0f]
#define BADGE_SELECTED_COLOR [UIColor colorWithRed:9.0f/255.0f green:147.0f/255.0f blue:3.0f/255.0f alpha:1.0f]
#define BADGE_SELECTED_STROKE_COLOR [UIColor colorWithRed:245.0f/255.0f green:243.0f/255.0f blue:234.0f/255.0f alpha:1.0f]
#define BADGE_SELECTED_TEXT_COLOR [UIColor whiteColor]

@interface DWTagList () <DWTagViewDelegate>

@end

@implementation DWTagList

@synthesize view, textArray, automaticResize, selectionArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:view];
    [self setClipsToBounds:YES];
    self.maxSelection = 0;
    self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
    self.font = [UIFont fontWithName:FONT_FACE size:FONT_SIZE_DEFAULT];
    self.labelMargin = LABEL_MARGIN_DEFAULT;
    self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
    self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
    self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    self.cornerRadius = CORNER_RADIUS;
    self.borderColor = BORDER_COLOR;
    self.borderWidth = BORDER_WIDTH;
    self.textColor = TEXT_COLOR;
    self.textShadowColor = TEXT_SHADOW_COLOR;
    self.textShadowOffset = TEXT_SHADOW_OFFSET;
    self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
    self.highlightedFontColor = FONT_HIGHLIGHTED_COLOR;
    self.badgeColor = BADGE_COLOR;
    self.badgeStrokeColor = BADGE_STROKE_COLOR;
    self.badgeTextColor = BADGE_TEXT_COLOR;
    self.badgeSelectedColor = BADGE_SELECTED_COLOR;
    self.badgeSelectedStrokeColor = BADGE_SELECTED_STROKE_COLOR;
    self.badgeSelectedTextColor = BADGE_SELECTED_TEXT_COLOR;
}

- (void)setTags:(NSArray *)array {
    [self setTags:array withBadges:nil withSelection:nil];
}

- (void)setTags:(NSArray *)array withBadges:(NSArray *)badgeArray {
    [self setTags:array withBadges:badgeArray withSelection:nil];
}

- (void)setTags:(NSArray *)array withBadges:(NSArray *)badgeArray withSelection:(NSArray *)selectedArray {
    textArray = [[NSArray alloc] initWithArray:array];
    badgeTextArray = [[NSArray alloc] initWithArray:badgeArray];
    selectionArray = [[NSArray alloc] initWithArray:selectedArray];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self display];
    }
}

- (void)setTagBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self display];
}

- (void)setTagHighlightColor:(UIColor *)color
{
    self.highlightedBackgroundColor = color;
    [self display];
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self display];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)display
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[DWTagView class]]) {
            DWTagView *tagView = (DWTagView*)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagView.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    NSInteger tag = 0;
    for (id text in textArray) {
        DWTagView *tagView;
        if (tagViews.count > 0) {
            tagView = [tagViews lastObject];
            [tagViews removeLastObject];
        }
        else {
            tagView = [[DWTagView alloc] init];
        }
        
        
        [tagView updateWithString:text
                             font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth
         ];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }
        
        previousFrame = tagView.frame;
        gotPreviousFrame = YES;
        
        [tagView setBackgroundColor:[self getBackgroundColor]];
        [tagView setCornerRadius:self.cornerRadius];
        [tagView setBorderColor:self.borderColor.CGColor];
        [tagView setBorderWidth:self.borderWidth];
        [tagView setTextColor:self.textColor];
        [tagView setTextShadowColor:self.textShadowColor];
        [tagView setTextShadowOffset:self.textShadowOffset];
        [tagView setTag:tag];
        [tagView setDelegate:self];
        
        if(badgeTextArray != nil && badgeTextArray.count > tag) {
            NSString *priceText = [badgeTextArray objectAtIndex:tag];
            if(priceText != nil && priceText.length > 0) {
                if(tagView.badgeView != nil) {
                    [tagView.badgeView removeFromSuperview];
                }
                tagView.badgeView = [[JSBadgeView alloc] initWithParentView:tagView alignment:JSBadgeViewAlignmentTopRight];
                tagView.badgeView.badgeText = priceText;
                tagView.badgeView.badgeTextFont = [UIFont systemFontOfSize:10.0f];
                tagView.badgeView.badgeBackgroundColor = self.badgeColor;
                tagView.badgeView.badgeTextColor = self.badgeTextColor;
                tagView.badgeView.badgeStrokeWidth = 2.0f;
                tagView.badgeView.badgeStrokeColor = self.badgeStrokeColor;
                tagView.badgeView.badgePositionAdjustment = CGPointMake(-2.0f, 2.0f);
                tagView.clipsToBounds = NO;
            } else {
                if(tagView.badgeView != nil) {
                    [tagView.badgeView removeFromSuperview];
                }
            }
        }
        
        if(selectionArray != nil && selectionArray.count > 0 && [selectionArray containsObject:@(tag)]) {
            tagView.button.selected = YES;
        } else {
            tagView.button.selected = NO;
        }
        
        if(tagView.button.selected) {
            [tagView setBackgroundColor:self.highlightedBackgroundColor];
            [tagView.label setTextColor:self.highlightedFontColor];
            tagView.badgeView.badgeBackgroundColor = self.badgeSelectedColor;
            tagView.badgeView.badgeTextColor = self.badgeSelectedTextColor;
            tagView.badgeView.badgeStrokeColor = self.badgeSelectedStrokeColor;
        } else {
            [tagView setBackgroundColor:[self getBackgroundColor]];
            [tagView.label setTextColor:self.textColor];
            tagView.badgeView.badgeBackgroundColor = self.badgeColor;
            tagView.badgeView.badgeTextColor = self.badgeTextColor;
            tagView.badgeView.badgeStrokeColor = self.badgeStrokeColor;
        }
        
        tag++;
        
        [self addSubview:tagView];
        
        if (!_viewOnly) {
            //            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            //            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
            //            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
        }
    }
    
    sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self setContentOffset:CGPointMake(0.0, self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
                  animated:animated];
}

- (void)touchDownInside:(id)sender
{
    //    UIButton *button = (UIButton*)sender;
    //    [[button superview] setBackgroundColor:self.highlightedBackgroundColor];
    //    [((DWTagView *)[button superview]).label setTextColor:self.highlightedFontColor];
}

- (NSInteger)calculateSelectedTags {
    NSInteger total = 0;
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[DWTagView class]]) {
            DWTagView *tagView = (DWTagView*)subview;
            if(tagView != nil && tagView.button.selected == YES) {
                total++;
            }
        }
    }
    return total;
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    DWTagView *tagView = (DWTagView *)[button superview];
    [tagView setBackgroundColor:[self getBackgroundColor]];
    
    NSInteger selectedTags = [self calculateSelectedTags];
    
    
    if(!button.selected) {
        
        if(self.maxSelection == 0 || selectedTags < self.maxSelection) {
            button.selected = YES;
        } else {
            button.selected = NO;
            [self.tagDelegate maxSelectionReached];
        }
    } else {
        button.selected = NO;
    }
    
    if(button.selected) {
        [[button superview] setBackgroundColor:self.highlightedBackgroundColor];
        [((DWTagView *)[button superview]).label setTextColor:self.highlightedFontColor];
        tagView.badgeView.badgeBackgroundColor = self.badgeSelectedColor;
        tagView.badgeView.badgeTextColor = self.badgeSelectedTextColor;
        tagView.badgeView.badgeStrokeColor = self.badgeSelectedStrokeColor;
    } else {
        [[button superview] setBackgroundColor:[self getBackgroundColor]];
        [((DWTagView *)[button superview]).label setTextColor:self.textColor];
        tagView.badgeView.badgeBackgroundColor = self.badgeColor;
        tagView.badgeView.badgeTextColor = self.badgeTextColor;
        tagView.badgeView.badgeStrokeColor = self.badgeStrokeColor;
    }
    
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:tagIndex:selected:)]) {
        [self.tagDelegate selectedTag:tagView.label.text tagIndex:tagView.tag selected:button.selected];
    }
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:tagIndex:)]) {
        [self.tagDelegate selectedTag:tagView.label.text tagIndex:tagView.tag];
    }
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:)]) {
        [self.tagDelegate selectedTag:tagView.label.text];
    }
    
    if (self.showTagMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:tagView.frame inView:self];
        [menuController setMenuVisible:YES animated:YES];
        [tagView becomeFirstResponder];
    }
}

- (void)touchDragExit:(id)sender
{
    //    UIButton *button = (UIButton*)sender;
    //    [[button superview] setBackgroundColor:[self getBackgroundColor]];
    //    [((DWTagView *)[button superview]).label setTextColor:self.textColor];
    
}

- (void)touchDragInside:(id)sender
{
    //    UIButton *button = (UIButton*)sender;
    //    [[button superview] setBackgroundColor:[self getBackgroundColor]];
    //    [((DWTagView *)[button superview]).label setTextColor:self.textColor];
    
}

- (UIColor *)getBackgroundColor
{
    return !lblBackgroundColor ? BACKGROUND_COLOR : lblBackgroundColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self display];
}

- (void)setBorderColor:(UIColor*)borderColor
{
    _borderColor = borderColor;
    [self display];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self display];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self display];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    [self display];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    _textShadowOffset = textShadowOffset;
    [self display];
}

- (void)dealloc
{
    view = nil;
    textArray = nil;
    lblBackgroundColor = nil;
}

#pragma mark - DWTagViewDelegate

- (void)tagViewWantsToBeDeleted:(DWTagView *)tagView {
    NSMutableArray *mTextArray = [self.textArray mutableCopy];
    [mTextArray removeObject:tagView.label.text];
    [self setTags:mTextArray];
    
    if ([self.tagDelegate respondsToSelector:@selector(tagListTagsChanged:)]) {
        [self.tagDelegate tagListTagsChanged:self];
    }
}

@end


@implementation DWTagView

- (id)init
{
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:TEXT_COLOR];
        [_label setShadowColor:TEXT_SHADOW_COLOR];
        [_label setShadowOffset:TEXT_SHADOW_OFFSET];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button setFrame:self.frame];
        [self addSubview:_button];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderColor:BORDER_COLOR.CGColor];
        [self.layer setBorderWidth:BORDER_WIDTH];
    }
    return self;
}

- (void)updateWithString:(id)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    CGSize textSize = CGSizeZero;
    BOOL isTextAttributedString = [text isKindOfClass:[NSAttributedString class]];
    
    if (isTextAttributedString) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [attributedString addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, ((NSAttributedString *)text).string.length)];
        
        textSize = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _label.attributedText = [attributedString copy];
    } else {
        textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        _label.text = text;
    }
    
    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;
    
    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _label.frame = CGRectMake(padding.width, 0, MIN(textSize.width, self.frame.size.width), textSize.height);
    _label.font = font;
    
    [_button setAccessibilityLabel:self.label.text];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setBorderColor:(CGColorRef)borderColor
{
    [self.layer setBorderColor:borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self.layer setBorderWidth:borderWidth];
}

- (void)setLabelText:(NSString*)text
{
    [_label setText:text];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_label setTextColor:textColor];
}

- (void)setTextShadowColor:(UIColor*)textShadowColor
{
    [_label setShadowColor:textShadowColor];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    [_label setShadowOffset:textShadowOffset];
}

- (void)dealloc
{
    _label = nil;
    _button = nil;
}

#pragma mark - UIMenuController support

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:)) || (action == @selector(delete:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.label.text];
}

- (void)delete:(id)sender
{
    [self.delegate tagViewWantsToBeDeleted:self];
}

@end
