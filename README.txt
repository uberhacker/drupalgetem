Installation:

Repo: git clone https://github.com/uberhacker/drupalgetem.git
Direct download: https://github.com/uberhacker/drupalgetem/archive/master.zip

Copy drupalgetem.sh from the cloned repo or download directory to your ~/bin directory so it can be executed anywhere on the server.  If you don't have a ~/bin directory, create one: mkdir ~/bin.  Make sure the script is executable: chmod +x ~/bin/drupalgetem.sh

Usage:

$ cd /path/to/drupal/root
$ drupalgetem.sh &> ~/report.txt - This exports the results to report.txt in your home directory.

Disclaimer:

This script does NOT work with site aliases.

Tips:

Download the archive file locally (or to another server):
Example:
$ scp -P 6421 [me]@someserver.com:/home/[me]/drush-backups/archive-dump/20141107195502/site_name.20141107_195502.tar.gz .  Replace [me] with your username.

Download the report file locally (or to another server):
Example:
$ scp -P 6421 [me]@someserver.com:/home/[me]/site_name-201411071355.txt .  Replace [me] with your username.

This script is released under the GNU GPL license.
