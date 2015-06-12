echo "Installing SFU Library specific modules, etc."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Note: Gitlab permissions not working for vagrant.
if [ -f "$SHARED_DIR/id_rsa" ]; then
  echo "Copying id_rsa to $HOME_DIR/.ssh"
  cp "$SHARED_DIR/id_rsa" "$HOME_DIR/.ssh"
  chown vagrant "$HOME_DIR/.ssh/id_rsa"
  chmod 400 "$HOME_DIR/.ssh/id_rsa"
else
  echo "Could not copy $SHARED_DIR/id_rsa to $HOME_DIR/.ssh"
fi

cd "$DRUPAL_HOME/sites/all/modules"

# Install/enable some modules.
drush --yes en features
drush --yes en strongarm
drush --yes en module_filter
drush --yes en admin_menu
drush --yes en admin_menu_toolbar
drush --yes en views_ui
drush --yes en views_bulk_operations

# Disable some modules.
drush --yes dis toolbar
drush --yes dis overlay
drush --yes dis islandora_marcxml

# Get Islandora Newspaper Batch module.
git clone https://github.com/mjordan/islandora_newspaper_batch.git
drush --yes en islandora_newspaper_batch

# Get the test feature module, enable it, and revert the feature.
git clone http://git.lib.sfu.ca/mjordan/islandora_test_site.git
drush --yes en islandora_test_site
drush --yes features-revert islandora_test_site

# Load some sample content.
git clone https://github.com/mjordan/islandora_scg.git
drush --yes en islandora_scg
drush --yes cc drush
drush iscgl --user=admin --quantity=10 --content_model=islandora:sp_basic_image --parent=islandora:sp_basic_image_collection --namespace=testing
