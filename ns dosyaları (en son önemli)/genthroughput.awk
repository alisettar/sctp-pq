BEGIN {
       recvdSize = 0
       startTime = 0
       stopTime = 0
  }
   
  {
             event = $1
             time = $3
             send_node_id = $5
             recv_node_id = $7
             pkt_size = $11
	     pkt_type = $9
   
  # Store start time
  if (event == "s" && pkt_size >= 12) {
    if (time > startTime) {
             startTime = time
             }
       }
   
  # Update total received packets' size and store packets arrival time
  if (pkt_type == "sctp" && event == "r" && send_node_id == 0 && recv_node_id == 1) {
       if (time > stopTime) {
             stopTime = time
             }
       # Rip off the header
       hdr_size = pkt_size % 48
       pkt_size -= hdr_size
       # Store received packet's size
       recvdSize += pkt_size
       }
  }
   
  END {
       throughput = (recvdSize/(stopTime-startTime))*(8/1000)

       printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",throughput,startTime,stopTime)
  }
