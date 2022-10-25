///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGPendingUploadMode;

#pragma mark - API Object

///
/// The `PendingUploadMode` union.
///
/// Flag to indicate pending upload default (for linking to not-yet-existing
/// paths).
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGPendingUploadMode : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBSHARINGPendingUploadModeTag` enum type represents the possible tag
/// states with which the `DBSHARINGPendingUploadMode` union can exist.
typedef NS_ENUM(NSInteger, DBSHARINGPendingUploadModeTag) {
  /// Assume pending uploads are files.
  DBSHARINGPendingUploadModeFile,

  /// Assume pending uploads are folders.
  DBSHARINGPendingUploadModeFolder,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBSHARINGPendingUploadModeTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "file".
///
/// Description of the "file" tag state: Assume pending uploads are files.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithFile;

///
/// Initializes union class with tag state of "folder".
///
/// Description of the "folder" tag state: Assume pending uploads are folders.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithFolder;

- (nonnull instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "file".
///
/// @return Whether the union's current tag state has value "file".
///
- (BOOL)isFile;

///
/// Retrieves whether the union's current tag state has value "folder".
///
/// @return Whether the union's current tag state has value "folder".
///
- (BOOL)isFolder;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBSHARINGPendingUploadMode` union.
///
@interface DBSHARINGPendingUploadModeSerializer : NSObject

///
/// Serializes `DBSHARINGPendingUploadMode` instances.
///
/// @param instance An instance of the `DBSHARINGPendingUploadMode` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGPendingUploadMode` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBSHARINGPendingUploadMode * _Nonnull)instance;

///
/// Deserializes `DBSHARINGPendingUploadMode` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGPendingUploadMode` API object.
///
/// @return An instantiation of the `DBSHARINGPendingUploadMode` object.
///
+ (DBSHARINGPendingUploadMode * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
