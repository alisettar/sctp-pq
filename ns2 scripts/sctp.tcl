

	 Trace set show_sctphdr_ 1 
	 # this needs to be set for tracing SCTP packets;

	 set ns [new Simulator]
 	 set nf [open out.nam w]
	 $ns namtrace-all $nf
	 set allchan [open all.tr w]
	 $ns trace-all $allchan

	 proc finish {} {
	    	global ns nf
		$ns flush-trace
		close $nf
		exec nam out.nam &
		exit 0
	 }

	 set n0 [$ns node]
	 set n1 [$ns node]
	 $ns duplex-link $n0 $n1 10MB 10ms DropTail

	 # NOTE: The debug files (in this example, they would be debug.SctpAgent.0
	 #       and debug.SctpAgent.1) contain a lot of useful info. They can be 
	 #       used to trace every packet sent, received, and processed.
	 #
	 set sctp0 [new Agent/SCTP]
	 $ns attach-agent $n0 $sctp0
	 $sctp0 set debugMask_ 0x00303000 # refer to sctpDebug.h for mask mappings;
	 $sctp0 set debugFileIndex_ 0

	 #set err [new ErrorModel/List]
	 #$err set rate_ 0.01
	 #$err droplist {15}
	 #$err ranvar [new RandomVariable/Uniform]
	 #$ns lossmodel $err $n0 $n1

	 set trace_ch [open trace.sctp w]
	 $sctp0 set trace_all_ 0 # do not trace all variables on one line;
	 $sctp0 trace cwnd_      # trace cwnd for all destinations;
	 $sctp0 attach $trace_ch

	 set sctp1 [new Agent/SCTP]
	 $ns attach-agent $n1 $sctp1
	 $sctp1 set debugMask_ -1         # use -1 to turn on all debugging;
	 $sctp1 set debugFileIndex_ 1
	 #$sctp1 set recvAppLayerDelay_ 0.025

	 $ns connect $sctp0 $sctp1

	 #set ftp0 [new Application/FTP]
	 #$ftp0 attach-agent $sctp0
	 set cbr0 [new Application/Traffic/CBR]
	 $cbr0 set packetSize_ 1310
	 $cbr0 set rate_ 9Mb
	 $cbr0 attach-agent $sctp0

	 $ns at 0.0 "$cbr0 start"
	 $ns at 60.0 "$cbr0 stop"
	 $ns at 60.0 "finish"

	 $ns run
