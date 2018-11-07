# Linux Adaptive Blacklist [labl]

### Description

A bash shell script wrapper for incorporating a wide variety of blacklist and whitelist sources, custom or otherwise, into a
high performance Linux ipset+iptables solution that can scale to very large list sizes.

#### Objectives

* Minimal dependencies
* IPv4 and IPv6 support, automatic detection, and validation of address[/bits] inputs

### Usage

* Using `labl` requires that it be run as root, or it will abort with a message.

        aborting ... must be root

* Executing `labl` as root, with no arguments, will produce a short usage output.

    * `labl`

            # labl
            usage: labl <add|check|remove> <ip|ip/bits> [blacklist|whitelist] # optional, blacklist is default
            -or-
            usage: labl <auto|restart|start|status|stop>

* A more convenient, memorable way of executing `labl` is to use the `blacklist` or `whitelist` links.

    * `blacklist`

            # blacklist
            usage: blacklist <add|check|remove> <ip|ip/bits>
            -or-
            usage: blacklist <auto|restart|start|status|stop>

    * `whitelist`

            # whitelist
            usage: whitelist <add|check|remove> <ip|ip/bits>
            -or-
            usage: whitelist <auto|restart|start|status|stop>


* Add a new IP to the blacklist.

        # blacklist add 1.2.3.4
        2018-11-02 13:43:02 EDT : [    OK     ] : [+++] 1.2.3.4 added to labl_inet blacklist

        # blacklist add 1.2.3.4/24
        2018-11-02 13:44:10 EDT : [    OK     ] : [+++] 1.2.3.4/24 added to labl_inet blacklist

* Check if an IP is being blacklisted.

        # blacklist check 1.2.3.5
        2018-11-02 13:44:27 EDT : [   CHECK   ] : 1.2.3.5 is blacklisted

* Remove an IP address from the blacklist.

        # blacklist remove 1.2.3.4/24
        2018-11-02 13:45:02 EDT : [  REMOVE   ] : 1.2.3.4/24 removed from labl_inet blacklist
        # blacklist remove 1.2.3.4/24
        2018-11-02 13:45:06 EDT : [  REMOVE   ] : 1.2.3.4/24 is NOT blacklisted

* Show current status.

    * `labl status`

            # labl status

            labl is NOT running, nothing is being blacklisted


            # labl status # running on a machine that only supports IPv4
            ----------------------------------------------------------------

            Name: labl_inet
            Type: hash:net
            Revision: 3
            Header: family inet hashsize 2048 maxelem 131072
            Size in memory: 33392
            References: 1
            Members:
            167.144.71.224
            244.28.63.20
            58.28.172.141
            191.183.94.39
            127.0.0.0/8 nomatch
            192.168.122.0/24 nomatch
            172.22.100.0/25 nomatch

            [+] iptables --match-set labl_inet loaded

            [+]
            [+] Blacklists (inet)
            [+]

            /home/jtingiris/src/labl/etc/labl.d/blacklist.random

            82.34.41.43
            107.167.247.116
            165.176.80.255
            193.144.73.28
            216.234.72.226


            [+]
            [+] Whitelists (inet)
            [+]

            /home/jtingiris/src/labl/etc/labl.d/whitelist.interfaces

            127.0.0.1/8
            172.22.100.54/25
            192.168.122.1/24


            [+]
            [+] Summary (inet)
            [+]

            4 blacklisted & 3 whitelisted inet addresses and/or ranges

            ----------------------------------------------------------------

            4 blacklisted and 3 whitelisted v4 IP addresses

            labl is running, 7 v4 addresses loaded

