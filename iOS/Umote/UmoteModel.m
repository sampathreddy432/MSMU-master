//
//  UmoteModel.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-06.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "UmoteModel.h"
#import "NSString+UAObfuscatedString.h"
#import "SDWebImagePrefetcher.h"

@interface UmoteModel()
{
    NSString *_api;
    NSMutableURLRequest *_request;
    NSURLResponse *_resonse;
    NSData *_data;
    NSError *_connectionErr;
    NSDictionary *_jsonObject;
    NSString *_dataStr;
}

@property (nonatomic, retain) NSString *cookie;
@property (nonatomic, strong) NSString *adUrl;
@property (nonatomic, strong) NSString *streamUrl;

@end

@implementation UmoteModel

UmoteModel *_sharedModel;
NSString *_apiKey;

+ (UmoteModel *)sharedModel
{
    if (_sharedModel == nil)
    {
        _sharedModel = [UmoteModel new];
        _apiKey = @"".f.i.n.d._.m.e._.i.f._.y.o.u._.c.a.n;
    }
    return _sharedModel;
}

- (BOOL)isSignedIn
{
    return self.cookie != nil;
}

- (void)setRemoteMode:(BOOL)remoteMode
{
    if (remoteMode != _remoteMode)
    {
        _remoteMode = remoteMode;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUmoteRemoteModeChanged object:nil];
    }
}

- (void)setVideoId:(NSNumber *)videoId
{
    if (![_videoId isEqual:videoId])
    {
        _videoId = videoId;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUmoteVideoChanged object:nil];
    }
}

- (NSString *)paramFromDict:(NSDictionary *)paramDict
{
    NSString *paramStr = @"";
    for (NSString *key in [paramDict keyEnumerator])
    {
        if ([paramDict[key] isKindOfClass:[NSDictionary class]])
        {
            continue;
        }
        
        paramStr = [NSString stringWithFormat:@"%@&%@=%@", paramStr, key, paramDict[key]];
    }
    
    for (NSString *key in [paramDict keyEnumerator])
    {
        if ([paramDict[key] isKindOfClass:[NSDictionary class]])
        {
            for (NSString *key2 in paramDict[key])
            {
                paramStr = [NSString stringWithFormat:@"%@&%@[%@]=%@", paramStr, key, key2, paramDict[key][key2]];
            }
        }
        
    }
    
    paramStr = [paramStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
    
    return paramStr;
}

- (NSMutableURLRequest *)api:(NSString *)apiName param:(NSDictionary *)paramDict method:(NSString *)httpMethod
{
    _api = apiName;
    
    NSString *urlStr = [NSString stringWithFormat:@"https://msmu.me/api/%@", apiName];
    NSString *paramStr = [self paramFromDict:paramDict];
    
    NSString *postLength;
    NSData *postData;
    NSString *postBody;
    if ([[httpMethod uppercaseString] isEqualToString:@"POST"])
    {
        postBody = paramStr;
        postData = [postBody dataUsingEncoding:/*NSASCIIStringEncoding*/NSUTF8StringEncoding allowLossyConversion:NO];
        postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    }
    else //if ([[httpMethod uppercaseString] isEqualToString:@"GET"])
    {
        urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, paramStr];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    request.HTTPMethod = httpMethod;
    
    [request setValue:@"application/json, text/javascript, */*; q=0.01"
   forHTTPHeaderField:@"Accept"];
   
    [request setValue:@"gzip,deflate,sdch"
   forHTTPHeaderField:@"Accept-Encoding"];
   
    [request setValue:@"en-GB,en-US;q=0.8,en;q=0.6"
   forHTTPHeaderField:@"Accept-Language"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];

    [request setValue:@"no-cache"
   forHTTPHeaderField:@"Pragma"];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    if (self.cookie)
        [request setValue:self.cookie
       forHTTPHeaderField:@"Cookie"];
    
    if (postLength)
        [request setValue:postLength
       forHTTPHeaderField:@"Content-Length"];

    if (postData)
        [request setHTTPBody:postData];
    
    NSLog(@"%@", urlStr);
    NSLog(@"%@", paramStr);
    
    _request = request;
    
    return request;
}


- (NSDictionary *)requestDict
{
    NSData *data = _request.HTTPBody;
    NSString* bodyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return @{@"method": _request.HTTPMethod,
             @"url": _request.URL,
             @"header": [_request allHTTPHeaderFields],
             @"body" : bodyStr};
}

- (void)alertError
{
    if ([_jsonObject[@"status"] isEqualToString:@"suc"])
    {
        return;
    }
    
    if ([_api isEqualToString:@"login"] &&
        [_jsonObject[@"status"] isEqualToString:@"err"])
    {
        return;  /// login error is handled
    }
    
    if ([_api isEqualToString:@"vote"] &&
        [_jsonObject[@"status"] isEqualToString:@"err"])
    {
        return;  /// vote could return error.
    }

    if ([_api isEqualToString:@"register"])
    {
        return;  /// register error is handled.
    }
    
    if ([_api isEqualToString:@"getFilmComments"])
    {
        return;  /// no comment warning is okay
    }
    
    if ([_api isEqualToString:@"getFilmId"])
    {
        return;  /// "ERROR: Unable to get current schedule!" is expected
    }
    
//    NSString *dataStr = [_dataStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];

    
//    NSString *str = [NSString stringWithFormat:
//                     @"response:\n\n%@ \n\nhttp request:\n\n%@",
//                     dataStr,
//                     [self requestDict]];
    
//    [[[UIAlertView alloc]initWithTitle:_jsonObject[@"msg"]
//                               message:str
//                              delegate:nil
//                     cancelButtonTitle:@"Dismiss"
//                     otherButtonTitles:nil]
//     show];
}



- (void)startMsmuApi:(NSString *)apiName param:(NSDictionary *)paramDict method:(NSString *)httpMethod completionHandler:
(void (^)(NSURLResponse *response, NSDictionary *json, NSError *connectionError))completion
{
    NSMutableURLRequest *request = [self api:apiName param:paramDict method:httpMethod];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         _resonse = response;
         _data = data;
         _connectionErr = connectionError;
         _dataStr = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];

         NSLog(@"%@", _dataStr);
         //NSLog(@"%@", response);
         //NSLog(@"%@", connectionError);
         
         NSDictionary *jsonObject;
         if (data)
         {
             jsonObject=[NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingMutableLeaves
                         error:nil];
             
             _jsonObject = jsonObject;
             
             //NSLog(@"jsonObject is %@",jsonObject);
         }
         else
         {
             NSLog(@"%@", connectionError.localizedDescription);
         }
         
         completion(response, jsonObject, connectionError);
         
         [self alertError];
     }];
}

