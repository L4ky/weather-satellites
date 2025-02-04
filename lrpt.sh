# Working... to be finished and tested again
# implemented oqpsk from meteor_demod

####################
source config.cfg
####################

file=$1
echo -e "\n\033[1m$file\033[0m"

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

# Normalise:
#sox ${file}.wav ${file}_norm.wav channels 1 gain -n
sox ${file}.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
if [[ ${file: -2} == "M2" ]]; then
    yes | $demod -B -m qpsk  -o ${file}.qpsk ${file}_norm.wav    
else
    yes | $demod -B -m oqpsk -o ${file}.qpsk ${file}_norm.wav
fi
touch -r ${file}.wav ${file}.qpsk

# Decode:
if [[ ${file: -2} == "M2" ]]; then
    $decoder ${file}.qpsk ${file} -cd -q
else
    $decoder ${file}.qpsk ${file} -int -cd -q
fi
touch -r ${file}.wav ${file}.dec

# Create image:
# only composite
$decoder ${file}.dec ${file} -r 65 -g 65 -b 64 -d -q
# three channels
# $decoder ${file}.dec ${file} -S -r 65 -g 65 -b 64 -d -q

if [[ -f "${file}.bmp" ]]; then
  convert ${file}.bmp ${file}.png
  rm -f ${file}.bmp
  touch -r ${file}.wav ${file}.png
  echo -e "\nImage created!"
fi

rm -f ${file}_norm.wav
#rm -f ${file}.qpsk
#rm -f ${file}.dec
