#!/bin/bash

etcd_key_list() {
	curl -s ${PENV_ETCD_HOST}${PENV_ETCD_KEY_PREFIX}?keys | jq -r '.node.nodes | .[] | .key'
}

etcd_get_key() {
	local KEY=$1
	curl -s ${PENV_ETCD_HOST}${KEY} | jq -r '.node.key' | rev | cut -d/ -f1 | rev
}

etcd_get_value() {
	local KEY=$1
	curl -s ${PENV_ETCD_HOST}${KEY} | jq -r '.node.value'
}

COMMANDS="$@"

if [ -f "$(dirname $0)/penvrc" ]; then
	source "$(dirname $0)/penvrc"
fi

if [ "$PENV_DRIVER" != etcd ]; then
	echo "Only etcd is support at the moment"
	exit 1
fi

key_list() { "${PENV_DRIVER}_key_list" $@; }
get_key() { "${PENV_DRIVER}_get_key" $@; }
get_value() { "${PENV_DRIVER}_get_value" $@; }

KEY_LIST=`key_list`

for KEY in $KEY_LIST; do
	KEYNAME=`get_key $KEY`
	VALUE=`get_value $KEY`
	export "${KEYNAME}=${VALUE}"
done

eval "$COMMANDS"
