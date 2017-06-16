
echo "delete all *.pb Files"
rm -f *.pb

echo "generate .pb File By .proto"
protoc test.proto -o test.pb


echo "copy client .pb File to bin/pb"
copy ./test.pb   ../../work/pb/

