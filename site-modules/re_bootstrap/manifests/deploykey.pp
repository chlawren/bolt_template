# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include re_bootstrap::deploykey
class re_bootstrap::deploykey (
  String $username
){
  file { "/home/${facts}['domain']/${username}/.ssh/r10k_deploy":
  ensure  => 'file',
  content => '{md5}b6d920ce273b0b9dc021e806223138ab',
  group   => 79401196,
  mode    => '0600',
  owner   => 79401196,
}


}
