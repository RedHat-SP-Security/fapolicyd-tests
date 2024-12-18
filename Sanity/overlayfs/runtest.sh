#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Dalibor Pospisil <dapospis@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2022 Red Hat, Inc.
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
    CleanupRegister 'rlRun "fapCleanup"'
    rlRun "fapSetup"
    CleanupRegister 'rlRun "rlFileRestore"'
    rlRun "rlFileBackup --clean /usr/bin/id2"
    rlRun "cp /usr/bin/id /usr/bin/id2"
  rlPhaseEnd; }

  expected_default_hardcoded=0
  expected_default_config=0

  tcfTry "Tests" --no-assert && {
    rlPhaseStartTest "DynamicUser - filesystem_mark default setting" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      if [[ $expected_default -eq 0 ]]; then
        rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 0
        rlAssertNotGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
      else
        rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 126
        rlAssertGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
      fi
    rlPhaseEnd; }

    rlPhaseStartTest "DynamicUser - filesystem_mark hardcoded default" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      fapSetConfigOption 'allow_filesystem_mark'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      if [[ $expected_default_hardcoded -eq 0 ]]; then
        rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 0
        rlAssertNotGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
      else
        rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 126
        rlAssertGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
      fi
    rlPhaseEnd; }

    rlPhaseStartTest "DynamicUser - filesystem_mark=0" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      fapSetConfigOption 'allow_filesystem_mark' '0'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 0
      rlAssertNotGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
    rlPhaseEnd; }

    rlPhaseStartTest "DynamicUser - filesystem_mark=1" && {
      CleanupRegister --mark 'rlRun "fapServiceStop"'
      fapSetConfigOption 'allow_filesystem_mark' '1'
      rlRun "fapServiceStart"
      rlRun "rlServiceStatus fapolicyd"
      sleep 5
      rlRun -s "systemd-run --pipe -p DynamicUser=yes bash -c 'id ; id2'" 126
      sleep 5
      rlAssertGrep "/usr/bin/id2: Operation not permitted" $rlRun_LOG -iq
    rlPhaseEnd; }
  tcfFin; }

  rlPhaseStartCleanup && {
    CleanupDo
    tcfCheckFinal
  rlPhaseEnd; }
  rlJournalPrintText
rlJournalEnd; }
