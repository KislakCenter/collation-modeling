#!/usr/bin/env bash

this_dir=`dirname $0`

RAILS=$this_dir/rails

$RAILS g migration add_manuscript_id_to_quires manuscript:references

# $RAILS g model quire number:string position:integer manuscript:references

# $RAILS g scaffold manuscript \
#     title:string \
#     shelfmark:string \
#     url:string
