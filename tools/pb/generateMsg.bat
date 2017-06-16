@echo off

echo "delete all *.pb Files"
del /F *.pb.*

echo "generate .pb File By .proto"
protoc.exe test.proto -o test.pb
 

echo "copy client .pb File to bin/pb"
copy /Y ".\test.pb"   			"../../work/pb/"

pause
