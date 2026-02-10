`timescale 1ns/1ps
`define QUOTE(q) `"`"
module calc_hamming();
	
    logic [127:0] b1_p1 [0:3];
    logic [127:0] b1_p2 [0:3];
    logic [127:0] b1_p3 [0:3];

    logic [127:0] b2_p1 [0:3];
    logic [127:0] b2_p2 [0:3];
    logic [127:0] b2_p3 [0:3];

////////////////////  BOARD 1 - PUF 1 ////////////////////////////////////
    // Response = CB
    assign b1_p1[0] = 128'h 8ACD_264C_D7AE_265E_4CBC_3A55_DAAD_A974;

    // Response = 49
    assign b1_p1[1] = 128'h 2295_E058_7E81_D3EE_271A_0506_5988_89BA;

    // Response = B4
    assign b1_p1[2] = 128'h 4E9A_633A_165D_143C_FF2C_3D00_9E4F_842A;

    // Response = 94
    assign b1_p1[3] = 128'h 1AB7_6FB3_7FBA_C82F_8BCD_3D00_7094_6749;

////////////////////  BOARD 1 - PUF 2 ////////////////////////////////////
    // Response BA
    assign b1_p2[0] = 128'h 8A6D_264C_D7AE_265E_4CBC_3A55_DAAD_A974;

    // Response 55
    assign b1_p2[1] = 128'h 2295_E058_7E81_D3EE_271A_0506_5988_89BA;

    // Response A4
    assign b1_p2[2] = 128'h 4E9A_633A_165D_143C_FF2C_3D00_9E4F_842A;

    // Response AA
    assign b1_p2[3] = 128'h 1AB7_6FB3_7FBA_C82F_8BCD_3D00_7094_6749;

////////////////////  BOARD 1 - PUF 3 ////////////////////////////////////
    // Response 2A (inconsistent)
    assign b1_p3[0] = 128'h 4EB5_AF3E_3C37_ED1E_871E_0F48_26ED_2C68;

    // Response BC (incosistent)
    assign b1_p3[1] = 128'h 2823_C705_3DE6_AC4C_9D91_9764_802A_90F8;

    // Response 55 (inconsistent)
        assign b1_p3[2] = 128'h BE44_2CCE_3E83_715E_F3E3_17E8_3CFD_1FD3;

    // Response D3 (inconsistent)
    assign b1_p3[3] = 128'h B6A7_F94F_B1D8_9F92_C92B_5cF4_5234_AA64;

////////////////////  BOARD 2 - PUF 1 ////////////////////////////////////
    // Response = CB
    assign b2_p1[0] = 128'h 8A6D_264C_D7AE_265E_4CBC_3A55_DAAD_A974; //00CB

    // Response = C9
    assign b2_p1[1] = 128'h 2295_E058_7E81_D3EE_271A_0506_5988_89BA; //1FC9

    // Response = B4
    assign b2_p1[2] = 128'h 439A_633A_165D_143C_FF2C_3D00_9E4F_B42A; //2AB4

    // Response = 14
    assign b2_p1[3] = 128'h 1AB7_6FB3_7FBA_C82F_8BCD_3D00_7094_6749; //3F14

////////////////////  BOARD 2 - PUF 2 ////////////////////////////////////
    // Response = AA
    assign b2_p2[0] = 128'h 8A6D_264C_D7AE_265E_4CBC_3A55_DAAD_A974; //00AA

    // Response = 95
    assign b2_p2[1] = 128'h 2295_e058_7E81_D3EE_271A_0506_5988_896A; //1F95

    // Response = 55
    assign b2_p2[2] = 128'h 4E9A_633A_165D_143C_FF2C_3D00_9E4F_B42A; //2A55

    // Response = AA
    assign b2_p2[3] = 128'h 1AB7_6FB3_7FBA_C82F_8BCD_3D00_7094_6749; //3FAA

