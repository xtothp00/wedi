#!/bin/bash
#   Interpretation of a wrapper script for text editor called wedi
# for the purpose of the course IOS @ the FIT, BUT -- spring semester 2017.

# readonly vars as constants
POSIXLY_COORRECT=yes
readonly EDI_0=1
readonly EDI_1=2
readonly EDI_2=4
readonly EDI_3=8
readonly EDI_4=16
readonly EDI_5=32
readonly EDI_6=64
readonly EDI_7=128
#readonly EDITORS="ed ex vi vim emacs nano"
readonly EDITORS=(\${VISUAL:-foo} \${EDITOR:-bar} nano emacs vim vi ex ed )
STAT_REG=0;

#The init function
init()
{
  # Check of the existence of the $WEDI_RC
#  echo ${WEDI_RC?"\$WEDI_RC: paramter unset"}
  if [ -z "${WEDI_RC:+"test"}" -a "${WEDI_RC+"test"}" = "test" ]; then
    echo "\$WEDI_RC: paramter set but null" 1>&2
    return 4
  elif [ -z "${WEDI_RC:+"test"}" -a -z "${WEDI_RC+"test"}" ]; then
    echo "\$WEDI_RC: paramter unset" 1>&2
    return 3
  fi

  # Let's see the editors on the system. Shall we?
##  if [ -n "${VISUAL}" -a check_editor_presence "${VISUAL}" ]; then
#  if [ -n "${VISUAL}" ]; then if check_editor_presence "${VISUAL}"; then
#    let "STAT_REG |= ${VIS_SET}"; fi
#  elif [ -n "${EDITOR}" ]; then if check_editor_presence "${EDITOR}"; then
#    let "STAT_REG |= ${EDI_SET}"; fi
#  else
#    scan_editors;
#  fi
  scan_editors;

  return 0
}

check_editor_presence()
{
  if command -v ${1} 1>/dev/null 2>&2; then
    return 0
  else
    return 1
  fi

  exit 1
}

scan_editors()
{
  echo "Scanning editors..."

#  for i in $(echo ${EDITORS} | awk '{ for(i=0; i<NF; i++) print i }')
  for i in {0..7}
  do
#    echo " *** Editor #${i} --" $(eval echo ${EDITORS[${i}]})
#    check_editor_presence $(eval echo ${EDITORS[${i}]})
#    echo $?
#    command -v $(eval echo ${EDITORS[${i}]})
#    echo $?
    if check_editor_presence $(eval echo ${EDITORS[${i}]}); then
      let "STAT_REG |= $(eval echo \${EDI_${i}})"
    fi
  done
  printf "\nSTATUS REGISTER: %x\n\n" $STAT_REG
  return 0
}

open_file()
{
  echo "Openning file ${1}..."

  for i in {0..7}
  do
    if let "STAT_REG ^ (1 << ${i})"; then
      eval echo ${EDITORS[${i}]}
    fi
  done
}

show_help()
{
  echo "NAME"
  echo "       wedi - Text editor wrapper script hopefully POSIX compliant."
  echo ""
  echo "SYNOPSIS"
  echo "       wedi FILE | DIRECTORY"
  echo "       wedi -m | -l [DIRECTORY]"
  echo "       wedi -b | -a DATE [DIRECTORY]"
  echo ""
  echo "DESCRIPTION"
  echo "       Launch the default text editor set by the environment variable \$VISUAL."
  echo "       If it is not being set, variable \$EDITOR is being used. For the case"
  echo "       none of the environment variables were found set, the system is being"
  echo "       searched for the available editors in the following order:"
  echo ""
  echo "        * ed"
  echo "        * ex"
  echo "        * vi"
  echo "        * vim"
  echo "        * emacs"
  echo "        * nano"
  echo ""
  echo "       The editors are sorted in an "
}

#  original thoughts of the simplicity of getting the abolute path...
# get_path()
# {
#   echo "$(cd "$(dirname "${1}")"; pwd)/$(basename "${1}")"
# }

# function to get the absolute path
get_path()
{
  if printf "%s" ${1} | grep -e '^-' -q; then
    return 1
#    continue
  elif [ ${1:-'.'} = '.' ]; then
    tmp_path="$(pwd)"
  elif [ ${1} = '..' ]; then
    tmp_path="$(echo "$(cd ..; pwd)")"
  else
    tmp_path=$(echo "$(cd "$(dirname "${1}")"; pwd)/$(basename "${1}")")
  fi

  if [ -d "${tmp_path}" ]; then
    echo "${tmp_path}/"
    return 3
  else echo "${tmp_path}"
    return 4
  fi
}

