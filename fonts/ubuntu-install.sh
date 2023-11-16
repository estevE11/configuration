wget https://github.com/intel/intel-one-mono/releases/download/V1.2.1/ttf.zip
unzip ttf.zip

cd ttf
mkdir ~/.fonts
mv *.ttf ~/.fonts

cd ..
rm -r ttf
rm ttf.zip
