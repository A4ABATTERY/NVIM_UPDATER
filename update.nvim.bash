#!/bin/bash

#change dir to user's $HOME
cd ~

#function that asks yes/no input  (y/n)
askInput (){
	retVal=0
	read -p "$1 (y/n): " answer
	case ${answer:0:1} in
	    y|Y )
		retVal=$(true)
	    ;;
	    * )
		retVal=$(false)
	    ;;
	esac
	
	return $retVal
	
}


#Check if vim/vi is installed.....
#### First check if the vim/vi command works, then check if the APT package is installed.
(/usr/bin/vim --version > /dev/null 2> /dev/null  || /usr/bin/vi --version > /dev/null 2> /dev/null ) && (apt list --installed 2> /dev/null | grep -P "^vim-[a-z]+" -o > /dev/null 2> /dev/null )

# Check return value of the command directly above
if [[ $? -eq 0 ]]
then
	echo "Vim is still installed :( "
	echo "IMO: NeoVim is better"
	var=( $(apt list --installed 2> /dev/null | grep -P "^vim-[a-z]+" -o) )
	var_str=$(apt list --installed 2> /dev/null | grep -P "^vim-[a-z]+" -o)
	
	askInput "$(echo Do you want to uninstall the following? $var_str)"
	
	# Check return value of the command directly above
	if [ $? -eq 0 ]
	then
		
		var=( $(apt list --installed 2> /dev/null | grep -P "^vim-[a-z]+" -o) )
		var=${var[@]%%:*}
		i=1
		for vim_prog in $var;
			do
			
			sudo apt remove $vim_prog -y  2> /dev/null >/dev/null
			echo "Ran: sudo apt remove $vim_prog"
			
		done;
	
	fi
fi


if [ -f ~/nvim.appimage ] 
then

	askInput "$(echo Do you want to delete the existing nvim.appimage and download the latest version?)"
	
	# Check return value of the command directly above
	if [ $? -eq 0 ]
	then
		
		rm -rf ./nvim.appimage
		$(curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage)
		chmod u+x ./nvim.appimage
		
	fi
	
else
	$(curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage)
	chmod u+x ./nvim.appimage

	
fi

echo ""
echo "Installation of nvim.appimage involves deleting/removing the existing sym-link /usr/bin/nvim or uninstalling existing neovim package via APT package manager"
echo ""

askInput "$(echo Do you want to install/re-install nvim? \(If you have never installe Neovim, then answer yes \(y\).\))"

# Check return value of the command directly above
if [ $? -eq 0 ]
then
	#Check if Neovim is installed usin APT
	(apt list --installed 2> /dev/null | grep -P "(\w+-)?neovim(-\w+)?" > /dev/null)
	
	# Check return value of the command directly above
	if [ $? -eq 0 ]
	then
		echo "Using APT to remove neovim pacakge"
		
		var=( $(apt list --installed 2> /dev/null | grep -P -o "(\w+-)?neovim(-\w+)?" 2> /dev/null) )
		var=${var[@]%%:*}
		i=1
		for neovim_prog in $var;
			do
			
			sudo apt remove $neovim_prog -y 2> /dev/null >/dev/null
			echo "Ran: apt remove $neovim_prog"
		done;
	fi
	
	
	if [ -d ./squashfs-root/ ] 
	then
		echo "Removing existing ~/squashfs-root/"
		rm -rf ./squashfs-root/
		echo ""
	fi
	
	echo "Extracting the nvim.appimage"
	./nvim.appimage --appimage-extract
	echo ""

	echo "Copying/moving the extracted appimage to root "
	sudo cp -fr ./squashfs-root / 2> /dev/null
	if [ $? -eq 1 ]
	then
		sudo mv ./squashfs-root /
	fi
	echo ""

	if [ -d /usr/bin/nvim ] 
	then
		echo "Removing existing symlink /usr/bin/nvim"
		sudo rm -rf /usr/bin/nvim
		echo ""
	fi

	if [ ! -L /usr/bin/nvim ]
	then
		echo "Making new symlink /usr/bin/nvim"
		sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
		echo ""
	fi
	echo ""
	echo ""
	echo ""
	nvim --version


fi
