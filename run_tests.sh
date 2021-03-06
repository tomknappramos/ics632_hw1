#!/bin/bash

echo "running tests..."

# setup vars
str="time_val"
n=9500			# array size
k_start=50		# tile size start
k_end=300		# tile size end
k_inc=100		# tile increment amount
epochs=3		# tests per tile size

# clear any possible previous results
> normal_time_results.txt
> tile_time_results.txt
> normal_l1_results.txt
> tile_l1_results.txt
> normal_llc_results.txt
> tile_llc_results.txt


###### time - non tiled ########

echo "time - non tiled"

# compile
icc exercise1.c -o exercise1 -O3 -D N=$n -D k=100

for ((i=0; i<epochs; i++))
do 

  # send stats to output file 
  perf stat -o perf.txt ./exercise1; 

  # parse time value from output file
  str=$(cat perf.txt | grep "seconds time elapsed" | sed  "s/ *//" | sed "s/ seconds.*//" | sed "s/,//g")
   
  # append time with trial number to time_results file
  echo -n "$str, " >> normal_time_results.txt

  # log trial number
  echo $i

done

echo ""


###### time - tiled ########

echo "time - tiled"

for ((j=k_start; j<=k_end; j+=k_inc))
do

	# compile
	icc exercise1.c -o exercise1 -O3 -D N=$n -D k=$j -D TILE_MODE

	# append tile size to time_results file
	echo -n "$j, " >> tile_time_results.txt

	# log tile size
	echo $j
	
	for ((i=0; i<epochs; i++))
	do 

	  # send stats to output file 
	  perf stat -o perf.txt ./exercise1; 

	  # parse time value from output file
	  str=$(cat perf.txt | grep "seconds time elapsed" | sed  "s/ *//" | sed "s/ seconds.*//" | sed "s/,//g")
	   
	  # append time with trial number to time_results file
	  echo -n "$str, " >> tile_time_results.txt

	  # log trial number
	  echo $i

	done

	echo "" >> tile_time_results.txt

done
	
echo ""


###### L1 cache misses - non tiled ########
echo "L1 cache misses - non tiled"

icc exercise1.c -o exercise1 -O3 -D N=$n -D k=100
for ((i=0; i<epochs; i++))
do 
  perf stat -e L1-dcache-load-misses -o perf.txt ./exercise1; 
  str=$(cat perf.txt | grep "L1" | sed "s/ *//" | sed "s/ .*L1.*//" | sed "s/,//g")
  
  echo -n "$str, " >> normal_l1_results.txt
  echo $i
  
done

echo ""


###### L1 cache misses - tiled ########
echo "L1 cache misses - tiled"

for ((j=k_start; j<=k_end; j+=k_inc))
do
	icc exercise1.c -o exercise1 -O3 -D N=$n -D k=$j -D TILE_MODE

	echo -n "$j, " >> tile_l1_results.txt
	echo $j
	
	for ((i=0; i<epochs; i++))
	do 
	  perf stat -e L1-dcache-load-misses -o perf.txt ./exercise1; 
	  str=$(cat perf.txt | grep "L1" | sed "s/ *//" | sed "s/ .*L1.*//" | sed "s/,//g")
	  echo -n "$str, " >> tile_l1_results.txt
	  echo $i
	done
	
	echo "" >> tile_l1_results.txt
	
done

echo ""


###### LLC misses - non tiled ########
echo "LLC misses - non tiled"

icc exercise1.c -o exercise1 -O3 -D N=$n -D k=100
for ((i=0; i<epochs; i++))
do 
  perf stat -e LLC-load-misses -o perf.txt ./exercise1; 
  str=$(cat perf.txt | grep "LLC" | sed "s/ *//" | sed "s/ .*LLC.*//" | sed "s/,//g")
  
  echo -n "$str, " >> normal_llc_results.txt
  echo $i
  
done

echo ""


###### LLC misses - tiled ########
echo "LLC misses - tiled"

for ((j=k_start; j<=k_end; j+=k_inc))
do
	icc exercise1.c -o exercise1 -O3 -D N=$n -D k=$j -D TILE_MODE

	echo -n "$j, " >> tile_llc_results.txt
	echo $j
	
	for ((i=0; i<epochs; i++))
	do 
	  perf stat -e LLC-load-misses -o perf.txt ./exercise1; 
	  str=$(cat perf.txt | grep "LLC" | sed "s/ *//" | sed "s/ .*LLC.*//" | sed "s/,//g")
	  echo -n "$str, " >> tile_llc_results.txt
	  echo $i
	done
	
	echo "" >> tile_llc_results.txt
	
done

echo ""


# log everything
cat normal_time_results.txt
echo ""
echo ""
cat tile_time_results.txt
echo ""
echo ""
cat normal_l1_results.txt
echo ""
echo ""
cat tile_l1_results.txt
echo ""
echo ""
cat normal_llc_results.txt
echo ""
echo ""
cat tile_llc_results.txt
echo ""
echo ""
