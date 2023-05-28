set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf
	 set allchan [open all.tr w]
	 $ns trace-all $allchan
$ns color 1 Blue
$ns color 2 Red

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

for {set i 1} {$i < 8} {incr i} {
	set s($i) [$ns node]
}

for {set i 1} {$i < 8} {incr i} {
	set r($i) [$ns node]
}

for {set i 1} {$i < 3} {incr i} {
	set n($i) [$ns node]
}

#link tanımlama
$ns duplex-link $s(1) $n(1) 50Mb 10ms DropTail
$ns duplex-link $n(2) $r(1) 50Mb 10ms DropTail

for {set i 2} {$i < 8} {incr i} {
	$ns duplex-link $s($i) $n(1) 50Mb 10ms DropTail
}

for {set i 2} {$i < 8} {incr i} {
	$ns duplex-link $r($i) $n(2) 50Mb 10ms DropTail
}

$ns duplex-link $n(1) $n(2) 20Mb 10ms DropTail
#link tanımlama son

for {set i 1} {$i < 15} {incr i} {
	set sctp($i) [new Agent/SCTP]
	$sctp($i) set debugMask_ 0x00303000
	$sctp($i) set debugFileIndex_ 0
	$sctp($i) set class_ 1
	#$sctp($i) set recvAppLayerDelay_ 0.005
}
$sctp(1) set class_ 2
for {set i 1} {$i < 8} {incr i} {
	$ns attach-agent $s($i) $sctp($i)
	$ns attach-agent $r($i) $sctp([expr ($i + 7)])
}

	set cbr(1) [new Application/Traffic/CBR]
	$cbr(1) set packetSize_ 1310
	$cbr(1) set rate_ 9Mb	
	#$cbr(1) set interval_ 0.01
	$cbr(1) attach-agent $sctp(1)

for {set i 2} {$i < 8} {incr i} {
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) set packetSize_ 1310
	$cbr($i) set type_ CBR
	$cbr($i) set rate_ .5Mb
	$cbr($i) attach-agent $sctp($i)
}

for {set i 1} {$i < 8} {incr i} {
	$ns connect $sctp($i) $sctp([expr ($i + 7)])
}

for {set i 1} {$i < 8} {incr i} {
	$ns at 0.0 "$cbr($i) start"
	$ns at 60.0 "$cbr($i) stop"
}
$ns at 60.0 "finish"
$ns run
