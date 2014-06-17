DupFinder
------------
DupFinder is a Bugzilla extension to find duplicate bug reports. The current implementation is based on the work by Runeson et al.[1].

[1] P. Runeson, M. Alexandersson, and O. Nyholm. Detection of duplicate defect reports using natural language processing. In ICSE, pages 499-510, 2007.


Installation
------------

Follow these steps to install DupFinder:

1.  Go to your Bugzilla installation folder.

1.  Put extension files in:

        extensions/DupFinder

2.  Run checksetup.pl.

3.  Restart your webserver (if needed, e.g., when using mod_perl).
