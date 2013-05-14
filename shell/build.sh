#!/bin/bash
basedir="`pwd`";
arch=`uname -p`
pushd /usr/src/redhat/SPECS;
#rpm -e soworker --nodeps;rm -f /etc/*dispatchd.ini.* /etc/*thinkd.ini.*
rpm -e ispider --nodeps ;rm -f /etc/*spider.ini* /etc/*extractor.ini* /etc/*monitord.ini*
rpm -e ithunder --nodeps ;rm -f /etc/*dispatchd.ini* /etc/*thinkd.ini*
rpm -e hidbase libdbase --nodeps ;rm -f /etc/hi*.ini
rpm -e qmtask libmtask --nodeps ;rm -f /etc/qtaskd.ini
#rpm -e sodo libsobase --nodeps; rm -f /etc/so*.ini*
rpm -e hibase libibase --nodeps; rm -f /etc/hi*.ini*
rpm -e libscws --nodeps
rpm -e libsbase libevbase --nodeps;
rm -rf /usr/src/redhat/BUILD/* /usr/src/redhat/SRPMS/* /usr/src/redhat/RPMS/x86_64/* ${basedir}/debuginfo/* ${basedir}/4DB/*  ${basedir}/gid32/* ${basedir}/src/* ${basedir}/rpms/* ${basedir}/srpms/* /tmp/*;
buildrpm()
{
    name=$1;ver=$2;rel=$3;isinstall=$4;isdebug=$5;
    perl -i -p -e "s/^Version: .*/Version: ${ver}/" ${name}.spec \
    && perl -i -p -e "s/^Release: .*%/Release: ${rel}%/" ${name}.spec \
    && rpmbuild -ba ${name}.spec 
    [ "$?" != 0 ] && exit
    if [ "$isinstall" == "yes" ];
    then
        RPMDIR="/usr/src/redhat/RPMS";
        dev=""
        [ "$name" == "qmtask" ] && dev="${RPMDIR}/${arch}/libmtask-${ver}-${rel}.${arch}.rpm"
        [ "$name" == "hidbase" ] && dev="${RPMDIR}/${arch}/libdbase-${ver}-${rel}.${arch}.rpm"
        [ "$dev" != "" -a -e "$dev" ] && rpm -Uvh "$dev" --force
        rpm -Uvh $RPMDIR/${arch}/${name}-${ver}-${rel}.${arch}.rpm --force 
        [ "$?" != 0 ] && exit
    fi
    if [ "$isdebug" == "1" ]; 
    then
        cp ${name}.spec  ${name}_4DB.spec \
        &&  perl -i -p -e "s/^%configure/%configure CFLAGS=\"-O0 -g\" CPPFLAGS=\"-O0 -g\" CXXFLAGS=\"-O0 -g\"/" ${name}_4DB.spec \
        &&  perl -i -p -e "s/^Release: .*%/Release: 4DB${rel}%/" ${name}_4DB.spec \
        && rpmbuild -ba ${name}_4DB.spec && rm -f ${name}_4DB.spec
        [ "$?" != 0 ] && exit
    fi
}
#libevbase
buildrpm libevbase 1.0.2 1 yes 0 
#libsbase
buildrpm libsbase 1.0.5 8 yes 0
#libscws
buildrpm libscws 1.1.8 1  yes 0
#libmtask & qmtask
buildrpm qmtask 0.0.5 51 yes 0
#hidbase 
buildrpm hidbase 0.0.5 2 yes 0
#libibase
buildrpm libibase 0.5.21 9 yes 0
#libsobase
#buildrpm libsobase 1.5.21 4 yes 0
#libchardet
buildrpm libchardet 0.0.4 2 yes 0
#hibase
buildrpm hibase 0.4.21 10 yes  0
#sodo
#buildrpm sodo 1.4.21 3 no 0
#ispider
buildrpm ispider 0.0.2 8 yes 0
#ithunder
buildrpm ithunder 0.0.4 11 yes 0
#sowork
#buildrpm soworker 1.0.3 73 no 0
popd
#perl -i -p -e "s@/tmp@/data/tmp@g" /etc/hidocd.ini; 
#service hidocd start
#perl -i -p -e "s@/tmp@/index/tmp@g" /etc/sodocd.ini;
#service sodocd start
rm -rf /tmp/*
#tarball
mkdir -p ${basedir}/{debuginfo,4DB,srpms,rpms,src}
cp -f /usr/src/redhat/SOURCES/*.tar.gz ${basedir}/src/ 
mv -f /usr/src/redhat/SRPMS/* ${basedir}/srpms/ 
#mv -f /usr/src/redhat/RPMS/${arch}/*4DB* ${basedir}/4DB/rpms
mv -f /usr/src/redhat/RPMS/${arch}/*debuginfo* ${basedir}/debuginfo/
mv -f /usr/src/redhat/RPMS/${arch}/* ${basedir}/rpms/
pushd ${basedir}/;
./tarball.sh
popd;
