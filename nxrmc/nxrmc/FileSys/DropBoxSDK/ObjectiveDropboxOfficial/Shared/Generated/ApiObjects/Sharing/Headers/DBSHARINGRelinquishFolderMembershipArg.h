///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGRelinquishFolderMembershipArg;

#pragma mark - API Object

///
/// The `RelinquishFolderMembershipArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGRelinquishFolderMembershipArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The ID for the shared folder.
@property (nonatomic, readonly, copy) NSString * _Nonnull sharedFolderId;

/// Keep a copy of the folder's contents upon relinquishing membership.
@property (nonatomic, readonly) NSNumber * _Nonnull leaveACopy;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param sharedFolderId The ID for the shared folder.
/// @param leaveACopy Keep a copy of the folder's contents upon relinquishing
/// membership.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithSharedFolderId:(NSString * _Nonnull)sharedFolderId
                                    leaveACopy:(NSNumber * _Nullable)leaveACopy;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param sharedFolderId The ID for the shared folder.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithSharedFolderId:(NSString * _Nonnull)sharedFolderId;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `RelinquishFolderMembershipArg` struct.
///
@interface DBSHARINGRelinquishFolderMembershipArgSerializer : NSObject

///
/// Serializes `DBSHARINGRelinquishFolderMembershipArg` instances.
///
/// @param instance An instance of the `DBSHARINGRelinquishFolderMembershipArg`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGRelinquishFolderMembershipArg` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBSHARINGRelinquishFolderMembershipArg * _Nonnull)instance;

///
/// Deserializes `DBSHARINGRelinquishFolderMembershipArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGRelinquishFolderMembershipArg` API object.
///
/// @return An instantiation of the `DBSHARINGRelinquishFolderMembershipArg`
/// object.
///
+ (DBSHARINGRelinquishFolderMembershipArg * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
