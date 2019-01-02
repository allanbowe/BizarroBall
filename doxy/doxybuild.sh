#!/bin/bash
####################################################################
# PROJECT: Bizarro Ball Docs Build                                 #
####################################################################

BUILD_FOLDER="/tmp/bizarro_docs"

# move to project root
cd ..

# create build directory
rm -rf $BUILD_FOLDER
mkdir $BUILD_FOLDER

# copy relevant files
cp -r Macros $BUILD_FOLDER 
cp -r Programs $BUILD_FOLDER 
cp -r doxy $BUILD_FOLDER 
cp README.md $BUILD_FOLDER
cp bizarroball.sas $BUILD_FOLDER

# update Doxyfile and generate
cd $BUILD_FOLDER
cp doxy/Doxyfile ./Doxyfile
echo "OUTPUT_DIRECTORY=$BUILD_FOLDER/out" >> ./Doxyfile
#echo "INPUT+=main.dox" >> ./Doxyfile
doxygen Doxyfile

# refresh github pages site
git clone git@github.com:allanbowe/bizarro.github.io.git
cd bizarro.github.io
git rm -r *
mv $BUILD_FOLDER/out/doxy/* .
echo " " >> .nojekyll
git add .nojekyll
git add *
git commit -m "build.sh build on $(date +%F:%H:%M:%S)"
git push

