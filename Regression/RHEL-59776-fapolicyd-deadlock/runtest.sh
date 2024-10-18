#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/fapolicyd/Sanity/trusted-execution
#   Description: The evaluator will configure fapolicyd to allow execution of executable based on path, hash and directory. The evaluator will then attempt to execute executables. The evaluator will ensure that the executables that are allowed to run has been executed and the executables that are not allowed to run will be denied.
#   Author: Dalibor Pospisil <dapospis@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2021 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1
PACKAGE="fapolicyd"

rlJournalStart && {
  rlPhaseStartSetup && {
    rlRun "rlImport --all" 0 "Import libraries" || rlDie "cannot continue"
    #rlRun ". ../../Library/common/lib.sh" || rlDie "cannot import"
    rlRun "rlCheckMakefileRequires" || rlDie "cannot continue"
    rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
    CleanupRegister "rlRun 'rm -r $TmpDir' 0 'Removing tmp directory'"
    CleanupRegister 'rlRun "popd"'
    rlRun "pushd $TmpDir"
    rlRun "chmod -R a+rwx $TmpDir"
    CleanupRegister 'fapCleanup'
    fapPrepareTestPackages true
    CleanupRegister 'rlRun "rpm -e fapTestPackage fapTestPackage-second"'
    #rlRun "dnf install bzip2 debugedit elfutils patch system-rpm-config zstd popt-devel -y"
    #rlRun "mkdir rpm_package_older"
    #pushd rpm_package_older
    #el9
    #wget https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/python3-rpm-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-build-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-build-libs-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-devel-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-libs-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-audit-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-fapolicyd-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-ima-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-prioreset-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-selinux-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-syslog-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-systemd-inhibit-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-sign-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-sign-libs-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/python3-rpm-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-build-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-build-libs-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-debugsource-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-devel-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-libs-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-audit-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-fapolicyd-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-ima-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-prioreset-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-selinux-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-syslog-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-plugin-systemd-inhibit-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-sign-debuginfo-4.16.1.3-27.el9.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9/x86_64/rpm-sign-libs-debuginfo-4.16.1.3-27.el9.x86_64.rpm
    #RHEL 9.3
    #wget https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/python3-rpm-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-build-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-build-libs-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-devel-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-libs-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-audit-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-fapolicyd-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-ima-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-prioreset-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-selinux-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-syslog-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-systemd-inhibit-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-sign-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-sign-libs-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/python3-rpm-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-build-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-build-libs-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-debugsource-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-devel-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-libs-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-audit-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-fapolicyd-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-ima-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-prioreset-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-selinux-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-syslog-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-plugin-systemd-inhibit-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-sign-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/rpm/4.16.1.3/27.el9_3/x86_64/rpm-sign-libs-debuginfo-4.16.1.3-27.el9_3.x86_64.rpm
    #rlRun "rpm -Uhv --force *"
    #rlRun "wget https://download.devel.redhat.com/brewroot/work/tasks/9119/65189119/fapolicyd-1.3.2-100.el9_4.test_sigbus_hotfix_01.x86_64.rpm https://download.devel.redhat.com/brewroot/work/tasks/9119/65189119/fapolicyd-selinux-1.3.2-100.el9_4.test_sigbus_hotfix_01.noarch.rpm"
    #popd
  rlPhaseEnd; }

  rlPhaseStartTest "functionality check" && {
    #rlRun "dnf downgrade rpm-4.16.1.3-29.el9.x86_64 -y"
    rlRun "fapServiceStart"
    #run fapolicyd
    #dowload packages
    wget https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/tcsh/6.22.03/6.el9/x86_64/tcsh-6.22.03-6.el9.x86_64.rpm
    wget https://download.devel.redhat.com/brewroot/vol/rhel-9/packages/zsh/5.8/9.el9/x86_64/zsh-5.8-9.el9.x86_64.rpm
    #bash
    #rlRun "while :; do rpm -i ./fapTestPackage-1-1.x86_64.rpm ; rpm -i ./fapTestPackage-second-1-1.x86_64.rpm; done"
    rlRun "while :; do rpm -i ./tcsh-6.22.03-6.el9.x86_64.rpm ; rpm -i ./zsh-5.8-9.el9.x86_64.rpm; done"
    CleanupRegister 'rlRun "rpm -e tcsh-6.22.03-6.el9.x86_64.rpm zsh-5.8-9.el9.x86_64.rpm"'
    CleanupRegister --mark 'rlRun "fapStop"'
    #rlRun "rpm -i .${fapTestPackage[1]} ; rpm -i .${fapTestPackage[2]}"
  rlPhaseEnd; }

  rlPhaseStartCleanup && {
    CleanupDo
  rlPhaseEnd; }
  rlJournalPrintText
rlJournalEnd; }
