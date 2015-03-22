#!/usr/bin/env bash

this_dir=`dirname $0`

RAILS=$this_dir/rails

$RAILS g scaffold manuscript \
    title:string \
    shelfmark:string \
    url:string
