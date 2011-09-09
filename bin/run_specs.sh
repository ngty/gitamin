#!/bin/bash

BIN_DIR=`dirname $0`
BIN_DIR=`cd $BIN_DIR && pwd`
APP_DIR=`cd ${BIN_DIR}/.. && pwd`

PHANTOMJS_DIR=${BIN_DIR}/phantomjs.git
PHANTOMJS_GIT=https://github.com/ariya/phantomjs.git
PHANTOMJS_VER='1.2'
PHANTOMJS_BIN=${BIN_DIR}/phantomjs.git/bin/phantomjs

JASMIN_DIR=${BIN_DIR}/jasmine.git
JASMIN_GIT=https://github.com/pivotal/jasmine.git
JASMIN_VER=6b5956724b7e64325c6465bc426bd924d6f2aefe

# ///////////////////////////////////////////////////////////////
# Initalize phantomjs
# ///////////////////////////////////////////////////////////////
if [[ ! -f $PHANTOMJS_BIN ]]; then
  echo "= Missing ${PHANTOMJS_BIN}, building it ... "

  cd $BIN_DIR && \
    git clone $PHANTOMJS_GIT $PHANTOMJS_DIR && \
    cd $PHANTOMJS_DIR && \
    git checkout $PHANTOMJS_VER && \
    qmake && \
    make

  if [[ -f $PHANTOMJS_BIN ]]; then
    echo ">> success."
  else
    echo ">> failure."
    echo ">> Pls see build instructions at:"
    echo ">> http://code.google.com/p/phantomjs/wiki/BuildInstructions"
    exit 1
  fi
fi

# ///////////////////////////////////////////////////////////////
# Initalize jasmine
# ///////////////////////////////////////////////////////////////
if [[ ! -d $JASMIN_DIR ]]; then
  echo "= Missing ${JASMIN_DIR}, cloning it ... "

  cd $BIN_DIR && \
    git clone $JASMIN_GIT $JASMIN_DIR && \
    cd $JASMIN_DIR && \
    git checkout $JASMIN_VER

  if [[ -d $JASMIN_DIR ]]; then
    echo ">> success."
  else
    echo ">> failure."
    exit 1
  fi
fi

# ///////////////////////////////////////////////////////////////
# Run test suite
# ///////////////////////////////////////////////////////////////
if [[ $# == 0 ]]; then
  echo "USAGE: ${0} URL"
else
  cd ${APP_DIR} && \
    $PHANTOMJS_BIN ${BIN_DIR}/run_jasmine.coffee $@
fi

# __END__
