#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source $HOME/.priv
set -o vi
################################################################
export PATH=$PATH:$HOME/.local/bin:/opt/cuda/bin
export SUDO_EDITOR=nvim
export WINEDLLOVERRIDES=winemenubuilder.exe=d
################################################################

setAuthHeader() {
    local p1=$1
    local uri=${p1/'https://'/$URI_WITH_CRED}
    local tail=()
    for param; do
        [[ ! $param == $1 ]] && tail+=($param)
    done
    local ret="$uri ${tail[@]}"
    echo ${ret//'~'/$HOME}
}

makeBatchScript() {
    local script='$sourceuri="<bouncer_uri><res_path>"
$targetpath="$env:userprofile\<filename>"
$username="<bouncer_user>"
$password="<bouncer_pass>"
$ftpwebrequest=[system.net.ftpwebrequest]::create($sourceuri)
$ftpwebrequest.credentials=new-object system.net.networkcredential($username,$password)
$ftpwebrequest.enablessl=$true
$webresponse=$ftpwebrequest.getresponse()
$stream=$webresponse.getresponsestream()
$targetfile=new-object system.io.filestream($targetpath,[io.filemode]::create)
[byte[]]$buf=new-object byte[] 16384
do {
$readlength=$stream.read($buf,0,16384)
$targetfile.write($buf,0,$readlength)
} while ($readlength -ne 0)
$targetfile.close()'
    local p1=$1
    local res_path=${p1/$SBOX_URI/}
    local filename=${res_path##*/}
    local script_new=${script//'<res_path>'/$res_path}
    script_new=${script_new//'<filename>'/$filename}
    script_new=${script_new//'<bouncer_uri>'/$BOUNCER_URI}
    script_new=${script_new//'<bouncer_user>'/$BOUNCER_USER}
    script_new=${script_new//'<bouncer_pass>'/$BOUNCER_PASS}
    local encoded=$(echo "$script_new" | unix2dos | iconv -t utf-16le | base64 -w0 -)
    echo '@echo off' > ./$filename.bat
    echo "powershell -encoded $encoded" >> ./$filename.bat
    unix2dos ./$filename.bat
}

sboxget() {
    local p1=$1
    local uri=${p1/$SBOX_URI/$BOUNCER_URI}
    local filename=${uri##*/}
    curl --ssl -k --user $BOUNCER_USER:$BOUNCER_PASS --output $filename $uri
}

################################################################
alias gitdot='git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME'

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias mpvsync='syncplay --no-gui --no-store --player-path /usr/bin/mpv -a $SYNCPLAY_SERVER -n $USER -r $SYNCPLAY_ROOM'
alias mpvseedbox='f(){ unset -f f; mpv $(setAuthHeader "$@"); }; f'

alias send7z='7z a -mhe=on -p$(keepassxc-cli generate -L 256 | tee /dev/tty) -mx0 data.7z'
alias qbittnovpn="sed -i '/Connection\\\Interface=/s/tun0/enp12s0/;/Connection\\\InterfaceName=/s/tun0/enp12s0/;/Session\\\Interface=/s/tun0/enp12s0/;/Session\\\InterfaceName=/s/tun0/enp12s0/' $HOME/.config/qBittorrent/qBittorrent.conf && qbittorrent ; sed -i '/Connection\\\Interface=/s/enp12s0/tun0/;/Connection\\\InterfaceName=/s/enp12s0/tun0/;/Session\\\Interface=/s/enp12s0/tun0/;/Session\\\InterfaceName=/s/enp12s0/tun0/' $HOME/.config/qBittorrent/qBittorrent.conf"

alias battlenet='env WINEESYNC=1 WINEPREFIX=$HOME/wine_prefixes/battlenet WINEDLLOVERRIDES=$WINEDLLOVERRIDES\;nvapi,nvapi64=d WINEDEBUG=-all DXVK_LOG_LEVEL=none wine $HOME/wine_prefixes/battlenet/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net\ Launcher.exe'
alias killbattlenet='env WINEPREFIX=$HOME/wine_prefixes/battlenet wineserver -k'

alias fixwin="wmctrl -r 'obs_viewer - Google Chrome' -e 0,0,0,1314,890"
alias fixwins='wmctrl -e 0,0,0,1280,720 -r'
################################################################

CYAN="\[$(tput setaf 6)\]"
RESET="\[$(tput sgr0)\]"
PS1="${CYAN}\W \$${RESET} "
