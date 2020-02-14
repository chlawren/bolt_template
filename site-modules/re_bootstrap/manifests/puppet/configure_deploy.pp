# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include re_bootstrap::puppet::configure_deploy
#
class re_bootstrap::puppet::configure_deploy (
  $re_control_repo_keyname = '/etc/puppetlabs/puppetserver/ssh/r10k_deploy',
  $git_url                 = 'git@co-vsv-01-0031.idm.pre.gpn.gov.uk:rel_engineering/re-control-repo.git',
){

  file { '/etc/puppetlabs/puppetserver/ssh':
    ensure => 'directory',
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0700',
  }

  file { "${re_control_repo_keyname}":
    ensure  => 'file',
    content => 'Manually deploy the private key',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0600',
  }

  pe_node_group { 'PE Master':
    ensure        => 'present',
    classes       => {
      'pe_repo' => {
        'enable_bulk_pluginsync' => false
      },
      'pe_repo::platform::el_7_x86_64'      => {},
      'pe_repo::platform::windows_x86_64'   => {},
      'puppet_enterprise::profile::master' => {
         'code_manager_auto_configure'     => true,
         'r10k_private_key'                => "${re_control_repo_keyname}",
         'r10k_remote'                     => "${git_url}",
         'replication_mode'                => 'none'
       }
    },
      environment        => 'production',
      environment_trumps => false,
      parent             => 'PE Infrastructure',
      pinned             => [$facts['clientcert']],
      rule               => ['or', ['=', 'name', $facts['clientcert'] ]],
    }

    pe_node_group {'PE Console':
      ensure      => 'present',
      classes     => {
        'puppet_enterprise::license'        => {
          'manage_license_key' => false
      },
      'puppet_enterprise::profile::console' => {}
    },
      environment        => 'production',
      environment_trumps => false,
      parent             => 'PE Infrastructure',
      pinned             =>  [$facts['clientcert']],
      rule               => ['or', ['=', 'name', $facts['clientcert'] ]],
    }

    file { '/etc/puppetlabs/license.key':
      ensure  => 'file',
      content => 'puppet:///modules/re_bootstrap/etc/puppetlabs/license.key',
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0644',
   }

   pe_node_group { 'Controller Workstation':
  ensure             => 'present',
  classes            => {
  'puppet_enterprise::profile::controller' => {

  }
},
  environment        => 'production',
  environment_trumps => false,
  parent             => 'All Nodes',
}

}
