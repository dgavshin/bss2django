#!/bin/bash

SCRIPT_DIR=$(dirname $0)
BSS_DIR=$1

function load_venv()
{
    local env_file=$SCRIPT_DIR/env
    # shellcheck source=$SCRIPT_DIR/env
    source "$env_file"

    if [ -n "$VIRTUAL_ENV" ]
    then
        #Activate virtual env
        # shellcheck source=$SCRIPT_DIR/$VIRTUAL_ENV/bin/activate
        source "$SCRIPT_DIR/$VIRTUAL_ENV/bin/activate"
    fi
}

function move_bootstrap_assets() {
  BSS_DIR=$1
  cd "$BSS_DIR" || exit

  ASSETS=(css img js)
  for asset in "${ASSETS[@]}"; do
    if [ -d "assets/bootstrap/$asset" ]
    then
      for app in "${DJANGO_APPS[@]}"; do
        for file in assets/bootstrap/"$asset"/*.*; do
          echo "Mooving $file to assets/$asset/$app"

          mv "$file" "assets/$asset/$app"
          rmdir "assets/bootstrap/$asset"
          rmdir "assets/bootstrap"

          filename=$(basename "$file")
          sed -i "s|assets/bootstrap/$asset/$filename|assets/$asset/$app/$filename|g" "$app"/*.html
        done
      done
    fi
  done
}

function move_internal_js_files() {
    BSS_DIR=$1
    cd "$BSS_DIR" || exit

    for app in "${DJANGO_APPS[@]}"; do
        for file in assets/js/*.js; do
            echo "Mooving $file to assets/js/$app"
            mv "$file" "assets/js/$app"
            filename=$(basename "$file")
            sed -i "s|assets/js/$filename|assets/js/$app/$filename|g" "$app"/*.html
        done
    done
}



#Load virtual env if necessary

load_venv

move_bootstrap_assets "$1"
move_internal_js_files "$1"

cd "$1" || exit
DJANGO_PROJECT=$DJANGO_PROJECT python3 "$SCRIPT_DIR/converter.py" "$1"
