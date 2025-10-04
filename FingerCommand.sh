#/bin/bash

## /shellscript/fingercommand username

FINFO= `getent passwd $1|cut -f 5 -d :`
###  variables and values  ###############

fn=`echo $FINFO | cut -f 1 -d ,`
de=`echo $FINFO | cut -f 2 -d ,`
oc=`echo $FINFO | cut -f 3 -d ,`
pc=`echo $FINFO | cut -f 4 -d ,`

echo "Login Name: $1"
echo "============================================================"
echo "Full Name: $fn"
echo "Designatio: $de"
echo "Office contact: $oc"
echo "personal contact: $pc"
echo "============================================================="
