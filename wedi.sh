#!/bin/bash
#   Interpretation of a wrapper script for text editor called wedi
# for the purpose of the course IOS @ the FIT, BUT -- spring semester 2017.

# readonly vars as constants.
POSIXLY_COORRECT=yes
readonly EDI_0=1
readonly EDI_1=2
readonly EDI_2=4
readonly EDI_3=8
readonly EDI_4=16
readonly EDI_5=32
readonly EDI_6=64
readonly EDI_7=128
readonly EDITORS=(\${VISUAL:-foo} \${EDITOR:-bar} nano emacs vim vi ex ed )

# Status Register of the editors on the system.
STAT_REG=0;

# An EXTRA help for the usage.
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

#The init function
init()
{
  # Check of the existence of the $WEDI_RC
  if [ -z "${WEDI_RC:+"test"}" -a -z "${WEDI_RC+"test"}" ]; then
    echo "\$WEDI_RC: paramter unset" 1>&2
    return 3
  elif [ -z "${WEDI_RC:+"test"}" -a "${WEDI_RC+"test"}" = "test" ]; then
    echo "\$WEDI_RC: paramter set but null" 1>&2
    return 4
  fi

  rc_path="$(get_path ${WEDI_RC})"
  rc_path_retval=${?}
  if [ ${rc_path_retval} -eq 3 ]; then
    echo "${rc_path} stored in the \$WEDI_RC (${WEDI_RC}) seems to be a directory" 1>&2
    echo "This wariable must contain the path of the wedi's RC, A.K.A. runcom, A.K.A. run configuration, ..., file" 1>&2
    return 5
  elif [ ${rc_path_retval} -eq 4 ]; then
    if [ -f ${rc_path} -a -r ${rc_path} -a -w ${rc_path} ]; then
      if [ -s ${rc_path} ]; then
        echo "File ${rc_path} is non-zero in size." 1>/dev/null
      else
        echo "File ${rc_path} is zero in size." 1>/dev/null
      fi
    elif [ ! -e ${rc_path} ]; then
#      echo "File @ ${rc_path}, read from \$WEDI_RC environment variable (${WEDI_RC}) is non-existing"
#      echo "Going to touch it..."
      touch ${rc_path}
      return
    fi
  fi
  # Let's see the editors on the system. Shall we?
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

  for i in {0..7}
  do
    if check_editor_presence $(eval echo ${EDITORS[${i}]}); then
      let "STAT_REG |= $(eval echo \${EDI_${i}})"
    fi
  done
  printf "\nSTATUS REGISTER: %x\n\n" $STAT_REG
  return 0
}

# function to get the absolute path and a bit more
get_path()
{
#  echo "\$1 received by the get_path function: ${1}"
  if printf "%s" ${1} | grep -e '^-' -q; then
    return 1
#  elif [ ${1:-'.'} = '.' ]; then
  elif [ ${1:-'.'} = '.' ]; then
    tmp_path="$(pwd)"
  elif [ ${1} = '..' ]; then
    tmp_path="$(echo "$(cd ..; pwd)")"
  elif printf "%s" ${1} | grep -e '^~' -q; then
    tmp_path="$(eval dirname "${1}")"
    tmp_path="${tmp_path}/$(basename "${1}")"
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
  date -d $(echo "${1}" | grep -E '^[0-9]{4}\-((((0[13578])|(1[02]))\-(([0-2][0-9])|(3[01])))|(((0[469])|(11))\-(([0-2][0-9])|(30)))|(02\-[0-2][0-9]))$') +%s 2>/dev/null
  return
}

call_editor()
{
  if [ -z ${1} ]; then
    read tmp
    set "${tmp}"
  fi

  for i in {0..7}
  do
    let "tmp = $STAT_REG & (1 << ${i})"
    if [ $tmp -gt 0 ]; then
      eval \${EDITORS[${i}]} \${1}
      break
    fi
  done

  return
}

# formating file's path received on the STDIN or as the first
# pocitional parameter to STDOUT
fmt_rec()
{
  if [ -z ${1} ]; then
    declare local tmp
    read tmp
    set "${tmp}"
  fi

  printf "%10d \"%s/\" \"%s\"\n" $(date +%s) $(dirname ${1}) $(basename ${1})
}

# pushing string received on STDIN or the first positional parameter
# to the top of the stack
push_rc()
{
  if [ -z ${1} ]; then
    declare local tmp
    read tmp
    set "${tmp}"
  fi

  echo ${1} >> ${rc_path};

  return
}

# pushing string received on STDIN or the first positional parameter
# to the bottom of the stack
hsup_rc()
{
  if [ -z ${1} ]; then
    declare local tmp
    read tmp
    set "${tmp}"
  fi

  sed "1 i\\${1}" -i ${rc_path};

  return
}

