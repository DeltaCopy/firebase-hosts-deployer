#!/usr/bin/env bash
set -eo pipefail

WEB_DIR="$1"
TOKEN="$2"
FIREBASE_PROJECT="$3"
FIREBASE_APP="$4"

FIREBASE_VERSION=`firebase -V`
FIREBASE_CONF="firebase.json"


echo "──────────────────────────────────────────"
echo " Firebase deployment"
echo "──────────────────────────────────────────"

exec_deployment(){

    echo "✔ Preparing.."

    if [[ -z "$FIREBASE_TOKEN" ]]; then
        export FIREBASE_TOKEN="$TOKEN"
        echo "✔ Firebase token set."
    else

        echo "✔ Firebase token is set."

    fi

    cd "$WEB_DIR"

    echo "✔ Adding Firebase project."
    firebase use --add "$FIREBASE_PROJECT"
    
    echo "✔ Displaying list of apps."
    firebase apps:list

    echo "✔ Applying Firebase app hosting target."
    firebase target:apply hosting app "$FIREBASE_APP"

    echo "──────────────────────────────────────────"
    echo "Attempting deployment."
    firebase deploy -m "GitLab CI Deployment"
    echo "──────────────────────────────────────────"

    if [[ $? -eq 0 ]]; then
        echo "✔ Deployment went OK."
        exit 0
    else
        echo "Error: Deployment failed."
        exit 1
    fi
}


if [ ! -z "$FIREBASE_VERSION" ];then
    echo "✔ Firebase version = $FIREBASE_VERSION"
else
    echo "Error: Failed to get Firebase version, is Firebase installed properly?"
    exit 1
fi

if [[ ! -z "$WEB_DIR" ]] && [[ ! -z "$TOKEN" ]] && [[ ! -z "$FIREBASE_PROJECT" ]] && [[ ! -z "$FIREBASE_APP" ]];
then
    WEB_DIR=`realpath $WEB_DIR`
    echo "✔ Deployment site directory = $WEB_DIR"

    if [ -d "$WEB_DIR" ];
    then
        echo "✔ Site directory exists."
        echo "Checking for Firebase configuration file = $FIREBASE_CONF"
        if [[ -f "$WEB_DIR/$FIREBASE_CONF" ]]; then
            echo "✔ Firebase configuration file found."
            exec_deployment

        else
            echo "Error: Firebase configuration file not found."
            exit 1
        fi
    else
        echo "Error: Site directory does not exist / Firebase token / Firebase project is not valid / Firebase app is not valid."
        exit 1
    fi


else
    echo "Usage: ./firebase-ci.sh [path to site directory] [token] [project] [app]"
    exit 1
fi


