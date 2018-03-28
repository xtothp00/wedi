#!/bin/sh

check_rc()
{
  if test -a $WEDI_RC
    then
      return 0
  else
    touch $WEDI_RC
  fi
}


