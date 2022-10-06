#!/bin/sh

#  ci_post_clone.sh
#  SeeMeet
#
#  Created by 김인환 on 2022/08/14.
#  
# Install CocoaPods using Homebrew.
brew install cocoapods
        
# Install dependencies you manage with CocoaPods.
pod install
