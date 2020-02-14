plan re_bootstrap::switchover (
  TargetSpec $nodes,
  String $master,
){
    run_task ('re_bootstrap::agent_switchover',$nodes,'_run_as'=>root, master=>$master)
    run_task ('bootstrap',$nodes,'_run_as'=>root, master=>$master)
    run_command ('/opt/puppetlabs/puppet/bin/puppet agent -t --waitforcert=30s',$nodes,'_run_as'=>root)
}
