glass-libs
==========

This contains the source file modules for running the second iteration of the Glass GUI framework, within Rebol2.  Completely replaces VID, requires Rebol/View 2.7.8

This repository only stores the slim package source code to start and run Glass.

For documentation and examples, get the main Glass repository.


Why separate the source repo from the rest?
----------

By having a repo with only the source code, you can clone the repo within your main slim library setup directly.

Simply add a glass subdirectory in the same place where you have your slim.r file and slim will be able to use the glass libs directly without any additional setup.

Furthermore, the next iteration of the Glass GUI engine will be so different than the current one, that it will be a separate repository.