- (void)registerUser:(NSDictionary *)param
          completion:(void (^)(BOOL succuess, NSDictionary *data, NSString *errMsg))completion
{
    [self startMsmuApi:@"register"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         if (jsonObject)
         {
             NSDictionary *data = jsonObject[@"data"];
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 completion(YES, data, nil);
             }
             else
             {
                 completion(NO, data, [jsonObject objectForKey:@"msg"]);
             }
         }
         else
         {
             completion(NO, nil, connectionError.localizedDescription);
         }
     }];
}

- (void)userLogIn:(NSString *)user password:(NSString *)password completion:(void (^)(BOOL succuess, NSString *errMsg))completion
{
    NSDictionary *param = @{@"username": user,
                            @"password": password};
    
    [self startMsmuApi:@"login"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
        if (jsonObject)
        {
            if ([[jsonObject objectForKey:@"status"] isEqualToString:@"suc"])
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                
                self.cookie = [httpResponse allHeaderFields][@"Set-Cookie"];
                NSLog(@"%@", self.cookie);
                
                completion(YES, nil);
            }
            else
            {
                completion(NO, [jsonObject objectForKey:@"msg"]);
                
                
            }
        }
        else
        {
            completion(NO, connectionError.localizedDescription);
        }
    }];
}

- (void)signOut
{
    
    NSLog(@"%@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://msmu.me/api/login"]]);
    NSLog(@"%@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://msmu.me/api/logout"]]);
    NSLog(@"%@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://msmu.me/api"]]);
    
    [self startMsmuApi:@"logout"
                 param:nil
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {

     }];
    
    self.cookie = nil;
}

- (NSArray *)channels
{
    if (_channels == nil)
    {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://msmu.me/api/channels?stream=hls"]];

        if (data)
        {
            NSError *err;
            _channels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            
            NSMutableArray *imageUrls = [NSMutableArray new];
            for (NSMutableDictionary *dict in _channels)
            {
                NSString *str = dict[CHANNEL_logo];
                str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                
                if ([str rangeOfString:@"https:"].location == NSNotFound)
                {
                    str = [@"https:" stringByAppendingString:str];
                }
                
                if ([str rangeOfString:@".png"].location == NSNotFound)
                {
                    NSLog(@"Invalid channel logo:%@ for channel %@", str, dict[CHANNEL_fullName]);
                }
                else
                {
                    [imageUrls addObject:str];
                }
                
                dict[CHANNEL_logo] = str;
            }
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageUrls];
            
            if (err)
                NSLog(@"channel json err = %@", err);
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
    }

    return _channels;
}

