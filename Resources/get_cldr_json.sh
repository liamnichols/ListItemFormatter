# MIT License
#
# Copyright (c) 2019 Liam Nichols
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/bash

# Fetches the latest copy of CLDR json and extracts relevant files for processing
#
# Run:
#
# ➜  Resources ./get_cldr_json.sh cldr_json

if [ -z "$1" ]
  then
    echo "You must supply the output directory as the first argument"
    exit 1
fi

mkdir -pv $1

OUT_PATH=`cd "$1"; pwd`
TDIR=`mktemp -d`
trap "{ rm -rf $TDIR; exit 255; }" SIGINT

# Clone the repos into the directory
cd $TDIR
git clone git@github.com:unicode-cldr/cldr-core.git
git clone git@github.com:unicode-cldr/cldr-misc-full.git

# Copy the relevant files
cp "$TDIR/cldr-core/supplemental/parentLocales.json" "$OUT_PATH/parentLocales.json"
cd "$TDIR/cldr-misc-full/main"
mkdir -pv "$OUT_PATH/listPatterns"

for d in * ; do
  cp "$d/listPatterns.json" "$OUT_PATH/listPatterns/$d.json"
done

rm -rf $TDIR
exit 0
