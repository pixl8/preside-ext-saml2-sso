#!/bin/bash

if [[ $TRAVIS_TAG == v* ]] ; then
	cd `dirname $0`;
	CWD="`pwd`";

	box forgebox login username="$FORGEBOXUSER" password="$FORGEBOXPASS";
	box publish directory="$CWD";
fi