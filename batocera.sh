#!/bin/bash

# Stop EmulationStation
emulationstation stop; chvt 3; clear

# Resize tmp folder
mount -o remount,size=30000M /tmp

# Install necessary programs
if [ "$(readlink /usr/bin/fusermount3)" != "/usr/bin/fusermount" ]; then ln -s /usr/bin/fusermount /usr/bin/fusermount3; fi
if ! command -v rclone &> /dev/null; then curl https://rclone.org/install.sh | bash > /dev/null 2>&1; fi
if [ ! -f /userdata/system/rclone.conf ];  then wget -O /userdata/system/rclone.conf https://raw.githubusercontent.com/WizzardSK/gameflix/main/rclone.conf > /dev/null 2>&1; fi
if [ ! -f /userdata/system/httpdirfs ];  then wget -O /userdata/system/httpdirfs  https://github.com/WizzardSK/gameflix/raw/main/batocera/share/system/httpdirfs; chmod +x /userdata/system/httpdirfs; fi
if [ ! -f /userdata/system/mount-zip ];  then wget -O /userdata/system/mount-zip  https://github.com/WizzardSK/gameflix/raw/main/batocera/share/system/mount-zip; chmod +x /userdata/system/mount-zip; fi
if [ ! -f /userdata/system/ratarmount ]; then wget -O /userdata/system/ratarmount https://github.com/mxmlnkn/ratarmount/releases/download/v0.15.2/ratarmount-0.15.2-x86_64.AppImage; chmod +x /userdata/system/ratarmount; fi

# Read platforms in roms variable
IFS=$'\n' read -d '' -ra roms <<< "$(curl -s https://raw.githubusercontent.com/adriadam10/gameflix/main/platforms.txt)"

# Create necessary folders
mkdir -p /userdata/{rom,roms,thumb,thumbs,zip} /userdata/system/.cache/{httpdirfs,ratarmount,rclone}

# Mount all myrient in rom folder
rclone mount myrient: /userdata/rom --http-no-head --no-checksum --no-modtime --attr-timeout 1000h --dir-cache-time 1000h --poll-interval 1000h --allow-non-empty --daemon --no-check-certificate --config=/userdata/system/rclone.conf

IFS=";" # Use ; as delimiter

# Declare seen variable
declare -A seen

# Create gamelist.xml if needed
for each in "${roms[@]}"; do 
  read -ra rom < <(printf '%s' "$each")
  if [ ! -f /userdata/roms/"${rom[0]}"/gamelist.xml ]; then touch /userdata/roms/"${rom[0]}"/gamelist.xml; fi
done

# Prepare platforms
for each in "${roms[@]}"; do 
  read -ra rom < <(printf '%s' "$each") # Read platform to rom variable

  # Download thumbs if needed
  if [ ! -f /userdata/thumb/"${rom[0]}".png ]; then wget -O /userdata/thumb/"${rom[0]}".png https://raw.githubusercontent.com/fabricecaruso/es-theme-carbon/master/art/consoles/"${rom[0]}".png; fi
  if [[ -z "${seen[${rom[0]}]}" ]]; then
    seen[${rom[0]}]=1
    rom2="${rom[2]// /_}"
    if [ ! -d "/userdata/thumbs/${rom[2]}" ]; then
       wget "https://github.com/WizzardSK/${rom2}/archive/refs/heads/master.zip" -O /tmp/"${rom2}".zip && unzip -qq /tmp/"${rom2}".zip -d /userdata/thumbs/"${rom[2]}" && rm /tmp/"${rom2}".zip && mv "/userdata/thumbs/${rom[2]}/${rom2}-master/"*/ /userdata/thumbs/"${rom[2]}"
    fi
  fi  

  # Mount platform in roms folder
  ( rom3=$(sed 's/<[^>]*>//g' <<< "${rom[3]}")
  mkdir -p /userdata/roms/"${rom[0]}"/"${rom3}"
  if [[ ${rom[1]} =~ \.zip$ ]]; then
    perror "${rom[1]} is a zip! not allowed!"
  else
    mount -o bind /userdata/rom/"${rom[1]}" /userdata/roms/"${rom[0]}"/"${rom3}"
  fi
  
  # Create gamelist if needed
  if ! head -n 1 /userdata/roms/"${rom[0]}"/gamelist.xml | grep -Fxq "<gameList>" > /dev/null 2>&1; then
    echo "<gameList>" > /userdata/roms/"${rom[0]}"/gamelist.xml
    ls /userdata/roms/"${rom[0]}"/"${rom3}" | while read line; do
      line2=${line%.*}
      hra="<game><path>./${rom3}/${line}</path><name>${line2}</name><image>~/../thumbs/${rom[2]}/Named_Snaps/${line2}.png</image><titleshot>~/../thumbs/${rom[2]}/Named_Titles/${line2}.png</titleshot><thumbnail>~/../thumbs/${rom[2]}/Named_Boxarts/${line2}.png</thumbnail><marquee>~/../thumbs/${rom[2]}/Named_Logos/${line2}.png</marquee>"
      if (grep -iE 'pal|europe|(eu)' | grep -ivqE 'beta|demo') <<< "$line"; then
        echo "${hra}</game>" >> /userdata/roms/"${rom[0]}"/gamelist.xml
      else 
        echo "${hra}<hidden>true</hidden></game>" >> /userdata/roms/"${rom[0]}"/gamelist.xml
      fi
    done
    echo "<folder><path>./${rom3}</path><name>${rom3}</name><image>~/../thumb/${rom[0]}.png</image></folder>" >> /userdata/roms/"${rom[0]}"/gamelist.xml
    echo "</gameList>" >> /userdata/roms/"${rom[0]}"/gamelist.xml
  fi 
  echo "${rom[2]} loaded") &
done

# Wait mount and gamelist creation to finish
wait

# Change emulationstations systems config
cp /usr/share/emulationstation/es_systems.cfg /usr/share/emulationstation/es_systems.bak
wget -O /usr/share/emulationstation/es_systems.cfg https://github.com/WizzardSK/gameflix/raw/main/batocera/share/system/es_systems.cfg > /dev/null 2>&1

# Reload emulationstation
chvt 2; wget http://127.0.0.1:1234/reloadgames -O /dev/null > /dev/null 2>&1
