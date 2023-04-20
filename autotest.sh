#!/usr/bin/bash
ls source/dlox/* | entr -r dub test -- -debug