# pop from the stack
pop_rc()
{
  if [ -z ${1} ]; then
#    declare local tmp=$(cat)
    read_rc
#    echo ${tmp} | del_rc
  else
    declare local tmp=$(read_rc ${1})

#    if [ "${tmp}" ]; then
    del_rc ${1}
    echo ${tmp}
#    else
#      return 1
#    fi
  fi

  return
}

# reads from the last line from the STDIN or from the fileű
# provided as the first positioal parameter
read_rc()
{
  if [ -z ${1} ]; then
    sed -n '$ p'
  else
    sed -n '$ p' <${1}
  fi

  return
}

# deletes the last line in the similar was as the read read_rc() reads
# if no file name is provided as the first argument then a stream is read
# from the STDIN and sent to the STDOUT
del_rc()
{
  if [ -z ${1} ]; then
    sed '$ d'
  else
    sed '$ d' -i ${1}
  fi

  return
}

rot_rc()
{
  pop_rc ${1} | hsup_rc

  return
}

# function to get a record from wedirc
# assuming using the thing between ears
# positional parameters needs to be strictly followed
# -a|b YY-MM-DD [file absolute path]
get_by_date()
{
  if [ cat $(uname) | grep -i -e 'BSD' ]; then
    eval epoch=$(date -j -f "${2} %H:%M:%S" "2018-02-02 00:00:00" +%s)
  elif [ cat $(uname) | grep -i -e 'Linux' ]; then
    eval epoch=$(date -d="${2}" +%s)
  else
    echo "Could not determine system." 1>2
    exit 6
  fi

  case ${1} in

    -a)
      awk -v epoch=${epoch} '$1 >= epoch { print }' ${3:-'-'}
      ;;

    -b)
      awk -v epoch=${epoch} '$1 <= epoch { print }' ${3:-'-'}
      ;;

  esac

  return
}

# function to retrieve a record by the directory
# the first positional parameter is the absolute path of the directory
# the second positional parameter is optional as in the get_by_date() function
# and it is the absolute path of the RC file
get_by_dir()
{
  path=$(get_path $(eval echo \${${1}}))
  path_retval=${?}
  if [ ${path_retval} -eq 3 ]; then
    awk -v path=${path} '$2 ~ /^$path$/ { print  }' ${2:-'-'}
  fi

  return
}

# function similar to the get_by_dir() function
# optins are nearly the same except the firs is the absolute path of a file
get_by_file()
{
  path=$(get_path $(eval echo \${${1}}))
  path_retval=${?}
  if [ ${path_retval} -eq 4 ]; then
    awk -v path=${path} '$3 ~ /^$path$/ { print  }' ${2:-'-'}
  fi

  return
}

# counts the number of records
# first parameter can be a path to a file, if not given STDIN is being used
# records are being separeted by new-line character
# the no. of records is being spit to the STDOUT
cnt_rec_rc()
{
  case ${1} in

    -r)
      cat ${2:-'-'} | grep -v -e '^[[:blank:]]*#' ${1:-'-'} | wc -l | sed -e 's/^[ \t]*//;s/[ \t]*$//'
      return
      ;;

    -a)
      cat ${2:-'-'} | wc -l | sed -e 's/^[ \t]*//;s/[ \t]*$//'
      return
      ;;

  esac

  return
}

