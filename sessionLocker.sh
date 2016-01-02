#!/bin/bash
##################################################
# AUTHOR: Serg Kolo 
# Date: Jan 2nd 2016
# Description: A script that locks session every x
# 		minutes. 
# TESTED ON: 14.04.3 LTS, Trusty Tahr
# WRITTEN FOR: http://askubuntu.com/q/715721/295286
# Depends: qbus, dbus, Unity desktop
###################################################

# Copyright (c) 2016 Serg Kolo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


##############
# INTRODUCTION
##############

# This script locks user session every x minutes, and repeats this task
# upon user re-logging in. Useful for creating session for children, study session
# for college students, pomodoro sessions for self-learners ,etc.
#
# This can be started manually or as part of Startup Applications 

###########
# VARIABLES
###########
TIME="30m"

##########
# MAIN
##########
while [ 1 ]; 
do
  # Wait the time defined in VARIABLES part and lock the session
  /bin/sleep $TIME &&  qdbus  com.canonical.Unity /com/canonical/Unity/Session com.canonical.Unity.Session.Lock

  # Continuously query dbus every 0.25 seconds test whether session is locked
  # Once this sub-loop breaks, the main one can resume the wait and lock cycle.
  while [ $(qdbus  com.canonical.Unity /com/canonical/Unity/Session com.canonical.Unity.Session.IsLocked) == "true" ];
  do
    /bin/sleep 0.25 && continue
  done
done
