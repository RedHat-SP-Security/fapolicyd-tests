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
    tcfRun "rlCheckRecommended; rlCheckRequired" || rlDie "cannot continue"
    rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
    CleanupRegister "rlRun 'rm -r $TmpDir' 0 'Removing tmp directory'"
    CleanupRegister 'rlRun "popd"'
    rlRun "pushd $TmpDir"
    CleanupRegister 'rlRun "testUserCleanup"'
    rlRun "testUserSetup"
    CleanupRegister 'rlRun "fapCleanup"'
    rlRun "fapSetup"
    cat > repro.stp <<'EOF'
probe begin {
  printf("Hello World !!!\n")
}

function tttouch:long() %{
  struct file *filp = filp_open("/usr/bin/mkdir", O_RDONLY, 0777);
  if (IS_ERR(filp)) {
    filp = NULL;
  }

  if (filp) {
    filp_close(filp, NULL);
    THIS->__retvalue = 1;
  } else {
    THIS->__retvalue = 0;
  }
%}

probe syscall.execve {
  if (execname() == "ls" || execname() == "bash" ) {
    printf("%s %s (%ld) | %s \n", name, execname(), pid(), filename )
  }
}

probe syscall.openat {
  if (execname() == "ls" || execname() == "bash" ) {
    printf("%s %s (%ld) | %s \n", name, execname(), pid(), filename )
  }
}

probe kernel.function("open_exec") {
//      printf("just open %s\n", execname())
  if (execname() == "ls" || execname() == "bash" ) {
    printf("%s %s (%ld) | %s \n", probefunc(), execname(), pid(), $name$)

    printf("adding additional open\n")
    if (tttouch()) {
      printf("success\n")
    } else {
      printf("fail\n")
    }
  }
}

probe end {
  printf("End of the world!!!\n")
}
EOF
    CleanupRegister 'rlRun "fapStop"'
    rlRun "fapStart"
    rlRun "rlServiceStatus fapolicyd"
    rlRun 'bash -c "stap -g repro.stp" > >(tee stap.out) 2>&1 &'
    CleanupRegister "kill $!; rlWaitForCmd -t 300 'grep -q \"End of the world!!!\" stap.out'"
    rlWaitForCmd -t 300 'grep -q "Hello World !!!" stap.out'
  rlPhaseEnd; }

  tcfTry "Tests" --no-assert && {
    rlPhaseStartTest && {
      rlRun "su -c ls - $testUser"
    rlPhaseEnd; }

  tcfFin; }

  rlPhaseStartCleanup && {
    CleanupDo
    tcfCheckFinal
  rlPhaseEnd; }
  rlJournalPrintText
rlJournalEnd; }
