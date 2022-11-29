FROM ubuntu:18.04

# Kakao mirror 서버 연결
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
RUN apt -y update
RUN apt -y install sudo

# personal setting
RUN useradd -u 1000 -m user
RUN echo 'user  ALL=(ALL:ALL) ALL' >> /etc/sudoers
RUN echo 'user ALL=NOPASSWD: ALL' >> /etc/sudoers
USER user

# set time zone
ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt -y install tzdata
RUN sudo rm /etc/localtime
RUN sudo ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# install zsh
RUN sudo apt -y install git wget zsh fonts-powerline language-pack-en
#   oh-my-zsh install 
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
RUN sudo chsh -s /usr/bin/zsh 
#   install plugins
ENV ZSH_CUSTOM $HOME/.oh-my-zsh/custom
RUN sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
RUN sudo git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
#   .zshrc file edit
RUN echo 'export LANG=en_US.UTF-8 ZSH="$HOME/.oh-my-zsh" ZSH_THEME="agnoster" plugins=(git zsh-syntax-highlighting zsh-autosuggestions)\nsource $ZSH/oh-my-zsh.sh\nprompt_context() {\n  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then\n    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"\n  fi\n}' > ~/.zshrc
CMD ["zsh"]

# install ros
RUN sudo apt -y install gnupg
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list'
RUN wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -O - | sudo apt-key add -
RUN sudo apt update
RUN sudo apt -y install ros-melodic-desktop-full
RUN echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc
RUN /bin/zsh -c "source ~/.zshrc"
RUN sudo apt -y install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo rosdep init
RUN rosdep update

# install vulkan
RUN sudo apt -y install mesa-vulkan-drivers
RUN wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
RUN sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-1.2.189-bionic.list https://packages.lunarg.com/vulkan/1.2.189/lunarg-vulkan-1.2.189-bionic.list
RUN sudo apt update
RUN sudo apt -y install vulkan-sdk
RUN sudo apt -y install libxi-dev libglfw3-dev libglm-dev

# install opencv

# hardware accelation for intel gpu
RUN sudo apt -y install libgl1-mesa-glx libgl1-mesa-dri
RUN sudo rm -rf /var/lib/apt/lists/*
# for gpu access
RUN sudo gpasswd -a user avahi
USER user

RUN sudo apt -y update
RUN sudo apt -y upgrade