#!/bin/bash

if [[ -f scripts/before_train.sh ]]
then
    scripts/before_train.sh
fi

python train.py $@
