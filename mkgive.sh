#!/bin/sh
# Generates /give command for Minecraft and prints it to stdout
# DON'T USE IT!!!

USED_ATTRS=
USED_ENCHS=

ITEM_ID=
ITEM_NAME=
LORE=
COUNT=
TARGET=

UNBREAKABLE=

ATTRS="
generic.max_health
generic.follow_range
generic.knockback_resistance
generic.movement_speed
generic.attack_damage
generic.armor
generic.armor_toughness
generic.attack_knockback
generic.attack_speed
generic.luck
horse.jump_strength
generic.flying_speed
zombie.spawn_reinforcements
"

ENCHS="
minecraft:aqua_affinity
minecraft:bane_of_arthropods
minecraft:binding_curse
minecraft:blast_protection
minecraft:channeling
minecraft:depth_strider
minecraft:efficiency
minecraft:feather_falling
minecraft:fire_aspect
minecraft:fire_protection
minecraft:flame
minecraft:fortune
minecraft:frost_walker
minecraft:impaling
minecraft:infinity
minecraft:knockback
minecraft:looting
minecraft:loyalty
minecraft:luck_of_the_sea
minecraft:lure
minecraft:mending
minecraft:multishot
minecraft:piercing
minecraft:power
minecraft:projectile_protection
minecraft:protection
minecraft:punch
minecraft:quick_charge
minecraft:respiration
minecraft:riptide
minecraft:sharpness
minecraft:silk_touch
minecraft:smite
minecraft:soul_speed
minecraft:sweeping
minecraft:thorns
minecraft:unbreaking
minecraft:vanishing_curse
"

echoerr() {
   printf "mkgive: %s\n" "$*" >&2
}

genrand() {
   echo "4" # chosen by fair dice roll.
            # guaranteed to be random.
}

makedisplay() {
   if [ -n "$ITEM_NAME$LORE" ]; then
      printf "display:{"
      test -n "$ITEM_NAME" && printf "Name:\"{\\\"text\\\":\\\"%s\\\"}\", " "$ITEM_NAME"
      test -n "$LORE" && printf "Lore: [\"\\\"%s\\\"\"]," "$LORE" 
      printf "}," 
   fi
}
makeunbreakable() {
   if [ -n "$UNBREAKABLE" ]; then
      echo "Unbreakable: 1,"
   fi
}

# ATTRIBUTES
makeattr() {
   if [ -n "$*" ]; then
      NAME="$(echo "$ATTRS" | grep -i "$(echo "$*" | awk -F, '{print $1}')")"
      AMOUNT="$(echo "$*" | awk -F, '{print $2}')" 
      OPERATION="$(echo "$*" | awk -F, '{print $3}')" 

      # Is this what you call error checking?
      test -z "$NAME" && echoerr "attribute: name of attribute is empty" && exit 1;
      test -z "$AMOUNT" && echoerr "attribute: amount is empty" && exit 1;
      test -z "$OPERATION" && echoerr "attribute: operation is empty" && exit 1;

      printf "{"
         printf "AttributeName:\"%s\", " "$NAME"
         printf "Name:\"%s\", " "$NAME"
         printf "Amount: %s, " "$AMOUNT"
         printf "Operation: %s, " "$OPERATION"
         printf "UUID:[I; %s, %s, %s, %s]" "$(genrand)" "$(genrand)" "$(genrand)" "$(genrand)"     
      printf "},"
   fi
}

makeattrs() {
   if [ -n "$USED_ATTRS" ]; then
      printf 'AttributeModifiers: ['
      for f in $USED_ATTRS; do
         makeattr "$f"
      done 
      printf '],'
   fi
}

# ENCHANTMENTS
makeench() {
   if [ -n "$*" ]; then
      ENCH_ID="$(echo "$ENCHS" | grep "$(echo "$@" | awk -F, '{print $1}')")"
      LEVEL="$(echo "$*" | awk -F, '{print $2}')" 

      test -z "$ENCH_ID" && echoerr "enchantment ID is empty" && exit 1;
      test -z "$LEVEL" && echoerr "$ENCH_ID: level is empty" && exit 1;

      printf "{id:\"%s\",lvl:%s}, " "$ENCH_ID" "$LEVEL"
   fi
}

makeenchs() {
   if [ -n "$USED_ENCHS" ]; then
      printf 'Enchantments: ['
      for f in $USED_ENCHS; do
         makeench "$f"
      done 
      printf '],'
   fi
}

# HELP 
help() {
   h() {
      echo "mkgive - generates /give command for Minecraft and prints it to stdout."
   }
   c() {
      OPT_NAME="$1"
      OPT_ARGS="$2"
      OPT_DESC="$3"
      printf "   %s - %s.\n" "$OPT_NAME [$OPT_ARGS]" "$OPT_DESC"
   }
   args() {
      c "-i" "<item_id>" "item ID"
      c "-t" "<target>" "specify target"
      c "-a" "<attribute_name>,<amount>,<operation>" "attribute modifier"
      c "-e" "<enchantment>,<level>" "enchantment"
      c "-u" "" "unbreakable"
      c "-d" "<display_name>" "display name"
      c "-l" "<lore>" "lore, a description for an item"
      c "-c" "<count>" "count"
   }
   e() {
      echo "Example: "
      echo "   mkgive -i wooden_sword -t @p -a max_health,1,1 -e fortune,1";
   }
   h
   echo "Available arguments: "
   args
   echo "Note: '-i' and '-t' are necessary."
   e
}

# MAIN
mkgive() {
   CMD_UNBREAKABLE="$(makeunbreakable)"
   CMD_DISPLAY="$(makedisplay)"
   CMD_ENCHS="$(makeenchs)"
   CMD_ATTRS="$(makeattrs)"
   test -z "$TARGET" && echoerr "no target is specified, use \`-t <target>\`"  && exit 1
   test -z "$ITEM_ID" && echoerr "no item ID is specified, use \`-i <item_id>\`"  && exit 1
   printf "give %s %s" "$TARGET" "$ITEM_ID"
   if [ -n "$CMD_UNBREAKABLE$CMD_DISPLAY$CMD_ENCHS$CMD_ATTRS" ]; then
      printf "{";
      test -n "$CMD_UNBREAKABLE" && printf "%s " "$CMD_UNBREAKABLE";
      test -n "$CMD_DISPLAY"     && printf "%s " "$CMD_DISPLAY";
      test -n "$CMD_ENCHS"       && printf "%s " "$CMD_ENCHS";
      test -n "$CMD_ATTRS"       && printf "%s" "$CMD_ATTRS";
      printf "}";
   fi
   test -z "$COUNT" || printf " %s\n" "$COUNT"
   printf "\n"
}

main() {
   while getopts hc:ud:t:i:a:e:l: opt
   do
      case $opt in 
         h) help && exit 0;;
         u) UNBREAKABLE=1 ;;
         i) ITEM_ID="$OPTARG" ;;
         t) TARGET="$OPTARG"  ;;
         c) COUNT="$OPTARG" ;;
         d) ITEM_NAME="$OPTARG" ;;
         l) LORE="$OPTARG" ;;
         a)
            ATTR="$OPTARG";
            USED_ATTRS="$USED_ATTRS $ATTR" ;;
         e) 
            ENCH="$OPTARG";
            USED_ENCHS="$USED_ENCHS $ENCH" ;;
         *) echo "Unknown command"; exit 1 ;;
      esac
   done
   mkgive
}

main "$@"
