//
//  Struts.c
//  signature
//
//  Created by Ahmad  Hassan on 27/11/2015.
//  Copyright © 2015 Vocal Matrix. All rights reserved.
//

#import "Struts.h"


#define UIViewAutoresizingFlexibleMargins                 \
UIViewAutoresizingFlexibleBottomMargin    | \
UIViewAutoresizingFlexibleLeftMargin      | \
UIViewAutoresizingFlexibleRightMargin     | \
UIViewAutoresizingFlexibleTopMargin

#define UIViewAutoresizingFlexibleMargins1                 \
UIViewAutoresizingFlexibleWidth    | \
UIViewAutoresizingFlexibleHeight

int setstruts(UIView* myView)
{
    //    UIViewAutoresizing mask = myView.autoresizingMask;
    //    mask &= ~UIViewAutoresizingFlexibleBottomMargin;
    //    mask |= UIViewAutoresizingFlexibleTopMargin;
    myView.autoresizingMask = UIViewAutoresizingFlexibleMargins1;
    myView.autoresizesSubviews = YES;
    return 1;
}

int setstrutsWithMask(UIView* myView,UIViewAutoresizing mask )
{
    //    UIViewAutoresizing mask = myView.autoresizingMask;
    //    mask &= ~UIViewAutoresizingFlexibleBottomMargin;
    //    mask |= UIViewAutoresizingFlexibleTopMargin;
    myView.autoresizingMask = mask;
    myView.autoresizesSubviews = YES;
    return 1;
}