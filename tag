#!/bin/sh
# tag: allows you to tag files.


if [ -z "$TAGDIR" ]; then
   echo "TAGDIR is undefined" && exit 1;
fi

echoerr() {
   printf "tag: %s\n" "$*" >&2 ; 
}

usage() {
   h() {
      echo "tag - allows you to tag files."
      echo "Available commands: "
   }
   c() {
      CMDNAME="$1"
      CMDARGS="$2"
      CMDDESC="$3"
      printf "   %5s [%8s] - %s\n" "$CMDNAME" "$CMDARGS" "$CMDDESC"
   }
   h
   c "add" "TAG FILE" "adds tag to a certain file."
   c "help" "" "shows help"
   c "ls" "" "lists all available tags."
   c "rm" "TAG FILE" "removes tag from a certain file."
   c "show" "TAG" "shows all file with specified tags"
   c "view" "FILE" "shows all tags applied to a specific file."
}

tagls() {
   find "$TAGDIR" -type f | sed "s/.*\///g; s/\.tag//g"
}  

tagrm() {
   TAG="$1"

   if [ $# -lt 3 ]; then
      printf "Do you want to remove tag %s from all files[y/N]: " "$TAG"
      read -r ANSWER
      case "$ANSWER" in
           Y|y) rm "$TAGDIR/$TAG.tag" && exit 0 ;;
         N|n|*) exit 0 ;;
      esac
   fi

   shift 
   for f in "${@}"; do
      sed -i "/$f/d" "$TAGDIR"/"$TAG".tag
   done

   if [ -z "$(cat "$TAGDIR/$TAG.tag")" ]; then
      rm "$TAGDIR/$TAG.tag";
   fi
}

tagadd() {
   TAG="$1"

   if [ -z "$TAG" ]; then
      echoerr "TAG is empty"
   fi
   
   shift 
   for f in "${@}"; do
      readlink -f "$f" >> "$TAGDIR/$TAG.tag"
   done
}

tagshow() {
   TAG="$1"

   if [ -r "$TAGDIR/$TAG.tag" ]; then
      cat "$TAGDIR"/"$TAG".tag
   else 
      echoerr "\"$TAG\" does not exists" && exit 1;
   fi;
}

tagview() {
   FILE="$1"
   for t in $(tagls); do
      grep "$FILE" "$TAGDIR/$t.tag" >/dev/null && echo "$t"
   done
}

case "$1" in
     ls|l) shift; tagls "$@" ;;
     rm|r) shift; tagrm "$@" ;;
    add|a) shift; tagadd "$@" ;;
   show|s) shift; tagshow "$@" ;;
   view|v) shift; tagview "$@" ;;
   help|h) shift; usage ;;
        *) echoerr "Unknown command" && exit 1 ;;
esac
