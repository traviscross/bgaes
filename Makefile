# -*- mode:makefile-gmake -*-
all:
%:
	if test -n "$$(which redo)"; then redo $@; else sh do.sh $@; fi
