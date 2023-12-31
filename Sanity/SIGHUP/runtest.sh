#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Dalibor Pospisil <dapospis@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2021 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/bin/rhts-environment.sh || :
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="fapolicyd"

rlJournalStart && {
  rlPhaseStartSetup && {
    rlRun "rlImport --all" 0 "Import libraries" || rlDie "cannot continue"
    tcfRun "rlCheckMakefileRequires" || rlDie "cannot continue"
    rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
    CleanupRegister "rlRun 'rm -r $TmpDir' 0 'Removing tmp directory'"
    CleanupRegister 'rlRun "popd"'
    rlRun "pushd $TmpDir"
    CleanupRegister 'rlRun "rlFileRestore"'
    rlRun "rlFileBackup --clean /opt/testfile"
    CleanupRegister 'rlRun "fapCleanup"'
    rlRun "fapSetup"
  rlPhaseEnd; }

  tcfTry "Tests" --no-assert && {
    rlPhaseStartTest "do not exit on SIGHUP" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      rlRun "systemctl kill --signal SIGHUP fapolicyd"
      rlRun "sleep 3"
      rlRun "rlServiceStatus fapolicyd"
      CleanupDo --mark
    rlPhaseEnd; }

    rlPhaseStartTest "react on SIGHUP" && {
      CleanupRegister --mark 'rlRun "fapStop"'
      rlRun "fapStart"
      rlRun "rlServiceStatus fapolicyd"
      rlRun "systemctl kill --signal SIGHUP fapolicyd"
      rlRun "sleep 10"
      rlRun "systemctl kill --signal SIGHUP fapolicyd"
      rlRun "sleep 10"
      rlRun "systemctl kill --signal SIGHUP fapolicyd"
      rlRun "sleep 10"
      rlRun -s "fapServiceOut -t"
      lns=$(grep 'Syncing DB' $rlRun_LOG | wc -l)
      rlAssertGrep 'Syncing DB' $rlRun_LOG
      rlAssertEquals "the reload was called three times" $lns 3
      rlRun "rlServiceStatus fapolicyd"
      CleanupDo --mark
    rlPhaseEnd; }

    rlPhaseStartTest "TrustDB update on SIGHUP" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      CleanupRegister 'rlRun "rm -f /opt/testfile"'
      rlRun "touch /opt/testfile"
      CleanupRegister 'rlRun "fapolicyd-cli -f delete /opt/testfile"'
      rlRun "fapolicyd-cli -f add /opt/testfile"
      rlRun "systemctl kill --signal SIGHUP fapolicyd"
      rlRun "sleep 10"
      rlRun -s "fapolicyd-cli -D | grep testfile"
      rlAssertGrep '/opt/testfile' $rlRun_LOG
      CleanupDo --mark
    rlPhaseEnd; }
  tcfFin; }

  rlPhaseStartCleanup && {
    CleanupDo
    tcfCheckFinal
  rlPhaseEnd; }
  rlJournalPrintText
rlJournalEnd; }
