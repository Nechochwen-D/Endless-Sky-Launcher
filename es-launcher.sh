#!/bin/bash
Path=$(dirname $(readlink -f $0))"/"
Config=$Path"es-launcher.config"
Resources=$Path"ES-launcher/"
Repos=$Resources"repositories/"
Instances=$Resources"instances/"

declare -a Repository
declare -a Plugin
declare -a Savefile
declare -a Version
declare -a OS
declare -a Result

lower(){
    case "$1" in
        [A-Z])
        n=$(printf "%d" "'$1")
        n=$((n+32))
        printf \\$(printf "%o" "$n")
        ;;
        *)
        printf "%s" "$1"
        ;;
    esac
}

HeaderText () {

	local bar=""
	local i=0
	local size=${#1}
	
	
	while (( $i < $size ))
	do
		bar+="-"
		((i++))
	done
	
	echo $bar
	echo $*
	echo $bar
}

StreamText () {
	
	local i=0
	
	while (( $i <= ${#1} ))
	do
		printf "$(expr substr "$1" $i 1)"
		if [ $2 ]
		then
			sleep $2
		else
			sleep .1
		fi
		((i++))
	done
	printf "\n"
}

Search () {
  
	local -n Array=$1
	local Reply=$2
	local Number=$3 
	local Term=$4
	local begin=$5
	(( begin-- ))
	
	local i=0
	local e=$begin
	local n=1
	
	unset $Result
	echo "test"
	echo "${Array[1]}"
	
	while (( i < ${#Array[@]} ))
	do
		read -a Break <<< ${Array[i]}
		case $Reply in
			bool)
				echo "${Break[e]}"
				if [[ "${Break[e]}" == *"$Term"* ]]
				then
					echo "$Term"
					return 0
				fi
			;;
			*)
				if [[ "${Break[e]}" == *"$Term"* ]]
				then
					Result[${#Result[@]}]=${Break[$Reply]}
					echo $Result
				fi
				if (( $n >= $Number || $n == ${#Array[@]} ))
				then
					return 0
				fi
				((n++))
			;;
		esac
		((i++))
	done
	return 1
}

Menu () {
	MenuInput=0
	printf "1:\tLaunch Version\n"
	printf "2:\tCompile Version\n"
	printf "3:\tImport Repository\n"
	printf "4:\tExit\n"
	echo
	while [ 1 ]
	do
		case $MenuInput in
			1) # Launch Version
				if [ ! ${Version[0]} ]
				then
					echo "There are no versions avaliable to run."
					echo "Please select compile from the list of options."
					echo
					Menu
				fi
				Launch
				break
			;;
			2) # Compile Version
				if ( ! Search "Repository" "bool" "void" "source" 4 )
				then
					echo "There are no repositories avaliable to compile."
					echo "Please import a repository containing source code."
					echo
					Menu
				fi
				Compile
				break
			;;
			3) # Import Repository
				Import
				break
			;;
			4) # Exit
				break
			;;
			*)
				echo "Please enter the number next to your choice."
				read MenuInput
				echo
			;;
		esac
	done
}

Launch () {
	:
}

Compile () {
	:
}

Import () {
	:
}

touch $Config	
mkdir -p $Resources
mkdir -p $Repos
mkdir -p $Instances

echo "Loading configuration file."
while read -a line
do
	case "${line[0]}" in
		repository)
			Repository[${#Repository[@]}]=${line[@]:1}
		;;
		plugin)
			Plugin[${#Plugin[@]}]=${line[@]:1}
		;;
		savefile)
			Savefile[${#Savefile[@]}]=${line[@]:1}
		;;
		version)
			Version[${#Version[@]}]=${line[@]:1}
		;;
		OS)
			OS[${#OS[@]}]=${line[@]:1}
		;;
	esac
done < "$Config"
echo "done"


# first time setup

if [[ ${#OS[@]} == 0 ]]
then
	while [ 1 ]
	do
		case $OSinput in
			Linux)
				break
			;;
			Windows)
				echo "Please enter the full path to your Code::Blocks executable starting with the drive."
				read OScompiler
				OS[1]=/mnt/
				i=0
				if [ "$(expr substr "$str" 2 1)" = ":" ]; then
					lower $char
					OS[1]+=$char/
				fi
				while (( i <= ${#OScompiler} ))
				do
					char=$(expr substr "$str" $i 1)
					
											((i++))
					
				done
				break
			;;
			OSX)
				echo "The author does not currently know how to compile for OSX. If you have done so please feel free to make a PR at http://github.com/Nechochwen-D/ES-launcher"
				exit 0
			;;
			*)
				echo "please enter OS (Linux, Windows, OSX)"
				read OSinput
				echo
			;;
		esac
	done
	OS[0]=$OSinput
fi

if ( Search "OS" 2 1 "Windows" 1)
then
	str=$(printf $Reply)
fi

if ( ! Search "Repository" "bool" "void" "endless-sky/endless-sky" 1 )
then
	indexL=${#Repository[@]}
	Repository[$indexL]="https://github.com/endless-sky/endless-sky.git auto"
	cd $Repos
	git clone https://github.com/endless-sky/endless-sky.git
	Repository[$indexL]+=" $(ls -td $Repos*/ | head -1) source"
fi

# begin interface

clear

HeaderText "Welcome to the unofficial launcher for Endless Sky."
echo "Script created by Nechochwen."
echo
echo "What do you want to do?" 
echo
Menu

echo ${#OS[@]}

# Write to .config file.

echo "# Repositories" > $Config
echo >> $Config
i=0
while [[ $i < ${#Repository[@]} ]]
do
	echo "repository ${Repository[$i]}" >> $Config
	((i++))
done
echo >> $Config
echo "# Plugins" >> $Config
echo >> $Config
i=0
while [[ $i < ${#Plugin[@]} ]]
do
	echo "plugin ${Plugin[$i]}" >> $Config
	((i++))
done
echo >> $Config
echo "# Saves" >> $Config
echo >> $Config
i=0
while [[ $i < ${#Savefile[@]} ]]
do
	echo "savefile ${Savefile[$i]}" >> $Config
	((i++))
done
echo >> $Config
echo "# Versions" >> $Config
echo >> $Config
i=0
while [[ $i < ${#Version[@]} ]]
do
	echo "version ${Version[$i]}" >> $Config
	((i++))
done
echo >> $Config
echo >> $Config
i=0
while [[ $i < ${#OS[@]} ]]
do
	echo "OS ${OS[$i]}" >> $Config
	((i++))
done
