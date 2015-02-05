module serial (rxd, txd, clk);

	input rxd;
	input clk;
	output txd;

	parameter [3:0] send1 = 3'b001, send2 = 3'b011, send3 = 3'b101, send4 = 3'b111,
			s1 = 3'b000, s2 = 3'b010, s3 = 3'b100, s4 = 3'b110;

	reg [3:0] present_state = s1;
	reg [3:0] next_state = s1;

	/* sender ports */
	reg [7:0] snd_data;
	reg snd_start;
	wire snd_busy;

	/* set senders port */
	async_transmitter snd(clk, snd_start, snd_data, txd, snd_busy);
	
	always @(posedge clk) begin
		present_state = next_state;
	end
	
	always @(present_state, snd_busy) begin
		case (present_state)
			0: begin
				/* start send @ */
				snd_data = 8'b0100_0000;
				snd_start = 1'b1;
				next_state = send1;
			end
			1: begin
				snd_start <= 1'b0;
				if (snd_busy == 1'b0)
					next_state = s2;
			end
			2: begin
				/* start send 0 */
				snd_data = 8'b0011_0000;
				snd_start = 1'b1;
				next_state = send2;
			end
			3: begin
				snd_start <= 1'b0;
				if (snd_busy == 1'b0)
					next_state = s3;
			end
			4: begin
				/* start send / */
				snd_data = 8'b0010_1111;
				snd_start = 1'b1;
				next_state = send3;
			end
			5: begin
				snd_start <= 1'b0;
				if (snd_busy == 1'b0)
					next_state = s4;
			end
			6: begin
				/* start send \n */
				snd_data = 8'b0000_1010;
				snd_start = 1'b1;
				next_state = send4;
			end
			7: begin
				snd_start <= 1'b0;
				if (snd_busy == 1'b0)
					next_state = s1;
			end
		endcase
	end
endmodule