evaluate_date()
{
  echo "${1}" | grep -E '^[0-9]{4}\-((((0[13578])|(1[02]))\-(([0-2][0-9])|(3[01])))|(((0[469])|(11))\-(([0-2][0-9])|(30)))|(02\-[0-2][0-9]))$' -q
  return
}


echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@                                        @"
echo "@   Leszek e vajon itten? (^.^)          @"
echo "@                                        @"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

init;
echo "------------------------------------------------------"
echo "| Az inicializalo fugveny visszateresi erteke: " ${?}
echo "------------------------------------------------------"
init_exit_code=${?}
if [ ${init_exit_code} -eq 0 ]; then
  echo "sikerult inicializalni"
else
  echo "inicializali hibaba futottunk."
#  show_help
  echo ${init_exit_code}
  exit 123
fi

echo "*********************************"
echo "*                               *"
echo "* Remelem eljutok ide...         "
echo "*  init exit code: ${1}          "
echo "*                               *"
echo "*********************************"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "<                               <"
echo ">  -kapcsolok parameterek       >"
echo "< feldolgozasa...               <"
echo ">                               >"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

if printf "%s" ${1} | grep -e "^-[0-9A-za-z]*$" -v -q; then
  current_path=$(get_path ${1})
  current_path_retval=${?}

  if [ ${current_path_retval} -eq 3 ]; then
    echo "${1} is a directory with absolute path: ${current_path}"
  elif [ ${current_path_retval} -eq 4 ]; then
    echo "${1} is or will be a file at the following path: ${current_path}"
  fi

elif printf "%s" ${1} | grep -e "^-[h]$" -q; then
  show_help
  exit 0

elif printf "%s" ${1} | grep -e "^-[mlab]$" -q; then
  case ${1} in
    -m|-l)
      if printf "%s" ${1} | grep -e "^-[0-9A-za-z]*$" -v -q; then
        current_path=$(get_path ${2})
        current_path_retval=${?}

      if [ ${current_path_retval} -eq 3 ]; then
        echo "${2} is a directory with absolute path: ${current_path}"
      elif [ ${current_path_retval} -eq 4 ]; then
        echo "${2} is or will be a file at the following path: ${current_path}"
      fi
      ;;

    -a|-b)
      if evaluate_date "${2}"; then
      else
        echo "Wrong date format -- "${2}" --" 1>2
        echo "Correct format of date: YYYY-MM-DD." 1>2
        echo "For details on usege use the help: wedi -h" 1>2

  esac

else
  echo "Option ${1} not supported. Use wedi -h for addional help on usage." 1>2
  exit 1
fi

while [ ${1} ]
do
  case ${1} in
    -h)
      show_help
      exit 0
      ;;
    -m)
      if [ -d $(realpath ${2} 2>/dev/null) ]; then
        echo "most used file in directory $(realpath ${2})"
        shift 2
      else
        echo "most used file"
        shift 1
      fi
      exit 0
      ;;
    -l)
      if [ -d $(realpath ${2}) ]; then
        echo "list of all files in directory $(realpath ${2})"
        shift 2
      else
        echo "list of all files"
        shift 1
      fi
      ;;
    -b)
      if echo ${2} grep -E '^[0-9]{4}\-((((0[13578])|(1[02]))\-(([0-2][0-9])|(3[01])))|(((0[469])|(11))\-(([0-2][0-9])|(30)))|(02\-[0-2][0-9]))$'; then
        if [ -d $(realpath ${3}) ]; then
          echo "list of all files before ${2} in folder ${3}"
          shift 2
        else
          echo "list of all files before ${2}"
          shift 1
        fi
        else
          echo "${2}: wrong date format.\nCorrect usage: YYYY-MM-DD." 1>&2
          exit 6
      fi
      ;;
    -a)
      if echo ${2} grep -E '^[0-9]{4}\-((((0[13578])|(1[02]))\-(([0-2][0-9])|(3[01])))|(((0[469])|(11))\-(([0-2][0-9])|(30)))|(02\-[0-2][0-9]))$'; then
        if [ -d $(realpath ${3}) ]; then
          echo "list of all files after ${2} in folder ${3}"
          shift 2
        else
          echo "list of all files after ${2}"
          shift 1
        fi
        else
          echo "${2}: wrong date format.\nCorrect usage: YYYY-MM-DD." 1>&2
          exit 6
      fi
      ;;
    *)
      if [ -d ${1} ]; then
        echo "directory"
      elif [ -e ${1} -a -r ${1} -a -w ${1}]; then
        echo "file exists with rw? rights set"
      else
        echo "file does not exists... creation needed"
      fi
      ;;
  esac
done

exit
