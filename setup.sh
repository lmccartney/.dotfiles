mkdir -p ${HOME}/.vim/colors/
mkdir -p ${HOME}/.gitrepos/
mkdir -p ${HOME}/.dotbackups

mv ${HOME}/.vimrc ${HOME}/.dotbackups/
cp ${HOME}/.bashrc ${HOME}/.dotbackups/
cp ${HOME}/.gitrepos/.dotfiles/.vimrc ${HOME}/
cp ${HOME}/.gitrepos/.dotfiles/.tmux.conf ${HOME}/

# start badwolf setup
if [ ! -d "${HOME}/.gitrepos/badwolf" ]; then
	git clone git@github.com:sjl/badwolf.git ${HOME}/.gitrepos/badwolf/
else
	cd ${HOME}/.gitrepos/badwolf/
	git pull &> /dev/null
fi

if [ ! -f "${HOME}/.vim/colors/badwolf.vim" ]; then
	ln -s ${HOME}/.gitrepos/badwolf/colors/badwolf.vim ${HOME}/.vim/colors/badwolf.vim
fi

if [ ! -z $( grep -Fxq "export TERM=xterm-256color" ${HOME}/.bashrc ) ]; then
	echo "if [ \"\$\{COLORTERM\} == \"gnome-terminal\" ]\; then" >> ${HOME}/.bashrc
	echo "	export TERM=xterm-256color" >> ${HOME}/.bashrc
	echo "fi" >> ${HOME}/.bashrc
fi
# end badwolf setup

# start syntastic setup
if [ ! -d "${HOME}/.gitrepos/vim-syntastic" ]; then
	git clone git@github.com:vim-syntastic/syntastic.git ${HOME}/.gitrepos/vim-syntastic/
else
	cd ${HOME}/.gitrepos/vim-syntastic/
	git pull &> /dev/null
fi

cp -rf ${HOME}/.gitrepos/vim-syntastic/autoload ${HOME}/.vim/
cp -rf ${HOME}/.gitrepos/vim-syntastic/doc ${HOME}/.vim/
cp -rf ${HOME}/.gitrepos/vim-syntastic/plugin ${HOME}/.vim/
cp -rf ${HOME}/.gitrepos/vim-syntastic/syntax_checkers ${HOME}/.vim/

# start pyenv setup
if [ ! -d "${HOME}/.pyenv" ]; then
	curl https://pyenv.run | bash
	if [ ! -z $( grep -Fxq "export PATH=\"${HOME}/.pyenv/bin:\$PATH" ${HOME}/.bashrc ) ];  then
		echo "export PATH=${HOME}/.pyenv/bin:\$PATH" >> ${HOME}/.bashrc
		echo "eval \"\$(pyenv init -)\"" >> ${HOME}/.bashrc
		echo "eval \"\$(pyenv virtualenv-init -)\"" >> ${HOME}/.bashrc
		source ${HOME}/.bashrc
	fi
	pyenv install 3.6.8
	pyenv install 3.7.3
fi
# end pyenv setup
