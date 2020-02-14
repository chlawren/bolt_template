#puppet apply --noop -e 'include re_bootstrap::puppet::configure_deploy' --modulepath=/opt/software/re-control-repo/site-modules:`puppet config print modulepath`
puppet apply  -e 'include re_bootstrap::puppet::configure_deploy' --modulepath=/opt/software/re-control-repo/site-modules:`puppet config print modulepath`

# puppet apply --noop -e 'class {"re_bootstrap::puppet::configure":}'
