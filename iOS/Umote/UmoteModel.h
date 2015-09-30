//
//  UmoteModel.h
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-06.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UmoteChannelChangeDelegate <NSObject>

- (void)updateChannel;

@end

static NSString *CHANNEL_chanID = @"chanID";
static NSString *CHANNEL_fullName = @"fullName";
static NSString *CHANNEL_shortName = @"shortName";
static NSString *CHANNEL_streamURL = @"streamURL";
static NSString *CHANNEL_logo = @"logo";

static NSString *UDEMAND_id = @"id";
static NSString *UDEMAND_name = @"name";
static NSString *UDEMAND_vodurl = @"vodurl";
static NSString *UDEMAND_posterImage = @"posterImage";

static NSString *demand_id = @"id";
static NSString *demand_name = @"name";
static NSString *demand_vodurl = @"vodurl";
static NSString *demand_posterImage = @"posterImage";


static NSString *RemoteChannelUp = @"chanUp";
static NSString *RemoteChannelDown = @"chanDown";
static NSString *RemoteVolumeDown = @"volDown";
static NSString *RemoteVolumeUp = @"volUp";
static NSString *RemoteMute = @"mute";

static NSString *RegisterUsername = @"username";
static NSString *RegisterPassword = @"password";
static NSString *RegisterFirstName = @"firstName";
static NSString *RegisterLastName = @"lastName";
static NSString *RegisterEmail = @"email";
static NSString *RegisterGender = @"gender";
static NSString *RegisterGenderMale = @"Male";
static NSString *RegisterGenderFemale = @"Female";
static NSString *RegisterMonth = @"month";
static NSString *RegisterDay = @"day";
static NSString *RegisterYear = @"year";

static NSString *kUmoteRemoteModeChanged = @"UmoteRemoteModeChanged";
static NSString *kUmoteVideoChanged = @"UmoteVideoChanged";

@interface UmoteModel : NSObject

+ (UmoteModel *)sharedModel;

@property (nonatomic, assign) id<UmoteChannelChangeDelegate> channelChangeDelegate;

- (void)registerUser:(NSDictionary *)dict
              completion:(void (^)(BOOL succuess, NSDictionary *data,  NSString *errMsg))completion;

- (void)userLogIn:(NSString *)user
         password:(NSString *)password
       completion:(void (^)(BOOL succuess, NSString *errMsg))completion;

- (void)signOut;


@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, assign) NSInteger curChannelIdx;
@property (nonatomic, readonly, getter = isSignedIn) BOOL signedIn;
@property (nonatomic, getter = isRemoteMode) BOOL remoteMode;
@property (nonatomic, strong) NSNumber *videoId;
@property (nonatomic, strong) NSDictionary *uDemand;
@property (nonatomic, strong) NSDictionary *demand;

- (NSString *)adUrlWithTime:(NSInteger)sec chanId:(NSNumber *)chanId videoId:(NSNumber *)vidId;
- (void)syncVideoId;

- (void)channelUp;
- (void)channelDown;

- (void)fetchUDemand:(NSInteger)limit page:(NSInteger)page completionHandler:(void (^)(NSArray *demands, NSString *errMsg))completion;
- (void)fetchdemand:(NSInteger)limit page:(NSInteger)page completionHandler:(void (^)(NSArray *demands, NSString *errMsg))completion;
- (void)fetchCommentsWithCompletionHandler:(void (^)(NSArray *comments, NSString *errMsg))completion;
- (void)submitComment:(NSString *)comment completionHandler:(void (^)(BOOL sucess, NSString *errMsg))completion;
- (void)submitVote:(NSInteger)vote completionHandler:(void (^)(BOOL success, NSString *errMsg))completion;
- (void)remoteControl:(NSString *)remoteAction completionHandler:(void (^)(BOOL success, NSString *errMsg))completion;

@end
