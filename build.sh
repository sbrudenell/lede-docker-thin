#!/bin/sh

# Because we start with a fat layer and strip down to a thin one, more than
# half of the space in the image is wasted. We "compress" the stripped image by
# creating an intermediary container, exporting the filesystem and re-importing
# to create the final image.

RELEASE=17.01.4

docker import http://downloads.lede-project.org/releases/${RELEASE}/targets/x86/64/lede-${RELEASE}-x86-64-generic-rootfs.tar.gz lede-x86-64-initial || exit 1
docker build -t lede-thin-temp . || exit 1
docker rmi lede-x86-64-initial || exit 1
docker create --name lede-thin-temp lede-thin-temp /bin/sh || exit 1
docker export lede-thin-temp | gzip > lede-thin.tar.gz || exit 1
docker rm lede-thin-temp || exit 1
docker rmi lede-thin-temp || exit 1
docker import -c 'CMD ["/sbin/init"]' lede-thin.tar.gz lede-thin:${RELEASE}-x86-64 || exit 1
rm lede-thin.tar.gz || exit 1
