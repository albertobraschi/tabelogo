CREATE TABLE `requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `delete_flg` tinyint(4) DEFAULT NULL,
  `rate` tinyint(4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rcd` int(11) DEFAULT NULL,
  `restaurant_name` varchar(255) DEFAULT NULL,
  `tabelog_url` varchar(255) DEFAULT NULL,
  `tabelog_mobile_url` varchar(255) DEFAULT NULL,
  `total_score` float DEFAULT NULL,
  `taste_score` float DEFAULT NULL,
  `service_score` float DEFAULT NULL,
  `mood_score` float DEFAULT NULL,
  `situation` varchar(255) DEFAULT NULL,
  `dinner_price` int(11) DEFAULT NULL,
  `lunch_price` int(11) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `station_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `tel` varchar(255) DEFAULT NULL,
  `business_hours` varchar(255) DEFAULT NULL,
  `holiday` varchar(255) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(40) DEFAULT NULL,
  `salt` varchar(40) DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `delete_flg` tinyint(4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090517052947');

INSERT INTO schema_migrations (version) VALUES ('20090519160535');

INSERT INTO schema_migrations (version) VALUES ('20090527140450');

INSERT INTO schema_migrations (version) VALUES ('20090608101341');