
# apply_helpers

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with apply_helpers](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)

## Description

This module provides helper tasks that are used by the `apply()` functionality in [Bolt](https://github.com/puppetlabs/bolt). These tasks are not intended to be run on their own, but as part of a [bolt plan](https://puppet.com/docs/bolt/latest/writing_plans.html) that uses the [apply keyword](https://puppet.com/docs/bolt/latest/applying_manifest_blocks.html).

This module allows Bolt plans using `apply()` to be run on a Puppet Enterprise (PE) installation.

## Setup

1. First you'll need to install the [puppetlabs-puppet_agent](https://github.com/puppetlabs-puppet_agent) module from the master branch on github. The easiest way to do this is to add
    ```
    mod 'puppetlabs-puppet_agent', :git => 'https://github.com/puppetlabs/puppetlabs-puppet_agent.git'
    ```
    to your `Puppetfile`. Alternatively you can clone the `puppetlabs-puppet_agent` repo, build it locally, and use the [Puppet Development Kit](https://puppet.com/docs/pdk/1.x/pdk_building_module_packages.html#concept-9267) to install
    ```
    git clone https://github.com/puppetlabs/puppetlabs-puppet_agent.git
    cd puppetlabs-puppet_agent
    pdk build
    puppet module install ./pkg/puppetlabs-puppet_agent-version.tar.gz
    ```
    from the commandline
1. Install the `apply_helpers` module in PE. Add the following to your `Puppetfile`:
    ```
    mod 'puppetlabs-apply_helpers'
    ```
    Or install using the puppet module command:
    ``` 
    puppet module install puppetlabs/apply_helpers
    ```
1. Using PE RBAC, grant the ability to run the `apply_helpers::custom_facts` and `apply_helpers::apply_catalog` tasks to the users who intend to use this module.

## Usage

Configure Bolt to [work with PE Orchestrator](https://puppet.com/docs/bolt/latest/bolt_configure_orchestrator.html) and run Bolt commands or Tasks from the console.

## Reference

This module includes tasks that are invoked automatically by Bolt: `apply_helpers::custom_facts` and `apply_helpers::apply_catalog`. These tasks should not be run on their own.

