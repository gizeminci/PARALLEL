# HALF OF THE BOX LENGTH MUST BE LARGER THAN THE PARTICLE NUMBER for small test cases
require_feature "COLLISION_DETECTION"
require_feature "VIRTUAL_SITES_RELATIVE"
#require_max_nodes_per_side {1 1 1}

set particle 2
cellsystem domain_decomposition -no_verlet_list
set box_length 10
setmd box_l $box_length $box_length $box_length
#set pidlist [list]
set fl [open test2.vtf a]
#set filei 0

part 0 pos 5 5 5 type 0 
part 1 pos 5.85 5 5 type 0 

writevsf $fl

#--------------------------------------------------------------------------#
# PART-2---> DEFINE THE MODELS AND CONSTANTS OF EQUATIONS
#--------------------------------------------------------------------------#
setmd time_step 0.01
setmd skin 1
#------------------LANGEVIN THERMOSTAT--------------------#
set temp 1.0
set gamma 1.0
thermostat off
#---------------lENNARD JONES POTENTIAL-------------------#
set eps 1.0
set sigma 1.0
set rcut 0.7

inter 0 0 lennard-jones $eps $sigma $rcut auto
#---------------BONDED POTENTIALS-------------------#
inter 1 angle 300 [PI]
inter 0 harmonic 300 1.0
#---------------BOUNDARY_CONDITIONS-----------------------#
#...Periodic boundary cond. Later, this may be changed....#
setmd periodic 1 1 1
#------------------COLLISION------------------------------#
on_collision bind_at_point_of_collision 1.0 0 1 1
#--------------------PARTICLE CONTROL----------------------#
for {set i 0} {$i <$particle} {incr i} {
    lappend pidlist $i
    vtfpid $i
}
#---------------PARTICLE MOTION---------------------------#

set n_cycle 2000
set n_steps 1

#set file [open "test.txt" "a"]
set i 0

while { $i<$n_cycle } {   
     integrate $n_steps

puts "time step is $i BONDS OF PARTICLES: 0--> [part 0 print bonds] -- 1 -->[part 1 print bonds]"

    writevcf $fl pids $pidlist

#    set toteng [analyze energy total]

#    puts $file "[setmd time]     $toteng"

incr i
    # CLOSE MAIN LOOP
}

exit

