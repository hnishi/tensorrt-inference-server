#!/bin/bash
# Copyright (c) 2018-2019, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

TEST_LOG="./docs.log"

rm -f $TEST_LOG
RET=0

apt-get update && \
    apt-get install -y --no-install-recommends python3-pip zip doxygen && \
    pip3 install --upgrade setuptools && \
    pip3 install --upgrade sphinx sphinx-rtd-theme nbsphinx exhale && \
    pip3 install --upgrade ../pkgs/tensorrtserver*.whl

set +e

(cd src/clients/c++/library &&
    cp -f request.h.in request.h
    cp -f request_grpc.h.in request_grpc.h
    cp -f request_http.h.in request_http.h)

# Set visitor script to be included on every HTML page
mkdir docs/_static && cp visitor_script docs/_static/.
export VISITS_COUNTING_SCRIPT=visitor_script

(cd docs && rm -f trtis_docs.zip && \
        make BUILDDIR=/opt/tensorrtserver/qa/L0_docs/build clean html) > $TEST_LOG 2>&1
if [ $? -ne 0 ]; then
    RET=1
fi

(cd build && zip -r ../trtis_docs.zip html)
if [ $? -ne 0 ]; then
    RET=1
fi

set -e

if [ $RET -eq 0 ]; then
    echo -e "\n***\n*** Test Passed\n***"
else
    cat $TEST_LOG
    echo -e "\n***\n*** Test FAILED\n***"
fi

exit $RET
