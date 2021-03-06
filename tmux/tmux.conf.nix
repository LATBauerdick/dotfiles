unbind-key C-b
set-option -g prefix C-a
bind-key C-a send-prefix
source /nix/store/97bra3g1a2pm03sfma98bh2w59kfx2if-python-2.7.15-env/lib/python2.7/site-packages/powerline/bindings/tmux/powerline.conf
# Add truecolor support
set-option -ga terminal-overrides ",xterm-256color:Tc"
# Default terminal is 256 colors
set -g default-terminal "screen-256color"

bind-key -n M-a last-pane
bind-key -n M-Tab next-window
bind-key -n M-n next-window
bind-key -n M-p previous-window

bind-key Up    select-pane -U
bind-key Down  select-pane -D
bind-key Left  select-pane -L
bind-key Right select-pane -R

bind-key < resize-pane -L 5
bind-key > resize-pane -R 5
bind-key + resize-pane -U 5
bind-key - resize-pane -D 5
bind-key = select-layout even-vertical
bind-key | select-layout even-horizontal

# enable vi keys
setw -g mode-keys vi
bind-key Escape copy-mode
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-selection
unbind-key p
bind-key p paste-buffer

set -g base-index 1

set -g history-limit 30000
bind-key R source-file ~/.tmux.conf \; display-message "source-file done"

set -g mouse on

# set -g default-command "reattach-to-user-namespace -l /bin/zsh"
