//
//  main.m
//  kPause
//
//  Created by Nagy Konstantin Olivér on 2013.07.12..
//  Copyright (c) 2013 Nagy Konstantin Olivér. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, char *argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, (const char **)argv);
}
