//
//  AppDelegate.h
//  AKRealmCoreData
//
//  Created by 李亚坤 on 2017/8/23.
//  Copyright © 2017年 Kuture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

