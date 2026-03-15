#!/bin/bash
# Post-job cleanup script for GitHub Actions runner.
# Invoked automatically via ACTIONS_RUNNER_HOOK_JOB_COMPLETED after each job.
# Removes rebuildable caches that grow unbounded between jobs.
#
# Intentionally not using set -e: individual cleanup failures should not
# prevent other cleanups from running.

echo "[cleanup] Running post-job cleanup..."
BEFORE=$(df -h / | awk 'NR==2 {print $4}')

# Temp files from builds
find /tmp -mindepth 1 -delete 2>/dev/null || true

# Gradle build caches (rebuilt each job from source)
rm -rf /root/.gradle/caches/build-cache-* 2>/dev/null || true
rm -rf /root/.gradle/caches/transforms-* 2>/dev/null || true
rm -rf /root/.gradle/caches/journal-* 2>/dev/null || true

# Gradle daemon logs and state
rm -rf /root/.gradle/daemon/ 2>/dev/null || true

# Runner diagnostic logs
find /actions-runner/_diag -name '*.log' -delete 2>/dev/null || true
find /runner-data/_diag -name '*.log' -delete 2>/dev/null || true

AFTER=$(df -h / | awk 'NR==2 {print $4}')
echo "[cleanup] Post-job cleanup complete. Disk free: ${BEFORE} -> ${AFTER}"
