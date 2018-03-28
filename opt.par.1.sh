while getopts a:b:c: o
do
        case "$o" in
                a) echo "$OPTIND Option 'a' found. '$OPTARG'";;
                b) echo "$OPTIND Option 'b' found with parameter '$OPTARG'.";;
                c) echo "$OPTIND Option 'c' found. '$OPTARG'";;
                *) echo "$OPTIND Use options a, b with a parameter, or c." >&2
                        exit 1;;
        esac
done

echo $OPTIND
