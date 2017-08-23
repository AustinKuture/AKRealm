//
//  YFPerson.h
//  AKRealmCoreData
//
//  Created by 李亚坤 on 2017/8/23.
//  Copyright © 2017年 Kuture. All rights reserved.
//

#import <Realm/Realm.h>

@interface YFPerson : RLMObject

@property NSString *name;
@property NSInteger age;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<YFPerson *><YFPerson>
RLM_ARRAY_TYPE(YFPerson)
