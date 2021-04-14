CREATE TABLE `users` (
  `uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Use uuid as primary key for security, so that it is harder for the attackers to guess',
  `username` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Unique and limit to 50 chars',
  `password` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Limit to 64 char to store the sha256 hashed passwords and avoid accidental leak',
  `is_custom_avatar` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Just need to store here whether a user is using a custom URL here as each user will only allowed one avatar, and the asset URL can be infered from the user uuid',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Track user creation, also this can be used for messages like "member since"',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Track user update',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_index_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `uuid` varchar(36) NOT NULL DEFAULT '',
  `user_uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Uuid of the user to associate to',
  `title` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Limit the size to up 500 in case html is needed',
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT 'Text data type should be big enough to covers most of the case; Content is nullable for semi-delete or redaction',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Track post creation',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Track post update',
  PRIMARY KEY (`uuid`),
  KEY `posts_foreign_key_user_uuid` (`user_uuid`),
  CONSTRAINT `posts_foreign_key_user_uuid` FOREIGN KEY (`user_uuid`) REFERENCES `users` (`uuid`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `uuid` varchar(36) NOT NULL DEFAULT '',
  `post_uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Uuid of the post to associate to',
  `user_uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Uuid of the user to associate to',
  `content` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Limit size of comment to 1000 chars, content is nullable for semi-delete or redaction',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Track comment creation',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Track comment update',
  PRIMARY KEY (`uuid`),
  KEY `comments_foreign_key_user_uuid` (`user_uuid`),
  KEY `comments_foreign_key_post_uuid` (`post_uuid`),
  CONSTRAINT `comments_foreign_key_post_uuid` FOREIGN KEY (`post_uuid`) REFERENCES `posts` (`uuid`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `comments_foreign_key_user_uuid` FOREIGN KEY (`user_uuid`) REFERENCES `users` (`uuid`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- I choose to use an entity-attribute-value model for the post_properties table to allow storing properties like "tags" which can have an array of values, plus it is flexible and can be easily expanded
-- The down side of the EAV is that it will need strict data enforcement from the ORM or in the blog app itself, also it can be inefficient if the data set gets large
CREATE TABLE `post_property_types` (
  `uuid` varchar(36) NOT NULL DEFAULT '',
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Name of the property, for example"summary", "tag", "image_url", etc',
  `is_multiple_allowed` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Clarify if a property can have multiple values and should be treated as array, or just single value',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_index_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `post_properties` (
  `uuid` varchar(36) NOT NULL DEFAULT '',
  `type_uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Limit the possible type value to the post_property_types table; Whether to allow multiple of rows for the same type on a single post can be determined base on the Is_multiple_allowed of the type',
  `post_uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'Uuid of the post to associate to',
  `value` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Limit the size of value, content is nullable for semi-delete or redaction',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Track property creation',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Track property update',
  PRIMARY KEY (`uuid`),
  KEY `post_properties_foreign_key_type_uuid` (`type_uuid`),
  KEY `post_properties_foreign_key_post_uuid` (`post_uuid`),
  CONSTRAINT `post_properties_foreign_key_post_uuid` FOREIGN KEY (`post_uuid`) REFERENCES `posts` (`uuid`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `post_properties_foreign_key_type_uuid` FOREIGN KEY (`type_uuid`) REFERENCES `post_property_types` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
