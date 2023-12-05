#!/bin/bash
sed -i "s/^\( *source *= *\"git\@github.com:.*\.git\)[?]ref=.*$/\1\"/" hpcc/hpcc.tf
sed -i "s/^\( *source *= *\"git\@github.com:.*\.git\)[?]ref=.*$/\1\"/" aks/aks.tf
sed -i "s/^\( *source *= *\"git\@github.com:.*\.git\)[?]ref=.*$/\1\"/" storage/main.tf
sed -i "s/^\( *source *= *\"\)git\@\(github.com\):/\1git::https:\/\/\2\//" hpcc/hpcc.tf
sed -i "s/^\( *source *= *\"\)git\@\(github.com\):/\1git::https:\/\/\2\//" aks/aks.tf
sed -i "s/^\( *source *= *\"\)git\@\(github.com\):/\1git::https:\/\/\2\//" storage/main.tf
