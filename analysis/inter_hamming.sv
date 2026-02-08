`timescale 1ns/1ps

module inter_hamming();
	
	initial begin
		$dumpfile("inter_hamming.vcd");
		$dumpvars(0, inter_hamming);
	end

	initial begin
		$display("Calculating Inter-Board Hamming Distances");
	end
	
	task ham;
		input [127:0] hash1;
		input [127:0] hash2;
		
		int i;
		int cnt;
		shortreal hamming_distance;
		logic [127:0] distance;
		assign distance = hash1 ^ hash2;

		for(i = 0; i < 128; i++) begin
			if(distance[i] == 1'b1)
				cnt++;
		end 
		
		hamming_distance = ($itor(cnt) / 128) * 100;
		$display("the hamming distance of 128'h%h", hash1);
		$display("and of 128'h%h is %d", hash2, hamming_distance);
	endtask

	always begin
		int i;
		$display("calculating the hamming distances of b0_p1 and b1_p1");
		for(i = 0; i < 4; i++) begin
			ham(b0_p1, b1_p1);
		end
			
	end


endmodule
