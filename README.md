# lede-docker-thin

This is a template for creating a "thin" LEDE docker container.

The idea is to build an LEDE container that's useful for the kind of
complicated routing and firewalling that LEDE can do. I use this to build
containers based on the `mwan3` package, which do routing for other containers.

It starts with the official release of LEDE (from
`lede-17.01.4-x86-64-generic-rootfs.tar.gz`) and removes all the packages that
aren't very useful in a container.

## What's in the image

I removed everything related to being a home firewall/router, including:

* luci
* dnsmasq
* odhcpd
* dropbear
* all kernel modules

The various LEDE system daemons are the only things that end up running in
the container.

```
/ # ps w
  PID USER       VSZ STAT COMMAND
    1 root     15288 S    /sbin/procd
   35 root      6832 S    /sbin/ubusd
  192 root      8964 S    /sbin/logd -S 16
  201 root     19540 S    /sbin/rpcd
  233 root     17396 S    /sbin/netifd
  275 root      9292 S    /bin/sh
  281 root      9288 R    ps w
```

This results in a very small container image.

```
lede-thin                              17.01.4-x86-64      9be52f540c89
2 minutes ago       2.35 MB
```

## Usage

To rebuild the image, run `./build.sh`.

Use the image:

```
docker run --tty --tmpfs /tmp --cap-add NET_ADMIN lede-thin:17.01.4-x86-64
```

Explanation of the parameters used:

* `--tty`: Use this, otherwise the startup messages go to `/dev/console` on
  your host.
* `--tmpfs /tmp`: This is LEDE's normal setup, and it expects files in
  `/tmp` to be wiped between reboots.
* `--cap-add NET_ADMIN`: This allows the container to change iptables and
  routes. You probably want this if you're using this image. Don't use
  `--privileged`.

Other parameters to consider:

* `--read-only`: This mostly works, but `logread` fails. I haven't figured out
  why.
* `--device /dev/kmsg`: The init process writes debug messages to `kmsg`, so
  this can be helpful when debugging init problems.
