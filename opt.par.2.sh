#!/bin/sh
# Getops while cikluson kivuli mukodese.
# Hogyan reagal?
# $OPTIND -- a kovetkezo 'option'-ra mutat
# $OPTARG -- az 'option' argumense
# Amikor csoportosítva adjuk at az 'option'-t, akkor az $OPTIND erteke nem novekszik.
# Ez azrt van így, mert a parameterlistan ugyanaz parameter alatt van a ket 'option'.

 getopts a:bcd opt
 echo '$OPTIND: ' $OPTIND '--' '$OPTARG: '$OPTARG
 echo '$opt: '$opt '--' '$OPTARG: ' $OPTARG
 echo ''
 
 getopts a:bcd opt
 echo '$OPTIND: ' $OPTIND '--' '$OPTARG: '$OPTARG
 echo '$opt: '$opt '--' '$OPTARG: ' $OPTARG
 echo ''
 
 getopts a:bcd opt
 echo '$OPTIND: ' $OPTIND '--' '$OPTARG: '$OPTARG
 echo '$opt: '$opt '--' '$OPTARG: ' $OPTARG
 echo ''
 
 getopts a:bcd opt
 echo '$OPTIND: ' $OPTIND '--' '$OPTARG: '$OPTARG
 echo '$opt: '$opt '--' '$OPTARG: ' $OPTARG
 echo ''

################################################################################
#   Igy nem lehet kiirni az osszes pozicionalis parametert, amit az eredeti
# szkript kapott. Helyette mintha a for ciklus parametereit kapnank meg.
# Igazabol per pillanat nem ertem, de legyen igy, s igy is van eme jovahagyas
# nelkul is. Mindenesetre lentebb van egy kiiras, mely listazza az ossze
# pozicionalis parametert azt ahogy kell, az eredeti szkriptbol.
#
# for i in $(seq 0 $#)
#   do
#     echo ${i} -- ${!i}
#   done

################################################################################
#
#   Ahogy most atneztem, a fenti allitas nem igaz. A lenti szkript bizinyitja
# az elso feltetelezesemet, mely szerint a pozicionalis parameterek a szkriptbol
# lesznek eloveve.
# for i in $(seq 0 5)
#   do
#     echo $i - $0, $1, $2, $3, $4, $5
#   done

for i in $(seq 0 $#)
  do
    echo ${i}: ${!i}
#    echo ${i}: ${0}
  done

echo \${0} -- ${0}
echo \${1} -- ${1}
echo \${2} -- ${2}
echo \${3} -- ${3}
echo \${4} -- ${4}
echo \${5} -- ${5}
