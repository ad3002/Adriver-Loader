#!/bin/bash

find src -type f -name "*.as" | xargs -Ivar dos2unix -c mac var