- (void)fetchAdUrl
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: @"https://msmu.me/api/adUrl"]];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        if ([dict[@"status"] isEqualToString:@"suc"])
        {
            NSString *adUrl = dict[@"data"][@"adURL"];
            NSString *streamUrl = dict[@"data"][@"streamURL"];
            
            _adUrl = adUrl;
            _streamUrl = streamUrl;
        }
    }
}

- (NSString *)adUrl
{
    if (_adUrl == nil)
    {
        [self fetchAdUrl];
    }
    
    return _adUrl;
}

- (NSString *)streamUrl
{
    if (_streamUrl == nil)
    {
        [self fetchAdUrl];
    }
    return _streamUrl;
}

- (NSNumber *)curChannelId
{
    NSDictionary *ch = self.channels[self.curChannelIdx];
    return ch[CHANNEL_chanID];
}

- (NSString *)adUrlWithTime:(NSInteger)sec chanId:(NSNumber *)chanId videoId:(NSNumber *)vidId
{
    NSString *str = self.adUrl;

    if (chanId && vidId)
    {
        str = self.streamUrl;
        str = [str stringByReplacingOccurrencesOfString:@"{@CHANID}" withString:[NSString stringWithFormat:@"%@", chanId]];
        str = [str stringByReplacingOccurrencesOfString:@"{@VIDEOID}" withString:[NSString stringWithFormat:@"%@", vidId]];
    }
    
    str = [str stringByReplacingOccurrencesOfString:@"{@SEC}" withString:[[NSNumber numberWithInteger:sec] description]];
    
    return str;
}

- (void)setUDemand:(NSDictionary *)uDemand
{
    self.videoId = uDemand[@"id"];
    
    _uDemand = uDemand;
    _curChannelIdx = -1;
    [self.channelChangeDelegate updateChannel];
    
}
- (void)setdemand:(NSDictionary *)demand
{
    self.videoId = demand[@"id"];
   
    demand = demand;
    _curChannelIdx = -1;
    [self.channelChangeDelegate updateChannel];
    
}



- (void)syncVideoId
{
    if (self.curChannel)
    {
        [self fetchFilmIdForChannel:self.curChannel completionHandler:^(NSNumber *filmID, NSString *errMsg) {
            if (self.videoId)
            {
                NSLog(@"setCurChannelIdx - filmID set already, ignore result of getFilmID API. [self.videoId = %@,  filmID = %@]", self.videoId, filmID);
            }
            else if (filmID)
            {
                self.videoId = filmID;
            }
            else
            {
                NSLog(@"No video ID available");
            }
        }];
    }
}

- (void)setCurChannelIdx:(NSInteger)curChannelIdx
{
    _curChannelIdx = curChannelIdx;
    _uDemand = nil;
    
    self.videoId = nil;
    
    [self syncVideoId];
    
    [self.channelChangeDelegate updateChannel];
}

- (void)channelUp
{
    if (_curChannelIdx + 1 < self.channels.count)
    {
        self.curChannelIdx = _curChannelIdx + 1;
    }
    else
    {
        self.curChannelIdx = 0;
    }
}

- (void)channelDown
{
    if (_curChannelIdx > 0)
    {
        self.curChannelIdx = _curChannelIdx - 1;
    }
    else
    {
        self.curChannelIdx = 34;
    }
}

- (NSNumber *)curChannel
{
    if (self.curChannelIdx < 0)
        return nil;
    
    return self.channels[self.curChannelIdx][CHANNEL_chanID];
}

- (void)fetchUDemand:(NSInteger)limit page:(NSInteger)page completionHandler:(void (^)(NSArray *demands, NSString *errMsg))completion
{
    NSDictionary *param = @{@"stream": @"hls",
                            @"page" : [NSNumber numberWithInt:page],
                            @"limit": [NSNumber numberWithInt:limit],
                            };
    
    [self startMsmuApi:@"ondemand"
                 param:param
                method:@"GET"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         NSArray *demands;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 demands = jsonObject[@"data"][@"demand"];
             }
             
             if (![demands isKindOfClass:[NSArray class]])
             {
                 demands = nil;
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(demands, errMsg);
     }];
}

