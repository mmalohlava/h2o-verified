Bug in snapshotting
===================

Description
-----------
The global snapshot takes a view of KV store - it collects a state of all KVs in
cluster and merge them together. 

In this case snapshotting sometimes hit the moment when local KV store
(represented by non blocking hash map NBHM) was growing and was not in expected state.

Reported as PUB-895.

Fix
---

Introduced in 3969cd2 - handling correctly intermediate state of NBHM

Tests
-----

  * High-level R test introduced in 65ebe33: `R/tests/testdir_jira/runit_pub895_NOPASS.R`
    * factorizing each column of given dataset

  * Dummy junit test introduce in eef4822: `src/test/java/water/TestKeySnapshotLong.java`
    * Test is generating many keys and trying to force put NBHM into intermediate
      growing state and take a snapshot


