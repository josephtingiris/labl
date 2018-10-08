# Linux Adaptive Blacklist [labl]

### Purpose

A bash shell script wrapper for incorporating a wide variety of blacklist and whitelist sources, custom or otherwise, into a
high performance Linux ipset+iptables blacklist/whitelist solution that can be trusted.

Objectives

* Generic shell wrapper for incorporating multiple, custom IP blacklists and whitelist into a single framework

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
