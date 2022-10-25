///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMGroupSelector;

#pragma mark - API Object

///
/// The `GroupSelector` union.
///
/// Argument for selecting a single group, either by group_id or by external
/// group ID.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMGroupSelector : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMGroupSelectorTag` enum type represents the possible tag states
/// with which the `DBTEAMGroupSelector` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMGroupSelectorTag) {
  /// Group ID.
  DBTEAMGroupSelectorGroupId,

  /// External ID of the group.
  DBTEAMGroupSelectorGroupExternalId,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMGroupSelectorTag tag;

/// Group ID. @note Ensure the `isGroupId` method returns true before accessing,
/// otherwise a runtime exception will be raised.
@property (nonatomic, readonly, copy) NSString * _Nonnull groupId;

/// External ID of the group. @note Ensure the `isGroupExternalId` method
/// returns true before accessing, otherwise a runtime exception will be raised.
@property (nonatomic, readonly, copy) NSString * _Nonnull groupExternalId;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "group_id".
///
/// Description of the "group_id" tag state: Group ID.
///
/// @param groupId Group ID.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithGroupId:(NSString * _Nonnull)groupId;

///
/// Initializes union class with tag state of "group_external_id".
///
/// Description of the "group_external_id" tag state: External ID of the group.
///
/// @param groupExternalId External ID of the group.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithGroupExternalId:(NSString * _Nonnull)groupExternalId;

- (nonnull instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "group_id".
///
/// @note Call this method and ensure it returns true before accessing the
/// `groupId` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "group_id".
///
- (BOOL)isGroupId;

///
/// Retrieves whether the union's current tag state has value
/// "group_external_id".
///
/// @note Call this method and ensure it returns true before accessing the
/// `groupExternalId` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "group_external_id".
///
- (BOOL)isGroupExternalId;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMGroupSelector` union.
///
@interface DBTEAMGroupSelectorSerializer : NSObject

///
/// Serializes `DBTEAMGroupSelector` instances.
///
/// @param instance An instance of the `DBTEAMGroupSelector` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMGroupSelector` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMGroupSelector * _Nonnull)instance;

///
/// Deserializes `DBTEAMGroupSelector` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMGroupSelector` API object.
///
/// @return An instantiation of the `DBTEAMGroupSelector` object.
///
+ (DBTEAMGroupSelector * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
