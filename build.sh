#!/bin/bash

mkdir -p derived
xcodebuild -scheme cml -configuration Release -derivedDataPath ./derived build
