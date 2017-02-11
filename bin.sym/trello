#!/bin/bash

# make sure we pass 2 argvs
if [ $# -ne 2 ]
then
	echo "Usage is: $0: <listName> \"<Title of Card>\"";
    exit 1
fi

case "$1" in
    'TODO')
        listId='5898ecb5800890ec6691c066';;
    *)
        echo 'Sorry, you didnt provide the listId for: '"$1";
        exit 0;;
esac

# replace spaces in name with '+'
name=$2
safe_name=$(echo "$name" | tr ' ' '+'|sed s/\&/%26/g)

key='4f6fb649bf838b639fcff2a1131c4636'

# this script requires an exported variable for the auth token, e.g export trello_token='abc123'
token=$trello_token

# make sure we have a token env variable
if [[ ! -n $token ]]
then
    echo 'Sorry, no trello_token variable exported, please export a trello token via export trello_token="abc123"';
    exit 0;
fi

data='name='$safe_name'&due=null&idList='$listId'&token='$token'&key='$key

curl -s -o /dev/null -w "%{http_code}\\n" --data "$data" https://api.trello.com/1/cards
