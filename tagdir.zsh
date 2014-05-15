#!/usr/bin/zsh

emulate -L zsh

TAG_CONF_DIR="${HOME}/.tagdir"
local store_file=$TAG_CONF_DIR/store

if [ ! -d $TAG_CONF_DIR ]; then
  mkdir $TAG_CONF_DIR
  echo "${TAG_CONF_DIR} created."
fi

if [ ! -e $store_file ]; then
  touch $store_file
  echo "${store_file} created."
fi

tagdir_help=`cat <<EOF
tagdir memorise directories with tags. so you can find directories with tag!!

USAGE:
  tagdir list     : show all memorized directories with tags
  tagdir add TAGS : create new entry for current directory. TAGS delimiter is ' '
EOF`


function tagdir() {

  if [ $# -eq 0 ]; then
    echo $tagdir_help
    return
  fi

  case $1 in
    list)
      color_number=32
      color="\x1b[038;05;${color_number}m"
      reset="\x1b[0m"
      sed -e "s/^\([^:]*\)/${color}\1${reset}/g" -e "s/:/\t/" $store_file
      # paste <(cut -d: -f1 $store_file) <(cut -d: -f 2- $store_file)
      ;;
    add)
      shift
      old_tags=""
      if cut -d: -f1 $store_file | fgrep $PWD > /dev/null; then
        local line_number=$(cat $store_file | egrep -n "^${PWD}:" | cut -d: -f1)
        old_tags=$(fgrep $PWD $store_file | cut -d: -f 2- )
        sed -i "${line_number}d" $store_file
      fi
      echo "$PWD:$(echo -n $old_tags $@ | sed 's/ /,/g')" >> $store_file
      ;;
    edit)
      $EDITOR $store_file
      ;;
    *)
      echo $tagdir_help
      ;;
  esac
}