* Start labl, automatically or manually.  Typically this is done automatically via cron, i.e.

    * `/etc/crontab`

            # linux adaptive blacklist (labl)
            */5 * * * * root [ -x /opt/labl/sbin/labl ] && /opt/labl/sbin/labl auto &>> /var/log/labl.log

    * `labl auto` (The `auto` flag will capture the current, running state and only apply the differences.  It will also `start` labl if it's not currently running.  This is useful to speed up consecutive/automated executions of very large, ever changing dynamic lists.)

            # labl auto # manaully; labl *not* currently started
            2018-11-02 13:25:31 EDT : [  NOTICE   ] : [-] iptables --match-set labl_inet NOT loaded
            2018-11-02 13:25:31 EDT : [  NOTICE   ] : ipset labl_inet NOT loaded
            2018-11-02 13:25:31 EDT : [    OK     ] : labl stop successful
            2018-11-02 13:25:31 EDT : [    OK     ] : ipset labl_inet created
            2018-11-02 13:25:31 EDT : [    OK     ] : iptables --match-set labl_inet started
            2018-11-02 13:25:31 EDT : [    OK     ] : 127.0.0.1/8 added to labl_inet whitelist
            2018-11-02 13:25:31 EDT : [    OK     ] : 172.22.100.54/25 added to labl_inet whitelist
            2018-11-02 13:25:31 EDT : [    OK     ] : 192.168.122.1/24 added to labl_inet whitelist
            2018-11-02 13:25:31 EDT : [    OK     ] : labl start successful

            # labl auto # manually; labl is already running, a dynamic labl.d/blacklist.* produced 'new' addresses to add
            2018-11-02 13:26:42 EDT : [    OK     ] : [+++] 244.28.63.20 added to labl_inet blacklist
            2018-11-02 13:26:42 EDT : [    OK     ] : [+++] 191.183.94.39 added to labl_inet blacklist
            2018-11-02 13:26:42 EDT : [    OK     ] : [+++] 167.144.71.224 added to labl_inet blacklist
            2018-11-02 13:26:42 EDT : [    OK     ] : [+++] 58.28.172.141 added to labl_inet blacklist


    * `labl start` (The `start` flag will always process everything in the `etc/labl.d` directories.  Depending on the list sizes, this may take some time.)

            # labl start # manually
            2018-11-02 13:31:58 EDT : [    OK     ] : ipset labl_inet created
            2018-11-02 13:31:58 EDT : [    OK     ] : iptables --match-set labl_inet started
            2018-11-02 13:31:58 EDT : [    OK     ] : 127.0.0.1/8 added to labl_inet whitelist
            2018-11-02 13:31:58 EDT : [    OK     ] : 172.22.100.54/25 added to labl_inet whitelist
            2018-11-02 13:31:58 EDT : [    OK     ] : 177.177.177.177 added to labl_inet whitelist
            2018-11-02 13:31:58 EDT : [    OK     ] : 192.168.122.1/24 added to labl_inet whitelist
            2018-11-02 13:31:58 EDT : [    OK     ] : [+++] 1.30.210.198 added to labl_inet blacklist
            2018-11-02 13:31:58 EDT : [    OK     ] : [+++] 27.21.208.184 added to labl_inet blacklist
            2018-11-02 13:31:58 EDT : [    OK     ] : [+++] 27.173.231.124 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 64.242.124.41 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 122.57.95.204 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 137.240.245.235 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 140.137.116.63 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 145.39.14.208 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 166.199.204.128 added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [  NOTICE   ] : 177.177.177.177 is whitelisted
            2018-11-02 13:31:59 EDT : [    OK     ] : [+++] 177.177.177.177 NOT added to labl_inet blacklist
            2018-11-02 13:31:59 EDT : [    OK     ] : labl start successful

* `labl stop`

        # labl stop
        2018-11-02 10:52:17 EDT : [    OK     ] : iptables --match-set labl_inet stopped
        2018-11-02 10:52:17 EDT : [    OK     ] : destoyed ipset labl_inet
        2018-11-02 10:52:17 EDT : [    OK     ] : labl stop successful


* `labl restart` (This will execute `labl stop` then `labl start`.)

        # labl restart
        2018-11-02 13:42:01 EDT : [    OK     ] : iptables --match-set labl_inet stopped
        2018-11-02 13:42:01 EDT : [    OK     ] : destoyed ipset labl_inet
        2018-11-02 13:42:01 EDT : [    OK     ] : labl stop successful
        2018-11-02 13:42:01 EDT : [    OK     ] : ipset labl_inet created
        2018-11-02 13:42:01 EDT : [    OK     ] : iptables --match-set labl_inet started
        2018-11-02 13:42:01 EDT : [    OK     ] : 127.0.0.1/8 added to labl_inet whitelist
        2018-11-02 13:42:01 EDT : [    OK     ] : 172.22.100.54/25 added to labl_inet whitelist
        2018-11-02 13:42:01 EDT : [    OK     ] : 177.177.177.177 added to labl_inet whitelist
        2018-11-02 13:42:01 EDT : [    OK     ] : 192.168.122.1/24 added to labl_inet whitelist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 40.68.236.212 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 103.231.30.112 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 110.182.225.178 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 148.120.81.225 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [  NOTICE   ] : 177.177.177.177 is whitelisted
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 177.177.177.177 NOT added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 188.167.170.166 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 201.186.57.202 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 202.226.205.104 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 206.239.43.250 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : [+++] 215.12.55.61 added to labl_inet blacklist
        2018-11-02 13:42:01 EDT : [    OK     ] : labl start successful

### Installation

* Getting the software

        # clone master
        git clone https://github.com/josephtingiris/labl labl
        # if you're not comfortable running from master, then checkout a stable tag, i.e.
        cd labl
        git tag -l
        git checkout tags/v0.0.2

* [OPTIONAL] Add `.../labl/sbin` to your path

* When `labl` is run, it will immediately check for the following dependencies.  If one is not found then it will abort.

    * awk
    * basename
    * cut
    * date
    * dirname
    * find
    * ip
    * ipset
    * iptables
    * ip6tables # only required if IPv6 is enabled
    * printf
    * readlink
    * subnetcalc
    * sed
    * sort

* Dynamic lists are put in `etc/labl.d`
    * `etc/labl.d` is where `labl` searches for dyanmic lists.
    * `labl` will first search `<installed path>/etc/labl.d` and then `/etc/labl.d` for lists.
    * Some dynamic lists are included.
        * Included lists are [here](https://github.com/josephtingiris/labl/tree/master/etc/labl.d) and in `<installed path>/etc/labl.d`
        * Example lists are [here](https://github.com/josephtingiris/labl/tree/master/etc/labl.d.example) and in `<installed path>/etc/labl.d.example`
    * If you want to make custom lists then they should be put in the directory `/etc/labl.d`
    * The `labl.d` lists must have `blacklist` or `whitelist` in their filename and be either 
        1. A text file containing IP addresses to blacklist or whitelist, or
        2. A shebang (#!) script (in any language) that produces output in the form of a single IP address per line.  The latter is useful for creating dynamic lists.


### License

Copyright (C) 2018, Joseph Tingiris [joseph.tingiris@gmail.com](mailto:joseph.tingiris@gmail.com)

```text
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
```

### Acknowledgements

* [The GNU Operating System.](https://www.gnu.org/software/bash/) For awk, basename, bash, cut, date, dirname, readlink, & sed.
* [The netfilter.org project.](https://netfilter.org/) For ipset, iptables, and ip6tables.
* [The University of Duisburg-Essen / Institute for Experimental Mathematics / Computer Networking Technology Group and Thomas Dreibholz.](https://www.uni-due.de/~be0001/subnetcalc/) For subnetcalc.
