
FROM alpine

# Enable HTTPS support in wget.
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && apk add --no-cache --update openssl curl bash sudo zsh shadow

RUN adduser -D -g '' -h /home/bauerdic -s /bin/zsh -u 6170 -G adm bauerdic
RUN usermod -p "$(openssl passwd -1 nixnix)" bauerdic
RUN apk add sudo
RUN echo "bauerdic ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER bauerdic
WORKDIR /home/bauerdic

# Download Nix and install it into the system.
ENV USER=bauerdic
RUN sudo apk add curl
RUN wget https://nixos.org/releases/nix/nix-2.2.1/nix-2.2.1-x86_64-linux.tar.bz2 \
  && echo "e229e28f250cad684c278c9007b07a24eb4ead239280c237ed2245871eca79e0  nix-2.2.1-x86_64-linux.tar.bz2" | sha256sum -c \
  && tar xjf nix-*-x86_64-linux.tar.bz2 \
  && sudo mkdir -m 0755 /etc/nix \
  && sudo echo 'sandbox = false' > nix.conf && sudo mv nix.conf /etc/nix \
  && sudo mkdir -m 0755 /nix && sudo chown bauerdic /nix && USER=bauerdic sh nix-*-x86_64-linux/install --no-daemon \
  && sudo ln -s /nix/var/nix/profiles/default/etc/profile.d/nix.sh /etc/profile.d/ \
  && sudo rm -r nix-*-x86_64-linux*


# RUN sudo rm -rf /var/cache/apk/* \
#   && /home/bauerdic/.nix-profile/bin/nix-collect-garbage --delete-old \
#   && /home/bauerdic/.nix-profile/bin/nix-store --optimise \
#   && /home/bauerdic/.nix-profile/bin/nix-store --verify --check-contents

RUN echo ". /home/bauerdic/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc

ENV \
    PATH=/home/bauerdic/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    NIX_PATH=/home/bauerdic/.nix-defexpr/channels

# RUN nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"
# RUN sudo `which nixos-generate-config` --root /

####users.users.root.initialHashedPassword = "";

# RUN nix-env -p /nix/var/nix/profiles/system -f '<nixpkgs/nixos>' -I nixos-config=/etc/nixos/configuration.nix -iA system

RUN nix-shell -p nix-info --run "nix-info -m"

ENV TERM screen-256color
RUN nix-env -i glibc-locales
ENV LANG   en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN bash -c 'echo export LOCALE_ARCHIVE="$(nix-env --installed --no-name --out-path --query glibc-locales)/lib/locale/locale-archive" >> zshrc'
RUN sudo mv zshrc /etc/zshrc

RUN mkdir ~/.ssh && curl -fsL https://github.com/latbauerdick.keys > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

RUN nix-env -i git

RUN git clone --recursive https://github.com/latbauerdick/dotfiles .dotfiles \
    && ln -sf ~/.dotfiles/vim/init.vim ~/.vimrc         \
    && mkdir -p ~/.config                               \
    && ln -sf ~/.dotfiles/vim ~/.config/nvim            \
    && ln -sf $(pwd)/.dotfiles/zsh/zshrc ~/.zshrc                 \
    && ln -sf $(pwd)/.dotfiles/tmux/tmux.conf.ubuntu ~/.tmux.conf \
    && ln -sf $(pwd)/.dotfiles/git/gitconfig ~/.gitconfig         \
    && ln -sf $(pwd)/.dotfiles/ssh/sshconfig ~/.ssh/config        \
    && ln -sf $(pwd)/.dotfiles/nixpkgs ~/.config/
####    && nix-env -iA myPackages -f '<nixpkgs>'

##ln -s $(pwd)/agignore ~/.agignore
##ln -s $(pwd)/tigrc ~/.tigrc
##ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh

RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
RUN git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k


RUN echo -e "with import <nixpkgs> {};\npython.withPackages (ps: with ps; [ powerline ])" > build.nix
RUN nix-env -f build.nix -i && python -c 'import powerline; print (powerline.__file__)'

EXPOSE 3222 60000-60010/udp
CMD zsh

