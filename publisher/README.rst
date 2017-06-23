=============================================================
Mirantis' downstream Ceph APT repository management playbooks
=============================================================

Synopsis
--------

These playbooks publish packages from the APT repository located on developer's
machine to the semi-public APT repository at perestroika_, which in pushes them
further to the public `Mirantis' Ceph APT repository`_

.. _perestroika: rsync://perestroika-repo-tst.infra.mirantis.net/decapod/ceph
.. _Mirantis' Ceph APT repository: http://mirror.fuel-infra.org/decapod/ceph
.. _public: http://mirror.fuel-infra.org/decapod/ceph


Workflow
--------

* Developer builds binary packages with git-buildpackage and sbuild
* The build script puts the newly built packages in the staging APT repository
* Developer runs sanity checks and uploads packages from the staging repository
  to the semi-public (perestroika_) one using these playbooks
* Some time later perestroika_ APT repository gets rsynced to 
  `Mirantis' Ceph APT repository`_

The staging repository layout
------------------------------

The staging APT repository is supposed to hold all supported Ceph release
(for all supported Ubuntu releases). More accurately packages of specific 
Ceph release for a given Ubuntu release must be available via the following
APT URL::

  deb ${src_repo_url} ${ceph_release}-${ubuntu_release} main

For example the URL of Jewel packages for Ubuntu 16.04::

  deb http://127.0.0.1/Public/repos/ceph jewel-xenial main

(note: ``file:///`` URL are OK, and obviously one can fetch packages from
any host, not just localhost).

The base URL of the staging repository (denoted as `src_repo_url`) can be
specified in the `group_vars/all` file.


The public repository layout
----------------------------

The public repository *must* be available to clients via the following URL::

  deb http://mirror.fuel-infra.org/decapod/ceph/${ceph_release}-${ubuntu_release} ${ceph_release}-${ubuntu_release} main

For example, the above URL of Jewel packages for Ubuntu 16.04::

  deb http://mirror.fuel-infra.org/decapod/ceph/jewel-xenial jewel-xenial main
 

GPG signatures
--------------

The staging repository is assumed to be GPG signed, the playbook
(or rather `reprepro` utility) verifies the GPG signatures of the staging
repository metadata (`Release`, `Packages` files, and so on).

The public repository is also GPG signed. It must be signed on every
upload (run of these playbooks) only a subset of the packages from
the staging repository gets copied (in particular debugging packages
are omitted due to their enormous size ~ 2GB!), and the structure of
the staging repo differs from that of the public repo.

As of now both the staging repository and the (semi-)public one are signed with
the same key specified by `gpg_key_id` variable in the `group_vars/all` file.


Extracting packages for upload
------------------------------

::

  ansible-playbook -i hosts -e dry_run='' subrepos.yml

This will copy Ceph packages from the staging APT repository (specified
by `src_repo_url` variable in the `group_vars/all` file) according to
the `supported_releases` dict (by default Jewel packages for Ubuntu 16.04
and 14.04 are copied), organize them into the correct hierarchy under
the `subrepos_root` directory, generate the meta-data for APT, sign it
with the specified GPG key (`gpg_key_id`), carefully rsync `subrepos_root`
to the semi-public perestroika_ repository (and cron running on perestroika
will eventually propagate those packages to the public_ APT repository).

To simulate the upload (i.e. to find out which files will be transferred)
one can use following command::

  ansible-playbook -i hosts subrepos.yml

After inspecting rsync output (and/or the temporary repositories under the
`subrepos_root` directory) one can upload the result of the above command::

  ansible-playbook -i hosts -e dry_run='' sync.yml
