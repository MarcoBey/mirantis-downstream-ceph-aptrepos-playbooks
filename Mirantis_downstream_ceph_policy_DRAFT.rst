==================================================
Miratis' downstream Ceph -- why, what, how (draft)
==================================================

Introduction
============

Mirantis provides modified Ceph packages to address bugs and limitations
that are crucial for customers and internal infrastructure. At the same
time Mirantis strives to *not* fork Ceph, that is

* Only one LTS version of Ceph is supported (Jewel at this time)
* We track the upstream releases as close as reasonable
* We keep patches as minimal and non-intrusive as possible
* We try to push as many patches as possible to upstream
* We support Ceph usage for the block (rbd) and the object storage
  (radosgw) only, other features like cephfs, exporting data via nfs,
  etc, are not supported


Valid reasons for a modification (patch)
========================================

* Data loss or a corruption (including the ones "by design", i.e. due to
  a counter-intuitive CLI command), examples:

  - http://tracker.ceph.com/issues/17545
  - http://tracker.ceph.com/issues/14512
  - http://tracker.ceph.com/issues/11493

* Client (qemu, libvirt, nova, etc) failure (assert, segfault,
  lockup, infinite loop, etc), examples:

  - http://tracker.ceph.com/issues/18436
  - http://tracker.ceph.com/issues/5488


* Server (ceph-osd, ceph-mon, radosgw) crash during a routine operation,
  in particular 

  - OSD assert()/segfault/lockup/intinite loop during peering, recovery, scrubbing
  - crashes which can be triggered by users (both programs and human ones)
  - crashes caused by non-fatal metadata inconsistency

  Examples:

  - http://tracker.ceph.com/issues/16474
  - http://tracker.ceph.com/issues/18258
  - http://tracker.ceph.com/issues/17188
  - http://tracker.ceph.com/issues/18488
  - http://tracker.ceph.com/issues/12892
  - http://tracker.ceph.com/issues/14191
  - http://tracker.ceph.com/issues/18187
  - http://tracker.ceph.com/issues/10262
  - http://tracker.ceph.com/issues/15943
  - http://tracker.ceph.com/issues/14428

* Serious resource leaks (either on the client or the server side), examples:

  - http://tracker.ceph.com/issues/13990
  - http://tracker.ceph.com/issues/18300
  - http://tracker.ceph.com/issues/16801
  - http://tracker.ceph.com/issues/16000
  - http://tracker.ceph.com/issues/12065

* Upgrade (from the previous/same LTS releases) issues, examples:

  - http://tracker.ceph.com/issues/18582
  - http://tracker.ceph.com/issues/19508

* Deployment/operational problems, examples:

  - http://tracker.ceph.com/issues/15678

* Wrong monitoring/performance information which breaks supported
  monitoring tools (TODO: clarify which ones), examples:

  - http://tracker.ceph.com/issues/16277


Please note that the above list does *not* include "client XXX wants this feature/patch"


The workflow
============

#. Check if the issue has been solved in the pending upstream bugfix-only release, if yes

   - cherry-pick the corresponding patch(es) to downstream
   - Build the package and run the basic tests
   - Proceed to the next bug (or have fun if there are none)

#. Check if the issue has been solved in the upstream development branch (master), if yes

   - Check if there's a `Backport` ticket in the upstream tracker, if not -- file one.
   - Backport the patch(es) from the (upstream) master branch to the (upstream) LTS one.
   - Submit a backport pull request to the upstream LTS branch
   - If core developers haven't rejected the above PR cherry-pick it
     to the downstream repository
   - Build the package and run the basic tests

Things to avoid
---------------

* Re-inventing the wheel: please check for a fix in the upstream LTS and 
  master branches
* Forking Ceph: please submit patches to upstream and keep the maintenance
  burden reasonable
* Skipping the review: please wait for a feedback from the core Ceph developers
  (unless it takes unreasonably long, like more than 3 -- 10 days)


Being proactive
---------------

* Search for the issues satisfying the `Valid reasons for a modification (patch)`_
  criteria in the `ceph-users`_ mailing list and the `upstream bug tracker`_,
  and treat them as if they have been already reported by a customer
* Participate in the upstream backporting effort


Testing modifications
=====================

The following qa suites should be run

* rados
* rbd
* rgw
* powercycle
* upgrade/hammer-x
* upgrade/jewel-x/point-to-point-x
* upgrade/client-upgrade
* ceph-disk


Downstream infrastructure
=========================

* `Source code repository`_ (uses `git-buildpackage`_ branches layout)
* `APT repository for Ubuntu 16.04`_

.. _upstream bug tracker: http://tracker.ceph.com
.. _ceph-users: http://lists.ceph.com/pipermail/ceph-users-ceph.com
.. _Source code repository: http://github.com/asheplyakov/pkg-ceph
.. _APT repository for Ubuntu 16.04: http://mirror.fuel-infra.com/decapod/ceph/jewel-xenial
.. _git-buildpackage: http://honk.sigxcpu.org/projects/git-buildpackage/manual-html

