<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'passwordsalt' => '',
  'secret' => '',
  'trusted_domains' => 
  array (
    0 => 'localhost',
    1 => 's',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => '',
  'version' => '',
  'overwrite.cli.url' => '',
  'dbname' => '',
  'dbhost' => '',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => '',
  'dbpassword' => '',
  'installed' => true,
  'instanceid' => '',
  'mail_smtpmode' => 'smtp',
  'mail_sendmailmode' => 'smtp',
  'mail_domain' => '',
  'mail_smtpsecure' => '',
  'mail_smtpauthtype' => '',
  'mail_smtpauth' => 1,
  'mail_smtphost' => 's',
  'mail_smtpport' => '',
  'mail_smtpname' => '',
  'mail_smtppassword' => '',
  'twofactor_enforced' => '',
  'twofactor_enforced_groups' => 
  array (
  ),
  'twofactor_enforced_excluded_groups' => 
  array (
  ),
  'overwriteprotocol' => 'https',
  'trusted_proxies' => 
  array (
    0 => '192.168.250.0/24',
  ),
  'maintenance' => false,
  'loglevel' => 2,
  'app_install_overwrite' => 
  array (
    0 => 'twofactor_totp',
  ),
  'theme' => '',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'debug' => false,
  'redis' => 
  array (
    'host' => 'redis',
    'port' => 6379,
    'password' => '',
  ),
);
