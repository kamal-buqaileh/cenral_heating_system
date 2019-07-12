#!/bin/bash

set -e # Exit on errors

if [ -n "$TMUX" ]; then
  export NESTED_TMUX=1
  export TMUX=''
fi

if [ ! $APP_DIR ]; then export APP_DIR=$HOME/workspace/central_heating_system; fi

cd $APP_DIR

tmux new-session  -d -s App
tmux set-environment -t App -g APP_DIR $APP_DIR

tmux new-window      -t App  -n 'Web'
tmux send-key        -t App  'cd $APP_DIR'                               Enter 'rails s'                                   Enter

tmux new-window      -t App -n 'Console'
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'rails c'                                   Enter

tmux new-window      -t App -n 'Database'
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'psql central_heating_system'               Enter

tmux new-window      -t App -n 'Redis'
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'redis-server'                              Enter
tmux split-window    -t App
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'redis-cli'                                 Enter

tmux new-window      -t App -n 'Sidekiq'
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'bundle exec sidekiq -C config/sidekiq.yml' Enter
tmux split-window    -t App
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'tail -f ./log/sidekiq.log'                 Enter

tmux new-window      -t App -n 'Elastic'
tmux send-key        -t App 'cd $APP_DIR/vendor/elasticsearch-6.2.2/bin' Enter './elasticsearch'                           Enter

tmux new-window      -t App -n 'vim'
tmux send-key        -t App 'cd $APP_DIR'                                Enter 'vim .'                                     Enter

if [ -z "$NESTED_TMUX" ]; then
  tmux -2 attach-session -t App
else
  tmux -2 switch-client -t App
fi
