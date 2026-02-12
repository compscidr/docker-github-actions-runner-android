#!/bin/bash
# Post-job cleanup script for GitHub Actions runner.
# Invoked automatically via ACTIONS_RUNNER_HOOK_JOB_COMPLETED after each job.
# Removes rebuildable caches that grow unbounded between jobs.

echo "Running post-job cleanup..."

# Temp files from builds
rm -rf /tmp/*

# Gradle build caches (rebuilt each job from source)
rm -rf /root/.gradle/caches/build-cache-*
rm -rf /root/.gradle/caches/transforms-*
rm -rf /root/.gradle/caches/journal-*

# Gradle daemon logs and state
rm -rf /root/.gradle/daemon/

# Runner diagnostic logs
rm -f /actions-runner/_diag/*.log
rm -f /runner-data/_diag/*.log

echo "Post-job cleanup complete."
