## test.gd
extends Node2D

func _ready():
	math_calcs()
	
## Simple test run for rescue sortie calculations using modulous.
## generates a quick array given the crew size and rv capacity.

## Each "Rescue Sorty" will be effectively the position in the array and control how long each sorty takes

## Remaining Crew calculated by taking sorty position + 1 and summing to end of array.
var rvcap = 16
var crewsz = 72
var mypartial = crewsz % rvcap
var dissubrem = 0
var res_try = 0

func math_calcs():
## Script segment to build the dissub crew status array!
	var y = crewsz
	y = y-rvcap
	var thearray = [rvcap]
	while y > mypartial:
		y = y - rvcap
		thearray.insert(thearray.size(),rvcap)
	thearray.insert(thearray.size(),mypartial)
	print(thearray)
	print(thearray.size())
	
	
	## Debugging code to test the rescue Try sortie position and sum remaining crew...
	for numtry in range(res_try,thearray.size()):
		dissubrem = arr_sum(thearray, numtry)
		dissubrem = clamp(dissubrem, 1, crewsz)
		print("test remaining is ", dissubrem)

	## Small function to quickly calc the remaining crew after a sortie...
	## with known starting position, sum values from start position to end of array and return the integer.
func arr_sum(sarray: Array, stpos: int) -> int:
	var sumstart = stpos
	var mysum = 0 
	for arrposit in range(sumstart, sarray.size()):
		mysum += sarray[arrposit]
	return mysum
	
