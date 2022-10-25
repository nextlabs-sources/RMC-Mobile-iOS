///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGSharedLinkSettingsError;

#pragma mark - API Object

///
/// The `SharedLinkSettingsError` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGSharedLinkSettingsError : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBSHARINGSharedLinkSettingsErrorTag` enum type represents the possible
/// tag states with which the `DBSHARINGSharedLinkSettingsError` union can
/// exist.
typedef NS_ENUM(NSInteger, DBSHARINGSharedLinkSettingsErrorTag) {
  /// The given settings are invalid (for example, all attributes of the
  /// SharedLinkSettings are empty, the requested visibility is `password` in
  /// `DBSHARINGRequestedVisibility` but the `linkPassword` in
  /// `DBSHARINGSharedLinkSettings` is missing, `expires` in
  /// `DBSHARINGSharedLinkSettings` is set to the past, etc.)
  DBSHARINGSharedLinkSettingsErrorInvalidSettings,

  /// User is not allowed to modify the settings of this link. Note that basic
  /// users can only set `public` in `DBSHARINGRequestedVisibility` as the
  /// `requestedVisibility` in `DBSHARINGSharedLinkSettings` and cannot set
  /// `expires` in `DBSHARINGSharedLinkSettings`
  DBSHARINGSharedLinkSettingsErrorNotAuthorized,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBSHARINGSharedLinkSettingsErrorTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "invalid_settings".
///
/// Description of the "invalid_settings" tag state: The given settings are
/// invalid (for example, all attributes of the SharedLinkSettings are empty,
/// the requested visibility is `password` in `DBSHARINGRequestedVisibility` but
/// the `linkPassword` in `DBSHARINGSharedLinkSettings` is missing, `expires` in
/// `DBSHARINGSharedLinkSettings` is set to the past, etc.)
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithInvalidSettings;

///
/// Initializes union class with tag state of "not_authorized".
///
/// Description of the "not_authorized" tag state: User is not allowed to modify
/// the settings of this link. Note that basic users can only set `public` in
/// `DBSHARINGRequestedVisibility` as the `requestedVisibility` in
/// `DBSHARINGSharedLinkSettings` and cannot set `expires` in
/// `DBSHARINGSharedLinkSettings`
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithNotAuthorized;

- (nonnull instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value
/// "invalid_settings".
///
/// @return Whether the union's current tag state has value "invalid_settings".
///
- (BOOL)isInvalidSettings;

///
/// Retrieves whether the union's current tag state has value "not_authorized".
///
/// @return Whether the union's current tag state has value "not_authorized".
///
- (BOOL)isNotAuthorized;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBSHARINGSharedLinkSettingsError` union.
///
@interface DBSHARINGSharedLinkSettingsErrorSerializer : NSObject

///
/// Serializes `DBSHARINGSharedLinkSettingsError` instances.
///
/// @param instance An instance of the `DBSHARINGSharedLinkSettingsError` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGSharedLinkSettingsError` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBSHARINGSharedLinkSettingsError * _Nonnull)instance;

///
/// Deserializes `DBSHARINGSharedLinkSettingsError` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGSharedLinkSettingsError` API object.
///
/// @return An instantiation of the `DBSHARINGSharedLinkSettingsError` object.
///
+ (DBSHARINGSharedLinkSettingsError * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