parse_pospars()
{
echo
echo ">  Processing the options/arguments   >"
echo

i=1;
j=${i};
while [ ${i} -le ${#} ]
do
  echo -n "${i} -- ${#} -- "; eval echo \${${i}};

  current_path=$(get_path $(eval echo \${${i}}))
  current_path_retval=${?}

  echo " "
  echo ">>>>>>>-- '${current_path}' -- '${current_path_retval}' --<<<<<<<<<<"
  echo " "

  case ${current_path_retval} in

    1)
      eval echo "\${${i}} option receive... OK. The question is: Will it blend?"
      case "$(eval echo \${${i}})" in

        -m)
          echo "the MOST called file..."
          let "j += i";
          path=$(get_path $(eval echo \${${j}}))
          path_retval=${?}
          if [ ${path_retval} -eq 3 ]; then
            echo "...from directory: ${path}"
            cat ${rc_path} | grep -e " \"${path}\" " | cut -d ' ' -f 3 | sort | uniq -c | sort | tail -1 | awk -F '"' '{ print $2 }'
            let "i += 2";
          elif [ ${path_retval} -eq 4 ]; then
            echo "...wait a minute, init this a file? ${path}"
            let "i += 2";
          elif [ ${path_retval} -eq 1 ]; then
            echo "...hmmm it seems, that the next positional parameter is an option. ${j}"
            path=$(get_path '.')
            echo "using the current working directory... @ ${path}"
            cat ${rc_path} | grep -e " \"${path}\" " | cut -d ' ' -f 3 | sort | uniq -c | sort | tail -1 | awk -F '"' '{ print $2 }'
            let "i++";
          fi
          ;;

        -l)
          echo "the LAST called file..."
          let "j += i";
          path=$(get_path $(eval echo \${${j}}))
          path_retval=${?}
          if [ ${path_retval} -eq 3 ]; then
            echo "...from directory: ${path}"
            cat ${rc_path} | grep -e " \"${path}\" " | cut -d ' ' -f 3 | tail -1 | awk -F '"' '{ print $2 }'
            let "i += 2";
          elif [ ${path_retval} -eq 4 ]; then
            echo "...wait a minute, init this a file? ${path}"
            let "i += 2";
          elif [ ${path_retval} -eq 1 ]; then
            echo "...hmmm it seems, that the next positional parameter is an option. ${j}"
            path=$(get_path '.')
            echo "using the current working directory... @ ${path}"
            cat ${rc_path} | grep -e " \"${path}\" " | cut -d ' ' -f 3 | tail -1 | awk -F '"' '{ print $2 }'
            let "i++";
          fi
          ;;

        -a|b)
          let "j = i + 1";
          declare local date=$(eval echo \${${j}})
          declare local date_epoch=$(evaluate_date ${date})
          declare local date_retval=${?}
          let "k = i + 2";
          declare local path
          path=$(get_path $(eval echo \${${k}}))
          declare local path_retval=${?}
          if [ 0 -eq ${date_retval} ]; then
            case "$(eval echo \${${i}})" in
            -a)
              echo "files called AFTER ${date}..."
              echo "${path_retval} -- ${path}"
              echo
              if [ ${path_retval} -eq 3 ]; then
                echo "...from directory: ${path}"
                cat ${rc_path} | grep -e " \"${path}\" " | awk -v date_epoch=${date_epoch} '$1>=date_epoch { gsub(/"/, "", $3); print $3 }'
                let "i += 3";
              elif [ ${path_retval} -eq 4 ]; then
                echo "...wait a minute, init this a file? ${path}"
                let "i += 3";
              elif [ ${path_retval} -eq 1 ]; then
                echo "...hmmm it seems, that the next positional parameter is an option. ${j}"
                path=$(get_path '.')
                echo "using the current working directory... @ ${path}"
                cat ${rc_path} | grep -e " \"${path}\" " | awk -v date_epoch=${date_epoch} '$1>=date_epoch { gsub(/"/, "", $3); print $3 }'
                let "i++"
              fi
              ;;
            -b)
              echo "files called BEFORE ${date}..."
              if [ ${path_retval} -eq 3 ]; then
                echo "...from directory: ${path}"
                cat ${rc_path} | grep -e " \"${path}\" " | awk -v date_epoch=${date_epoch} '$1<date_epoch { gsub(/"/, "", $3); print $3 }'
                let "i += 3";
              elif [ ${path_retval} -eq 4 ]; then
                echo "...wait a minute, init this a file? ${path}"
                let "i += 3";
              elif [ ${path_retval} -eq 1 ]; then
                echo "...hmmm it seems, that the next positional parameter is an option. ${j}"
                path=$(get_path '.')
                echo "using the current working directory... @ ${path}"
                cat ${rc_path} | grep -e " \"${path}\" " | awk -v date_epoch=${date_epoch} '$1<date_epoch { gsub(/"/, "", $3); print $3 }'
                let "i++"
              fi
              ;;
            esac
          else
            echo "wrrrroooonnnnngggggg DATE to list files called AFTER \"${date}\"..."
            if [ ${path_retval} -eq 3 ]; then
              echo "...from directory: ${path}"
              let "i += 3";
            elif [ ${path_retval} -eq 4 ]; then
              echo "...wait a minute, init this a file? ${path}"
              let "i += 3";
            elif [ ${path_retval} -eq 1 ]; then
              echo "...hmmm it seems, that the next positional parameter is an option. ${j}"
              path=$(get_path '.')
              echo "using the current working directory... @ ${path}"
              let "i += 2"
            fi
          fi
          ;;
      esac
      ;;

    3)
      eval echo "\${${i}} is a directory with absolute path: ${current_path}"
      rec_no=$(cnt_rec_rc -r ${rc_path} )
      lin_no=$(cnt_rec_rc -a ${rc_path})

      echo " "
      echo ">>>> ${records} <<<<"
      echo " "

      while [ $lin_no -gt 0 ]
      do
        local tmp=$(read_rc)
        if [ { echo ${tmp} | grep -e "${current_path}" -q } ]; then
          echo ${tmp} | awk '{ print $2 }'
        fi
      rot_rc
      let "lin_no--";
      done

      let "i++";
      ;;

    4)
      eval echo "\${${i}} is or will be a file at the following path: ${current_path}"

      push_rc "${current_path}"
      call_editor ${current_path}

      let "i++";
      ;;

  esac
done
return
}

init;
init_return_code=${?}

if [ ${init_return_code} -eq 0 ]; then
  echo "Successfully initialized. Return Code: ${init_return_code}"
else
  echo "Initialization unsuccessful. Return Code: ${init_return_code}"
  exit ${init_return_code}
fi

parse_pospars ${*};

exit