- (void)fetchdemand:(NSInteger)limit page:(NSInteger)page completionHandler:(void (^)(NSArray *demands, NSString *errMsg))completion
{
    NSDictionary *param = @{@"stream": @"hls",
                            @"page" : [NSNumber numberWithInt:page],
                            @"limit": [NSNumber numberWithInt:limit],
                            };
    
    [self startMsmuApi:@"ondemand"
                 param:param
                method:@"GET"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         NSArray *demands;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 demands = jsonObject[@"data"][@"demand"];
             }
             
             if (![demands isKindOfClass:[NSArray class]])
             {
                 demands = nil;
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(demands, errMsg);
     }];
}




- (void)fetchCommentsWithCompletionHandler:(void (^)(NSArray *comments, NSString *errMsg))completion
{
    if (self.videoId)
    {
        [self fetchCommentsForFilmId:self.videoId completionHandler:^(NSArray *comments, NSString *errMsg) {
            completion(comments, errMsg);
        }];
    }
}

- (void)fetchCommentsForFilmId:(NSNumber *)filmID completionHandler:(void (^)(NSArray *comments, NSString *errMsg))completion
{
    NSDictionary *param = @{@"videoId": filmID};
    
    [self startMsmuApi:@"getFilmComments"
                 param:param
                method:@"GET"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         NSArray *comments;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 NSArray *startArray = jsonObject[@"data"][@"comments"];
                 
                 comments = [[startArray reverseObjectEnumerator] allObjects];
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(comments, errMsg);
     }];
}

- (void)fetchFilmIdForChannel:(NSNumber *)channel completionHandler:(void (^)(NSNumber *filmID, NSString *errMsg))completion
{
    NSDictionary *param = @{@"chanid": channel};
    
    [self startMsmuApi:@"getFilmId"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         NSNumber *filmId;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 filmId = jsonObject[@"data"][@"filmId"];
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
                  
         completion(filmId, errMsg);
     }];
}

- (void)submitComment:(NSString *)comment completionHandler:(void (^)(BOOL sucess, NSString *errMsg))completion
{
    NSMutableDictionary *param = [@{@"comment": comment}
                                  mutableCopy];
    if (self.videoId)
        param[@"videoId"] = self.videoId;
    
    if (self.curChannel)
        param[@"chanId"] = self.curChannel;
    
    
    [self startMsmuApi:@"filmcomment"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         BOOL sucess;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 sucess = YES;
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(sucess, errMsg);
     }];
}


- (void)submitVote:(NSInteger)vote completionHandler:(void (^)(BOOL success, NSString *errMsg))completion
{
    NSMutableDictionary *param = [@{@"vote" : [NSNumber numberWithInteger:vote]}
                                  mutableCopy];
    
    if (self.videoId)
        param[@"videoId"] = self.videoId;
    
    if (self.curChannel)
        param[@"chanId"] = self.curChannel;

    [self startMsmuApi:@"vote"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         BOOL succuss = NO;
         NSString *errMsg;
         
         if (jsonObject)
         {
             errMsg = [jsonObject objectForKey:@"msg"];
             
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 succuss = YES;
             }
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(succuss, errMsg);
     }];
}

- (void)remoteControl:(NSString *)remoteAction completionHandler:(void (^)(BOOL success, NSString *errMsg))completion;
{
    
    NSString *f = @"false";
    NSMutableDictionary *remote = [@{RemoteChannelDown : f,
                                    RemoteChannelUp : f,
                                    RemoteVolumeDown : f,
                                    RemoteVolumeUp : f,
                                    RemoteMute: f}
                                  mutableCopy];
    
    remote[remoteAction] = @"true";
    
    NSMutableDictionary *param = [@{@"chanId":self.curChannel,
                                    @"remote":remote}
                                  mutableCopy];
    
//    for (NSString *key in [remote keyEnumerator])
//    {
//        [param setObject:remote[key] forKey:[NSString stringWithFormat:@"remote[%@]", key]];
//    }
    
    [self startMsmuApi:@"remoteControl"
                 param:param
                method:@"POST"
     completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *connectionError)
     {
         BOOL success;
         NSString *errMsg;
         
         if (jsonObject)
         {
             if ([jsonObject[@"status"] isEqualToString:@"suc"])
             {
                 success = YES;
             }
             
             errMsg = [jsonObject objectForKey:@"msg"];
         }
         else
         {
             errMsg = connectionError.localizedDescription;
         }
         
         completion(success, errMsg);
     }];
}

@end
