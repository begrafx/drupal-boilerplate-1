#!/bin/sh

# For now only Drush 6 supports sql-sync
if [ "${DRUPAL_MAJOR_VERSION}" = "7" ] && [ "${SYNC_METHOD}" = "AUTO" ] && [ "$(drush st | grep -i 'Drush version' | awk -F ':' '{print $2}' |  sed -e 's/^[ \t]*//')" != "6.1.0" ]; then
  composer global require drush/drush:6.1.0
fi

# Copy some defaults if do not exists
for f in /app/drush/defaults/modules/* ; do cp -n "$f" "/app/drush/modules" ; done
for f in /app/drush/defaults/aliases/* ; do cp -n "$f" "/app/drush/aliases" ; done
mkdir -p /app/drush/local
for f in /app/drush/defaults/local/* ; do cp -n "$f" "/app/drush/local" ; done
cp -n /app/drush/defaults/drushrc.php /app/drush/drushrc.php

# Symlink to project drushrc.php file.
mkdir -p $HOME/.drush
ln -s /app/drush/drushrc.php $HOME/.drush/drushrc.php > /dev/null 2>&1

# Create basic module containers
mkdir -p /app/drupal/sites/all/modules/contrib
mkdir -p /app/drupal/sites/all/modules/custom
mkdir -p /app/drupal/sites/all/drush

# Symlink to drushrc inside sites/all/drush
ln -s ../../../../drush/drushrc.php /app/drupal/sites/all/drush/drushrc.php > /dev/null 2>&1

mkdir -p /app/private/${DRUPAL_SUBDIR}


# Wait for database
while ! mysql -h${MYSQL_HOST_NAME} -p${MYSQL_ENV_MYSQL_ROOT_PASSWORD}  -e ";" ; do
  sleep 0.5
done
echo "Connected to ${MYSQL_HOST_NAME}";
