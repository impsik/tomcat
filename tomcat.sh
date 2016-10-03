#!/bin/bash
#Define functions
function packages {
if ! rpm -qa | grep -qw wget; then
echo "Wget not found!"
    yum install wget
fi
if ! rpm -qa | grep -qw curl; then
echo "Curl not found!"
    yum install curl
fi
}
function md5 {
        md5sum=$(md5sum apache-tomcat-$tom.tar.gz | awk '{print $1}')
        echo
        echo "All done, let's compare md5"
        echo
        echo -e "$original\n$md5sum"
        if [ "$original" = "$md5sum" ]
        then
        echo "MD5 are equal"
        else
        echo "MD5 not equal"
        echo ""
fi
}

function javadownload {
echo "Select Java version 7 or 8 and hit [ENTER]"
read javadownload
if [ $javadownload == 7 ]; then
curlit=$(curl -s http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html | grep 'linux-x64.tar.gz' | awk '{print $7}' | sed 's#MB","filepath":"##g#' | sed 's#"};###' | sort -V  | tail -1)
echo "Downloading: $curlit"
wget  --progress=bar --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $curlit
if [ $javadownload == 8 ]; then
curlit=$(curl -s http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html | grep 'linux-x64.tar.gz' | awk '{print $7}' | sed 's#MB","filepath":"##g#' | sed 's#"};###' | sort -V  | tail -1)
echo "Downloading: $curlit"
#wget  --progress=bar --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $curlit
fi
fi
}
function extract {
        echo "To which folder should we install Tomcat Tomcat $tom"
        read directory
                if [ -d "$directory" ]; then
                echo "Directory $directory already exists, skipping"
                mv --backup=numbered $directory /opt/old
                else
                mkdir $directory
                tar xzf apache-tomcat-$tom.tar.gz -C $directory --strip-components=1
                echo "Apache Tomcat extracted to $directory"
                fi
}
function user {
        echo "Under which user tomcat should run? Enter name and press [ENTER]: "
        read user
if /usr/bin/id $user 2>/dev/null; then
        echo "$user group already exists, skipping";
        else
        echo "$user group do not exist, let's make one";
        groupadd $user
        echo "Group $user created"
fi
if /usr/bin/id -g $user; then
        echo "Username $user already exists, skipping"
        chown -R $user:$user $directory
        else
        echo "Username $user do not exist, let's make one";
        useradd -g $user -d $directory $user
if ! rpm -qa | grep -qw httpd; then
usermod -G apache $user
else
echo "No apache installed, skiping to add user to apache group"
fi
        chown -R $user:$user $directory
        echo "Username $user created, necessary rights given to $directory"
fi
}
function initscript {
cp tomcat.orig.service tomcat.service
sed -i "s#--HOME--#$directory#g" tomcat.service
sed -i "s/--USER--/$user/g" tomcat.service
}
function java {
echo "Select Java version 7 or 8 and hit [ENTER]"
read javadownload
if [ $javadownload == 7 ]; then
curlit=$(curl -s http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html | grep 'linux-x64.tar.gz' | awk '{print $7}' | sed 's#MB","filepath":"##g#' | sed 's#"};###' | sort -V  | tail -1)
echo "Downloading: $curlit"
wget  --progress=bar --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $curlit
                if [ -d /opt/java7 ]
                then
                echo "Directory /opt/java7 already exists, skipping"
#               mv --backup=numbered /opt/java7 /opt/old
                java="/opt/java7"
                else
                mkdir /opt/java7
                java="/opt/java7"
                tar xzf jdk-7u*.gz -C /opt/java7 --strip-components=1
                echo "Java7 extracted to: /opt/java7"
fi
fi
if [ $javadownload == 8 ]; then
curlit=$(curl -s http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html | grep 'linux-x64.tar.gz' | awk '{print $7}' | sed 's#MB","filepath":"##g#' | sed 's#"};###' | sort -V  | tail -1)
wget  --progress=bar --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $curlit
                if [ -d /opt/java8 ]
                then
                echo "Directory /opt/java8 already exists, skipping"
                java="/opt/java8"
#                mv --backup=numbered /opt/java8 /opt/old
                else
                mkdir /opt/java8
                java="/opt/java8"
                tar xzf jdk-8u*.gz -C /opt/java8 --strip-components=1
                echo "Java8 extracted to: /opt/java8"
fi
fi
}
function setjava {
echo "Java home set to: $java"
sed -i "s#--JAVAHOME--#$java#" tomcat.service
mv tomcat.service /etc/systemd/system/tomcat-$user.service
systemctl daemon-reload
systemctl start tomcat-$user
}

echo "Choose Apache Tomcat version: 7, 8 or 9 type the number and press [ENTER]:"
read version
if [ $version == 7 ]
 then
packages
        tom=$(wget --quiet -O- http://www.eu.apache.org/dist/tomcat/tomcat-7/ | egrep -o '7.[0-9\.]+' | grep -v ':' | tail -1 )
        echo "Downloading latest: tomcat $tom"
        curl --progress-bar -O http://www.eu.apache.org/dist/tomcat/tomcat-7/v$tom/bin/apache-tomcat-$tom.tar.gz
        original=$(curl -s http://www.eu.apache.org/dist/tomcat/tomcat-7/v$tom/bin/apache-tomcat-$tom.tar.gz.md5 | awk '{print $1}')
        md5sum=$(md5sum apache-tomcat-$tom.tar.gz | awk '{print $1}')
md5
extract
user
initscript
java
setjava
elif [ $version == 8 ]
 then
packages
        tom=$(wget --quiet -O- http://www.eu.apache.org/dist/tomcat/tomcat-8/ | egrep -o '8.[0-9\.]+' |  grep -v ':' | sort -V  | tail -1 )
        echo "Downloading latest: tomcat $tom"
        curl --progress-bar -O http://www.eu.apache.org/dist/tomcat/tomcat-8/v$tom/bin/apache-tomcat-$tom.tar.gz
        original=$(curl -s http://www.eu.apache.org/dist/tomcat/tomcat-8/v$tom/bin/apache-tomcat-$tom.tar.gz.md5 | awk '{print $1}')
        md5sum=$(md5sum apache-tomcat-$tom.tar.gz | awk '{print $1}')
md5
extract
user
initscript
java
setjava
elif [ $version == 9 ]
 then
packages
        tom=$(wget --quiet -O- http://www.eu.apache.org/dist/tomcat/tomcat-9/ | egrep -o '9.[0-9\.]+.[0-9]' | grep -v ':' | sort -V  | tail -1 )
        echo "Downloading latest: tomcat $tom"
        curl --progress-bar -O http://www.eu.apache.org/dist/tomcat/tomcat-9/v$tom/bin/apache-tomcat-$tom.tar.gz
        original=$(curl -s http://www.eu.apache.org/dist/tomcat/tomcat-9/v$tom/bin/apache-tomcat-$tom.tar.gz.md5 | awk '{print $1}')
        md5sum=$(md5sum apache-tomcat-$tom.tar.gz | awk '{print $1}')
md5
extract
user
initscript
java
setjava
else
        echo "Unknown choice"
fi
rm -r $directory/webapps/docs
rm -r $directory/webapps/examples
rm -r $directory/webapps/host-manager
rm -r $directory/webapps/ROOT

echo "####################################################################################"
echo "# Secure Tomcat! More information: https://www.owasp.org/index.php/Securing_tomcat #"
echo "####################################################################################"
