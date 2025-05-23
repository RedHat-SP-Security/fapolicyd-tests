#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/fapolicyd/Sanity/cli-options
#   Description: Test for BZ#1817413 (Rebase FAPOLICYD to the latest upstream version)
#   Author: Dalibor Pospisil <dapospis@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2020 Red Hat, Inc.
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

Stop() {
  fapStop
}
Start() {
  fapStart
}
Update() {
  rlRun "fapolicyd-cli --update"
  rlRun "sleep 10s"
}

workaround=${workaround:-true}

TESTDIR_ALL="/var/testdir/subdir"
TESTDIR="/var/testdir/"
TESTFILE_FIRST="/var/testfile"
TESTFILE_SECOND="/var/testdir/testfile"
TESTFILE_THIRD="/var/testdir/subdir/testfile"

rlJournalStart && {
  rlPhaseStartSetup && {
    rlRun "rlImport --all" 0 "Import libraries" || rlDie "cannot continue"
    tcfRun "rlCheckMakefileRequires" || rlDie "cannot continue"
    rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
    CleanupRegister "rlRun 'rm -r $TmpDir' 0 'Removing tmp directory'"
    rlRun "cp -r files $TmpDir/"
    CleanupRegister 'rlRun "popd"'
    rlRun "pushd $TmpDir"
    CleanupRegister 'rlRun "fapCleanup"'
    rlRun "fapSetup"
    CleanupRegister 'rlRun "Stop"'
    rlRun "Start"
    CleanupRegister "rlFileRestore"
    rlRun "rlFileBackup --clean $TESTDIR $TESTFILE_FIRST"
    rlRun "mkdir -p $TESTDIR_ALL"
    rlRun "touch $TESTFILE_FIRST"
    rlRun "touch $TESTFILE_SECOND"
    rlRun "touch $TESTFILE_THIRD"
  rlPhaseEnd; }

  tcfTry "Tests" --no-assert && {
    rlPhaseStartTest "options recognition AC2" && {
      rlRun -s "fapolicyd-cli --help"
      opts="-d --delete-db -D --dump-db -f --file -t --ftype -l --list -u --update"
      for opt in $opts; do
        rlAssertGrep "$opt" $rlRun_LOG
      done
      rm -f $rlRun_LOG
      $workaround && Stop
      opts="-D --dump-db"
      for opt in $opts; do
        rlRun "fapolicyd-cli $opt > /dev/null"
      done
      opts="-d --delete-db"
      for opt in $opts; do
        rlRun "fapolicyd-cli $opt"
      done
      Start
      opts="-u --update -l --list"
      for opt in $opts; do
        rlRun "fapolicyd-cli $opt"
      done
      opts="-f --file -t --ftype"
      for opt in $opts; do
        rlRun -s "fapolicyd-cli $opt" 1-255
        rlAssertGrep "option .*requires an argument" $rlRun_LOG
        rm -f $rlRun_LOG
      done
    rlPhaseEnd; }

    rlPhaseStartTest "file subcommands AC3" && {
      rlRun -s "fapolicyd-cli -f add" 0-255
      rlAssertGrep "Wrong number of arguments" $rlRun_LOG
      rlAssertNotGrep "missing operation option|invalid|unknown|illegal|bad|unrecognized|undefined|unexpected" $rlRun_LOG -Eiq
      rm -f $rlRun_LOG
      rlRun -s "fapolicyd-cli -f delete" 0-255
      rlAssertGrep "Wrong number of arguments" $rlRun_LOG
      rlAssertNotGrep "missing operation option|invalid|unknown|illegal|bad|unrecognized|undefined|unexpected" $rlRun_LOG -Eiq
      rm -f $rlRun_LOG
      rlRun -s "fapolicyd-cli -f update" 0-255
      rlAssertNotGrep "missing operation option|invalid|unknown|illegal|bad|unrecognized|undefined|unexpected" $rlRun_LOG -Eiq
      rm -f $rlRun_LOG
    rlPhaseEnd; }

    rlPhaseStartTest "file subcommands AC4" && {
      rlRun -s "fapolicyd-cli -f blabla" 1-255
      rlAssertGrep "not a valid option|missing operation option|invalid|unknown|illegal|bad|unrecognized|undefined|unexpected" $rlRun_LOG -Eiq
      rm -f $rlRun_LOG
    rlPhaseEnd; }

    rlPhaseStartTest "file subcommands AC5 AC6" && {
      tcfChk "file" && {
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertNotGrep "$TESTFILE_FIRST" db_dump -E
        $workaround && Start
        rlRun "fapolicyd-cli -f add $TESTFILE_FIRST"
        Update
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertGrep "$TESTFILE_FIRST" db_dump -E
        $workaround && Start
        rlRun "fapolicyd-cli -f delete $TESTFILE_FIRST"
        Update
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertNotGrep "$TESTFILE_FIRST" db_dump -E
        $workaround && Start; :
      tcfFin; }
      tcfChk "directory" && {
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertNotGrep "$TESTDIR" db_dump -E
        #debugPrompt
        $workaround && Start
        rlRun "fapolicyd-cli -f add $TESTDIR"
        Update
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertGrep "$TESTFILE_SECOND" db_dump -E
        rlAssertGrep "$TESTFILE_THIRD" db_dump -E
        $workaround && Start
        rlRun "fapolicyd-cli -f delete $TESTDIR"
        Update
        $workaround && Stop
        rlRun "fapolicyd-cli -D >db_dump"
        rlAssertNotGrep "$TESTDIR" db_dump -E
        $workaround && Start; :
      tcfFin; }
    rlPhaseEnd; }

    rlPhaseStartTest "ftype - file AC8" && {
      rlRun "cp '$(rpm -qal | grep '\.pyc$' | head -n 1)' files/application_x-bytecode.python_.pyc"
      rlRun "cp '$(rpm -qal | grep '\.so$' | grep -v libc | grep -v pthread | head -n 1)' files/application_x-sharedlib_non-libc.so"
      rlRun "cp /bin/bash files/application_x-executable_bash"
      if rlIsRHELLike '>=9.6' || rlIsCentOS '>8'; then
        libc=$(rpm -ql glibc | grep -E '^(/usr)?/lib(64)?/libc\b.*\.so(\.[0-9]+)?$' | head -n1)
      else
        libc=$(rpm -ql glibc | grep -E '^/lib(64)?/libc\b.*\.so(\.[0-9]+)?$' | head -n1)
      fi
      tcfChk "checking $libc for application/x-sharedlib" && {
        echo -n "file's output:      "; file --mime $libc
        echo -n "fapolicyd's output: "; fapolicyd-cli -t $libc | tee out
        rlAssertGrep "application/x-sharedlib" out -Eq
      tcfFin; }
      while IFS=_ read -r ftype1 ftype2 rest; do
        tcfChk "checking files/${ftype1}_${ftype2}_$rest for ${ftype1}/${ftype2}" && {
          echo -n 'shebang: '
          if [[ "$ftype1" == "text" ]]; then
            head -n1 files/${ftype1}_${ftype2}_$rest
          else
            echo -n '0x'
            head -c20 files/${ftype1}_${ftype2}_$rest | rlHash --stdin
            echo -n ', '
            head -c20 files/${ftype1}_${ftype2}_$rest
            echo
          fi
          echo -n "file's output:      "; file --mime files/${ftype1}_${ftype2}_$rest
          echo -n "fapolicyd's output: "; fapolicyd-cli -t files/${ftype1}_${ftype2}_$rest | tee out
          rlAssertGrep "${ftype1}/${ftype2}" out -Eq
        tcfFin; }
      done < <(ls -1 files | grep -v scripts-gen.sh)
    rlPhaseEnd; }

    rlPhaseStartTest "ftype - drirectory AC9" && {
      rlRun -s "fapolicyd-cli -t /bin" 0-255
      rlAssertGrep "unknown" $rlRun_LOG -Eq
      rm -f $rlRun_LOG
    rlPhaseEnd; }

    rlPhaseStartTest "rules listing AC10" && {
      rlRun -s "fapolicyd-cli -l 2> /dev/null"
      a=$rlRun_LOG
      rule_file="/etc/fapolicyd/fapolicyd.rules"
      [[ -e /etc/fapolicyd/compiled.rules ]] && rule_file="/etc/fapolicyd/compiled.rules"
      rlRun -s "grep -Ev '^(#|\s*\$)' $rule_file | grep -E '^(allow|deny|%)' | sed -r 's/^%/-> \0/' | awk 'BEGIN {i=1} /^(allow|deny)/{print i++ \". \" \$0} /^-> %/{print}'"
      b=$rlRun_LOG
      rlRun "diff -u $a $b"
      rm -f $a $b
    rlPhaseEnd; }
    :
  tcfFin; }

  rlPhaseStartCleanup && {
    CleanupDo
    tcfCheckFinal
  rlPhaseEnd; }
  rlJournalPrintText
rlJournalEnd; }
