//
//  OCMNetwork.h
//  ConsentSDK
//
//  Created by Bruce Geerdes on 3/24/20.
//  Copyright © 2020 Osano, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCMConsent : NSObject
@property (class, nonatomic, assign, readonly) NSString * _Nonnull analytics;
@property (class, nonatomic, assign, readonly) NSString * _Nonnull essential;
@property (class, nonatomic, assign, readonly) NSString * _Nonnull marketing;
@property (class, nonatomic, assign, readonly) NSString * _Nonnull personalization;
@end

NS_ASSUME_NONNULL_BEGIN

@interface OCMNetwork : NSObject

@property (class, readonly) OCMNetwork *shared;
+ (NSString *)consentBaseUrl;
- (void)setConfigID:(NSString *)configID;
- (void)setCustomerID:(NSString *)customerID;

- (void)setConsentingDomain:(NSString * _Nullable)consentingDomain;
- (void)setUserID:(NSString * _Nullable)userID;

/**
 Gets published config from server
 
 - Returns: A config dictionary.
 */
- (void)getConsentConfig:(void (^)(NSDictionary * _Nullable config,
                                                  NSError * _Nullable error))completionHandler;

/**
 Send user consents to the server.
 
 - Parameter consents: List of items a user has consented to.
					   Any items not in list will be considered "not consented to".
 */
- (void)setUserConsents:(NSArray<NSString *> * _Nullable)consents
	  completionHandler:(void (^)(NSError * _Nullable error))completionHandler;

/**
 Get disclosure information from server.
 
 - Returns: An array of dictionaries.
 */
- (void)disclosureWithCompletionHandler:(void (^)(NSArray * _Nullable disclosure,
												  NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
