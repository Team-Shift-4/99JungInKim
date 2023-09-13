 1022  mkdir workspace
 1023  ls
 1024  cd workspace/
 1025  ls
 1026  git clone -b v2.0_develop_renewal https://lab.idatabank.com/gitlab/ARK/CDC/arkcdc2.git
 1027  ls
 1028  rm -rf arkcdc2/
 1029  ls
 1030  git clone -b v2.0_develop https://lab.idatabank.com/gitlab/ARK/CDC/arkcdc2.git
 1031  ls
 1032  cd arkcdc2/
 1033  ls
 1034  chmod 777 configure.sh
 1035  pwd
 1036  export SOURCE_HOME=/home/oracle/workspace/arkcdc2
 1037  ls
 1038  sh ./configure.sh
 1039  sh ./configure.sh linux8 oracle
 1040  ls
 1041  cd src
 1042  ls
 1043  make rebuildall
 1044  cd $ARKCDC_HOME/lib