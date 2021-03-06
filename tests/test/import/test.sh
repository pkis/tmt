#!/bin/bash
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup
        rlRun "tmp=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "cp -a data $tmp"
        rlRun 'pushd $tmp/data/parent/child'
        rlRun 'set -o pipefail'
    rlPhaseEnd

    rlPhaseStartTest 'Import metadata'
        rlRun 'tmt test import --no-nitrate | tee output'
        rlAssertGrep 'summary: Simple smoke test' 'main.fmf'
        rlRun 'grep -A1 require main.fmf | grep tmt'
        rlRun 'grep -A1 recommend main.fmf | grep fmf'
    rlPhaseEnd

    rlPhaseStartTest 'Check duplicates'
        rlAssertNotGrep 'component:' 'main.fmf'
        rlAssertNotGrep 'test:' 'main.fmf'
        rlAssertNotGrep 'duration:' 'main.fmf'
    rlPhaseEnd

    rlPhaseStartTest 'Check rhts-environment removal'
        rlAssertGrep 'Removing.*rhts-environment' 'output'
        rlAssertNotGrep 'rhts-environment' 'runtest.sh'
    rlPhaseEnd

    rlPhaseStartTest 'Verify inheritance'
        rlRun 'tmt test show | tee output'
        rlAssertGrep 'component tmt' 'output'
        rlAssertGrep 'test ./runtest.sh' 'output'
        rlAssertGrep 'duration 5m' 'output'
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "rm -r $tmp" 0 "Removing tmp directory"
        rlRun 'popd'
    rlPhaseEnd
rlJournalEnd
