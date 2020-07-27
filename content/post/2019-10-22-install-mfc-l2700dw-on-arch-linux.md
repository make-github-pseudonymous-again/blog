---
title: "Install Brother printer and scanner MFC-L2700DW on Arch Linux"
date: 2019-10-22T17:23:03+02:00
tags:
  - Brother
  - Printer
---

Using `sane`, `brscan4`, and `brother-mfc-l2700dw`.

<!--more-->

Install `sane`

	pacman -S sane

Install `brother-mfc-l2700dw` and `brscan4`

	trizen -S brother-mfc-l2700dw brscan4

Config the scanner functionality, by IP,

	brsaneconfig4 -a name=<CHOSEN NAME> model=MFC-L2700DW ip=<IP ADDRESS>

or by host name

	brsaneconfig4 -a name=<CHOSEN NAME> model=MFC-L2700DW nodename=<HOSTNAME>

In CUPS (localhost:631), configure new printer with IPP (by IP works best with
`ipp://<IP ADDRESS>:631/ipp/print`) and "MFC-L2700DW - IPP Everywhere" CUPS driver.

## Test

Print something

	...

Scan something

	scanimage --format=png > test.png
