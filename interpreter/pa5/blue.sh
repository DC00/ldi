#!/bin/bash
rm testcases/logs/*.cl-type
rm testcases/logs/*.log
echo "Running all tests.."

for file in testcases/*.cl ; do
	./make.sh $file > testcases/logs/${file#*/}.log
done

echo "Running reference interpreter"

for file in testcases/*.cl ; do
	echo $file
	cool $file > testcases/logs/${file#*/}.output
done

