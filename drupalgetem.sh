#!/bin/bash
#
# Preconditions:
# 1) drush, git and/or svn commands must exist in the environment path
# 2) Drupal root must be the current directory of the site you want to evaluate
#
CMDS="drush"
if [[ -d ".svn" ]]; then
  CMDS="drush svn"
fi
if [[ -d ".git" ]]; then
  CMDS="drush git"
fi
if [[ "$CMDS" == "drush" ]]; then
  echo "No git or svn repository exists."
fi
for i in $CMDS
do
  command -v $i > /dev/null && continue || { echo "$i command not found."; exit 1; }
done
drush archive-dump
if [[ ! -d "$HOME/.drush/drupalgeddon" ]]; then
  drush dl drupalgeddon
fi
if [[ ! -d "$HOME/.drush/site_audit" ]]; then
  drush dl site_audit
fi
security_review_module=$(drush sqlq --extra=-N "SELECT filename FROM system WHERE name = 'security_review'")
if [[ ! -f "$security_review_module" ]]; then
  drush dl security_review
  drush en -y security_review
fi
drush cc drush
echo ""
drush audit_security
echo ""
echo "Security review:"
drush security-review
echo ""
echo "Custom blocks that contain php code:"
drush sqlq --extra=-t "SELECT * FROM block_custom WHERE format = 'php_code'"
echo ""
echo "View displays that contain php code:"
drush sqlq --extra=-t "SELECT * FROM views_display WHERE display_options LIKE '%<?php%'"
echo ""
echo "Files that have changed recently:"
today=$(date -u +%s)
psa=$(date -ud '2014-10-15' +%s)
days=$(( ( $today - $psa )/60/60/24 ))
find . -type f -mtime -$days -exec ls -la {} \; | egrep -v '(\.git|\.svn)'
echo ""
echo "PHP files found in sites/default/files:"
find sites/default/files/ -type f -name '*.php' -exec ls -la {} \; | egrep -v '(\.git|\.svn)'
echo ""
echo ".htaccess files found in sites/default/files:"
find sites/default/files/ -type f -name '.htaccess' -exec ls -la {} \; | egrep -v '(\.git|\.svn)'
echo ""
find sites/default/files/ -type f -name '.htaccess' -exec cat {} \; | egrep -v '(\.git|\.svn)'
echo ""
echo "Files with malicious calls to eval() (ignore php and devel modules):"
grep -nRH --exclude=*.js 'eval(' *
echo ""
echo "Users who have accessed the site recently:"
drush sqlq --extra=-t "SELECT name, mail, FROM_UNIXTIME(access) AS last_access FROM users WHERE access > UNIX_TIMESTAMP('2014-10-15 00:00:00') ORDER BY access"
echo ""
echo "Users with admin role who have accessed the site recently:"
drush sqlq --extra=-t "SELECT u.name, u.mail, FROM_UNIXTIME(u.access) AS last_access FROM users u INNER JOIN users_roles r ON r.uid = u.uid WHERE r.rid = 3 AND u.access > UNIX_TIMESTAMP('2014-10-15 00:00:00') ORDER BY u.access"
echo ""
echo "Users with administer permissions who have accessed the site recently:"
drush sqlq --extra=-t "SELECT name, mail, FROM_UNIXTIME(access) AS last_access FROM users u WHERE uid IN (SELECT uid FROM users_roles WHERE rid IN (SELECT DISTINCT rid FROM role_permission WHERE permission LIKE 'administer%')) AND access > UNIX_TIMESTAMP('2014-10-15 00:00:00') ORDER BY access"
echo ""
# Reference: https://www.drupal.org/node/2365547
#echo "Reset all user passwords? (y/n) [n]:"
#read reset
#if test "$reset" -eq "y"; then
#  drush sqlq "UPDATE users SET pass = CONCAT('ZZZ', SHA(CONCAT(pass, MD5(RAND()))))"
#fi
if [[ -d ".svn" ]]; then
  svn diff
fi
if [[ -d ".git" ]]; then
  git diff
fi
