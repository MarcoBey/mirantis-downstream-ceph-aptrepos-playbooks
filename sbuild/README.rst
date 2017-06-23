===============================================
Setup a build host for Ceph downstream packages
===============================================

Synopsis
--------

This playbook simplifies configuration of git-buildpackage and sbuild
for building `Mirantis' downstream Ceph packages`_.

.. _Mirantis' downstream Ceph packages: http://mirror.fuel-infra.org/decapod/ceph

Prerequisites
-------------

* Build host: a system
  
  - running Ubuntu 16.04 (can be a VM, or an lxc container)
  - having enough RAM and CPUs: >= 16 GB RAM, >= 4 cores
  - having a plenty of free disk space: >= 128 GB
    
  Note: the disk space requirement is crucial. It's possible to get away with
  a slower system (less RAM/cores), but there must be enough disk space for
  those object files

* Control host (might be the same as the build host): a Linux system with
  ansible 2.2.x (or newer), an SSH client, and git

* An account on the build host which

  - can run any commands with `sudo` without password
  - reachable via SSH from the control host without a password

  Note: don't use `root` account on the build host, not only it's insecure, but things
  will likely not work at all.

The drill
---------

#. Install ansible 2.2.x (or newer) on the control host, see `ansible installation instructions`_.
#. Clone this very repository on the control host::

     git clone https://github.com/asheplyakov/mirantis-downstream-ceph-aptrepos-playbooks.git

#. Add the build host(s) to the inventory file (use the `hosts.sample` file as an example)::

     cd mirantis-downstream-ceph-aptrepos-playbooks/sbuild
     cp hosts.sample hosts
     vim hosts

#. Specify your name, email, and the GPG key id in the `group_vars/all` file
   under `maintainer` dict.

#. Check if the build host is reachable::

     ansible -m ping -i hosts all

#. Run the playbook::

     ansible-playbook -i hosts site.yml


Where to go from here?
----------------------

Now the build host has a clone Mirantis' downstream Ceph package code in the `~/pkg-ceph`
directory, and tools ready to build it. The package can be built with::

  ./debian/pkgbuild.sh

See `git-buildpackage`_ documentation to find out how to work patches, import
new upstream releases, make downstream releases, and so on. Good luck!

.. _ansible installation instructions: http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu
.. _git-buildpackage: http://honk.sigxcpu.org/projects/git-buildpackage/manual-html/gbp.html
