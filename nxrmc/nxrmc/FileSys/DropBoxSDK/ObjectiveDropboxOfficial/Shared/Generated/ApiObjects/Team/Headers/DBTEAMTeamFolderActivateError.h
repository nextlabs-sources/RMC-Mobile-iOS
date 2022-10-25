///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMTeamFolderAccessError;
@class DBTEAMTeamFolderActivateError;
@class DBTEAMTeamFolderInvalidStatusError;

#pragma mark - API Object

///
/// The `TeamFolderActivateError` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMTeamFolderActivateError : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMTeamFolderActivateErrorTag` enum type represents the possible tag
/// states with which the `DBTEAMTeamFolderActivateError` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMTeamFolderActivateErrorTag) {
  /// (no description).
  DBTEAMTeamFolderActivateErrorAccessError,

  /// (no description).
  DBTEAMTeamFolderActivateErrorStatusError,

  /// (no description).
  DBTEAMTeamFolderActivateErrorOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMTeamFolderActivateErrorTag tag;

/// (no description). @note Ensure the `isAccessError` method returns true
/// before accessing, otherwise a runtime exception will be raised.
@property (nonatomic, readonly) DBTEAMTeamFolderAccessError * _Nonnull accessError;

/// (no description). @note Ensure the `isStatusError` method returns true
/// before accessing, otherwise a runtime exception will be raised.
@property (nonatomic, readonly) DBTEAMTeamFolderInvalidStatusError * _Nonnull statusError;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "access_error".
///
/// @param accessError (no description).
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithAccessError:(DBTEAMTeamFolderAccessError * _Nonnull)accessError;

///
/// Initializes union class with tag state of "status_error".
///
/// @param statusError (no description).
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithStatusError:(DBTEAMTeamFolderInvalidStatusError * _Nonnull)statusError;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithOther;

- (nonnull instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "access_error".
///
/// @note Call this method and ensure it returns true before accessing the
/// `accessError` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "access_error".
///
- (BOOL)isAccessError;

///
/// Retrieves whether the union's current tag state has value "status_error".
///
/// @note Call this method and ensure it returns true before accessing the
/// `statusError` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "status_error".
///
- (BOOL)isStatusError;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMTeamFolderActivateError` union.
///
@interface DBTEAMTeamFolderActivateErrorSerializer : NSObject

///
/// Serializes `DBTEAMTeamFolderActivateError` instances.
///
/// @param instance An instance of the `DBTEAMTeamFolderActivateError` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMTeamFolderActivateError` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMTeamFolderActivateError * _Nonnull)instance;

///
/// Deserializes `DBTEAMTeamFolderActivateError` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMTeamFolderActivateError` API object.
///
/// @return An instantiation of the `DBTEAMTeamFolderActivateError` object.
///
+ (DBTEAMTeamFolderActivateError * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end