////////////////////  BOARD 2 - PUF 3 ////////////////////////////////////
    // Response = AA
    assign b2_p3[0] = 128'h E132_B1BA_33E4_0534_F7EF_8D6F_D6B6_E9ED; //00AA

    // Response = CA
    assign b2_p3[1] = 128'h 8FCE_4463_7905_CC46_6FF9_9E37_CCAC_B7DC; //3FCA

    // Response = 56
    assign b2_p3[2] = 128'h 0E06_AF92_B201_F354_FACB_4920_031C_1199; //2A56

    // Response = D6
    assign b2_p3[3] = 128'h 0164_55FE_42B5_3AD3_532C_675D_6DA1_844C; //3FD6

	shortreal hd;
	shortreal hd_b1_p1_p2 = 0.0;
	shortreal hd_b1_p1_p3 = 0.0;
	shortreal hd_b1_p2_p3 = 0.0;

	shortreal hd_b2_p1_p2 = 0.0;
	shortreal hd_b2_p1_p3 = 0.0;
	shortreal hd_b2_p2_p3 = 0.0;

	shortreal interboard_hd = 0.0;
	shortreal intraboard_hd1 = 0.0;
	shortreal intraboard_hd2 = 0.0;

	shortreal interboard_p1 = 0.0;
	shortreal interboard_p2 = 0.0;
	shortreal interboard_p3 = 0.0;
	shortreal interboard_p1_p2 = 0.0;
	shortreal interboard_p2_p1 = 0.0;
	shortreal interboard_p1_p3 = 0.0;
	shortreal interboard_p3_p1 = 0.0;
	shortreal interboard_p2_p3 = 0.0;
	shortreal interboard_p3_p2 = 0.0;

	initial begin
		$dumpfile("calc_hamming.vcd");
		$dumpvars(0, calc_hamming);
	end
	
	task automatic ham;
		input [127:0] hash1;
		input [127:0] hash2;
		input string hash1_n;
		input string hash2_n;
		output shortreal hamming_distance;
		
		int i;
		int cnt;
		logic [127:0] distance;

		distance = hash1 ^ hash2;

		for(i = 0; i < 128; i++) begin
			if(distance[i] == 1'b1) cnt++;
		end 
		
		hamming_distance = ($itor(cnt) / 128) * 100;
		$display("HD(%s,%s) = %2.2f",hash1_n,hash2_n,hamming_distance);
	endtask


	initial begin
		int i, j;
		string n1, n2;

		// START BOARD 1 Calculation
		$display("Calculating HD for Board 1:\n");
		$display("HD(placement1, placement2):");
		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b1_p1[%0d]", i);
				n2 = $sformatf("b1_p2[%0d]", j);
				ham(b1_p1[i], b1_p2[i], n1, n2, hd);
				hd_b1_p1_p2 += hd;
			end 

		hd_b1_p1_p2 = hd_b1_p1_p2 / 16;
		$display("\naverage HD between p1 and p2 = %2.2f\n", hd_b1_p1_p2);

		
		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b1_p1[%0d]", i);
				n2 = $sformatf("b1_p3[%0d]", j);
				ham(b1_p1[i], b1_p3[i], n1, n2, hd);
				hd_b1_p1_p3 += hd;
		end 

		hd_b1_p1_p3 = hd_b1_p1_p3 / 16;
		$display("\naverage HD between p1 and p3 = %2.2f\n", hd_b1_p1_p3);

		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b1_p2[%0d]", i);
				n2 = $sformatf("b1_p3[%0d]", j);
				ham(b1_p2[i], b1_p3[i], n1, n2, hd);
				hd_b1_p2_p3 += hd;
		end
		hd_b1_p2_p3 = hd_b1_p2_p3 / 16;
		$display("\naverage HD between p2 and p3 = %2.2f\n", hd_b1_p2_p3);

		intraboard_hd1 = hd_b1_p1_p2 + hd_b1_p1_p3 + hd_b1_p2_p3;
		intraboard_hd1 = intraboard_hd1 / 3;
		// END BOARD 1 Calculation

		// START BOARD 2 Calculation
		$display("Calculating HD for Board 2:\n");
		$display("HD(placement1, placement2):");
		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b2_p1[%0d]", i);
				n2 = $sformatf("b2_p2[%0d]", j);
				ham(b2_p1[i], b2_p2[i], n1, n2, hd);
				hd_b2_p1_p2 += hd;
		end
		hd_b2_p1_p2 = hd_b2_p1_p2 / 16;
		$display("\naverage HD between p1 and p2 = %2.2f\n", hd_b2_p1_p2);

		
		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b2_p1[%0d]", i);
				n2 = $sformatf("b2_p3[%0d]", j);
				ham(b2_p1[i], b2_p3[i], n1, n2, hd);
				hd_b2_p1_p3 += hd;
		end
		hd_b2_p1_p3 = hd_b2_p1_p3 / 16;
		$display("\naverage HD between p1 and p3 = %2.2f\n", hd_b2_p1_p3);

		for(i = 0; i < 4; i++) begin
				n1 = $sformatf("b2_p2[%0d]", i);
				n2 = $sformatf("b2_p3[%0d]", j);
				ham(b2_p2[i], b1_p3[i], n1, n2, hd);
				hd_b2_p2_p3 += hd;
		end
		hd_b2_p2_p3 = hd_b2_p2_p3 / 16;
		$display("\naverage HD between p2 and p3 = %2.2f\n", hd_b2_p2_p3);

		intraboard_hd2 = hd_b2_p1_p2 + hd_b2_p1_p3 + hd_b2_p2_p3;
		intraboard_hd2 = intraboard_hd2 / 3;
		// END BOARD 2 Calculation

		$display("Calculating Interboard HD:\n");

		$display("HD(b1,p1, b2,p1):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p1[%0d]", i);
				n2 = $sformatf("b2_p1[%0d]", j);
				ham(b1_p1[i], b2_p1[j], n1, n2, hd);
				interboard_p1 += hd;
			end 
		end
		interboard_p1 = interboard_p1 / 16;
		$display("\naverage HD between b1,p1 and b2,p1 = %2.2f\n", interboard_p1);

		$display("HD(b1,p2, b2,p2):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p2[%0d]", i);
				n2 = $sformatf("b2_p2[%0d]", j);
				ham(b1_p2[i], b2_p2[j], n1, n2, hd);
				interboard_p2 += hd;
			end 
		end
		interboard_p2 = interboard_p2 / 16;
		$display("\naverage HD between b1,p2 and b2,p2 = %2.2f\n", interboard_p2);

		$display("HD(b1,p3, b2,p3):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p3[%0d]", i);
				n2 = $sformatf("b2_p3[%0d]", j);
				ham(b1_p3[i], b2_p3[j], n1, n2, hd);
				interboard_p3 += hd;
			end 
		end
		interboard_p3 = interboard_p3 / 16;
		$display("\naverage HD between b1,p3 and b2,p3 = %2.2f\n", interboard_p3);

		$display("HD(b1,p1, b2,p2):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p1[%0d]", i);
				n2 = $sformatf("b2_p2[%0d]", j);
				ham(b1_p1[i], b2_p2[j], n1, n2, hd);
				interboard_p1_p2 += hd;
			end 
		end
		interboard_p1_p2 = interboard_p1_p2 / 16;
		$display("\naverage HD between b1,p1 and b2,p2 = %2.2f\n", interboard_p1_p2);

		$display("HD(b1,p2, b2,p1):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p2[%0d]", i);
				n2 = $sformatf("b2_p1[%0d]", j);
				ham(b1_p2[i], b2_p1[j], n1, n2, hd);
				interboard_p2_p1 += hd;
			end 
		end
		interboard_p2_p1 = interboard_p2_p1 / 16;
		$display("\naverage HD between b1,p2 and b2,p1 = %2.2f\n", interboard_p2_p1);

		$display("HD(b1,p1, b2,p3):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p1[%0d]", i);
				n2 = $sformatf("b2_p3[%0d]", j);
				ham(b1_p1[i], b2_p3[j], n1, n2, hd);
				interboard_p1_p3 += hd;
			end 
		end
		interboard_p1_p3 = interboard_p1_p3 / 16;
		$display("\naverage HD between b1,p1 and b2,p3 = %2.2f\n", interboard_p1_p3);

		$display("HD(b1,p3, b2,p1):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p3[%0d]", i);
				n2 = $sformatf("b2_p1[%0d]", j);
				ham(b1_p3[i], b2_p1[j], n1, n2, hd);
				interboard_p3_p1 += hd;
			end 
		end
		interboard_p3_p1 = interboard_p3_p1 / 16;
		$display("\naverage HD between b1,p3 and b2,p1 = %2.2f\n", interboard_p3_p1);

		$display("HD(b1,p2, b2,p3):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p2[%0d]", i);
				n2 = $sformatf("b2_p3[%0d]", j);
				ham(b1_p2[i], b2_p3[j], n1, n2, hd);
				interboard_p2_p3 += hd;
			end 
		end
		interboard_p2_p3 = interboard_p2_p3 / 16;
		$display("\naverage HD between b1,p2 and b2,p3 = %2.2f\n", interboard_p2_p3);

		$display("HD(b1,p3, b2,p2):");
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				n1 = $sformatf("b1_p3[%0d]", i);
				n2 = $sformatf("b2_p2[%0d]", j);
				ham(b1_p3[i], b2_p2[j], n1, n2, hd);
				interboard_p3_p2 += hd;
			end 
		end
		interboard_p3_p2 = interboard_p3_p2 / 16;
		$display("\naverage HD between b1,p3 and b1,p2 = %2.2f\n", interboard_p3_p2);

		interboard_hd = interboard_p1 + interboard_p2 + interboard_p3
						+ interboard_p1_p2 + interboard_p2_p1
						+ interboard_p1_p3 + interboard_p3_p1
						+ interboard_p2_p3 + interboard_p3_p2;
		interboard_hd = interboard_hd / 9;

		$display("average intraboard hamming distance for board 1 = %2.2f", intraboard_hd1);
		$display("average intraboard hamming distance for board 2 = %2.2f", intraboard_hd2);
		$display("average interboard hamming distance = %2.2f", interboard_hd);

		
	end
	


endmodule
