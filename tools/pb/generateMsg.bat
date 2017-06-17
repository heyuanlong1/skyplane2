@echo off

echo "delete all *.pb Files"
del /F *.pb.*

echo "generate .pb File By .proto"
protoc.exe msg.proto -o msg.pb
 

echo "copy client .pb File to bin/pb"
copy /Y ".\msg.pb"   			"../../work/workcommon/pb/"

pause
