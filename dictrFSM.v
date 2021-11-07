// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//Finite State Machine of Control Path
// using 3 always 
module dicClockFsm (
		output reg dicRun,     // clock is running
		output reg dicDspMtens,
		output reg dicDspMones,
		output reg dicDspStens,
		output reg dicDspSones,

		output reg dicStrMtens,
		output reg dicStrMones,
		output reg dicStrStens,
		output reg dicStrSones,

		output reg dicLdMTens, //1 if ten's minutes should be loaded. 0 if not.
		output reg dicLdMOnes, //1 if one's minutes should be loaded. 0 if not.
		output reg dicLdSTens, //1 if ten's seconds should be loaded. 0 if not.
		output reg dicLdSOnes, //1 if one's seconds should be loaded. 0 if not.

		output reg dicAMTens, //1 if ten's minutes for alarm should be loaded. 0 if not.
		output reg dicAMOnes,
		output reg dicASTens,
		output reg dicASOnes,
		
		output reg alarm_ena,

        	input      det_cr,
        	input      det_S,      // S/s detected
                input      det_L,      // L/l detected
		input      det_A,      // A/a detected
		input      det_num0to5, // Num 0-5 detected
		input      det_num0to9, // Num 0-9 detected
		input      det_atSign, //@ sign detected.

		input      rst,
		input      clk
    );

    //defining local parameters for the rest of our alarm clock.
    localparam
    STOP             = 4'b0000, 
    RUN              = 4'b0001,

    LOAD_TIME_1      = 4'b0010,
    LOAD_TIME_2      = 4'b0011,
    LOAD_TIME_3      = 4'b0100,
    LOAD_TIME_4      = 4'b0101,
    LOAD_TIME_5      = 4'b0110,

    LOAD_ALARM_1     = 4'b0111,
    LOAD_ALARM_2     = 4'b1000,
    LOAD_ALARM_3     = 4'b1001,
    LOAD_ALARM_4     = 4'b1010,
    LOAD_ALARM_5     = 4'b1011,
    LOAD_ALARM_6     = 4'b1100,

    DEACTIVATE_ALARM = 4'b1101,
    ACTIVATE_ALARM   = 4'b1110;

    /*STOP             = 1'b0, 
    RUN              = 1'b1,

    LOAD_TIME_1      = 3'b010,
    LOAD_TIME_2      = 3'b011,
    LOAD_TIME_3      = 3'b100,
    LOAD_TIME_4      = 3'b101,
    LOAD_TIME_5      = 3'b110,

    DEACTIVATE_ALARM = 3'b000,
    ACTIVATE_ALARM   = 3'b001,

    LOAD_ALARM_1     = 3'b010,
    LOAD_ALARM_2     = 3'b011,
    LOAD_ALARM_3     = 3'b100,
    LOAD_ALARM_4     = 3'b101,
    LOAD_ALARM_5     = 3'b110,
    LOAD_ALARM_6     = 3'b111;*/


    //defining states for our alarm clock.
    reg [3:0] cState;
    reg [3:0] nState;

    //reg [2:0] currentLoadState;
    //reg [2:0] nextLoadState;

    //reg [2:0] currentActivationState;
    //reg [2:0] nextActivationState;

    reg [3:0] currentAlarmState;
    reg [3:0] nextAlarmState;

    reg isLoading = 1'b0;


    //
    // state machine next state
    //
    //FSM.1 add code to set nState to STOP or RUN
    //      if det_S -- nState = RUN
    //      if det_cr -- nState = STOP
    //      5% of points assigned to lab3
    always @(*) begin
        if (rst)
	    begin
                nState = STOP;
	        isLoading = 0;
	    end
        else begin

        case (cState)
            RUN:
   	    begin
		if(det_cr)
		   nState = STOP;
		else if(det_S)
		   nState = RUN;
		else if(det_L)
		   nState = LOAD_TIME_1;
		else if(det_A)
		   nState = LOAD_ALARM_1;
		else
		   nState = RUN;
		//if(det_cr & !isLoading) nState = STOP;
		//else nState = RUN;
   	    end

     	    STOP:
            begin
		if(det_S)
		   nState = RUN;
		else if(det_cr)
		   nState = STOP;
		else if(det_L)
		   nState = LOAD_TIME_1;
		else if(det_A)
		   nState = LOAD_ALARM_1;
		else
		   nState = STOP;
		//if(det_S & !isLoading) nState = RUN;
		//else nState = STOP;
            end

	    //loading transition states.
	    LOAD_TIME_1:
	    begin
		isLoading = 1;
		if(det_num0to5)
		    nState = LOAD_TIME_2;
		else
		    nState = LOAD_TIME_1;
	    end

	    LOAD_TIME_2:
	    begin
		isLoading = 1;
		if(det_num0to9)
		    nState = LOAD_TIME_3;
		else
		    nState = LOAD_TIME_2;
	    end

	    LOAD_TIME_3:
	    begin
		isLoading = 1;
		if(det_num0to5)
		    nState = LOAD_TIME_4;
		else
		    nState = LOAD_TIME_3;
	    end

	    LOAD_TIME_4:
	    begin
		isLoading = 1;
		if(det_num0to9)
		    nState = LOAD_TIME_5;
		else
		    nState = LOAD_TIME_4;
	    end

	    LOAD_TIME_5:
	    begin
	        isLoading = 0;
	        if(det_S)
		    nState = RUN;
		else if(det_cr)
		    nState = STOP;
		else
		    nState = LOAD_TIME_5;
	    end

	    //alarm transition states.
	    LOAD_ALARM_1:
	    begin
	    	if(det_num0to5)
		    nState = LOAD_ALARM_2;
		else
		    nState = LOAD_ALARM_1;
	    end

	    LOAD_ALARM_2:
	    begin
	    	if(det_num0to9)
		    nState = LOAD_ALARM_3;
		else
		    nState = LOAD_ALARM_2;
	    end

	    LOAD_ALARM_3:
	    begin
	    	if(det_num0to5)
		    nState = LOAD_ALARM_4;
		else
		    nState = LOAD_ALARM_3;
	    end

	    LOAD_ALARM_4:
	    begin
	    	if(det_num0to9)
		    nState = LOAD_ALARM_5;
		else
		    nState = LOAD_ALARM_4;
	    end

	    LOAD_ALARM_5:
	    begin
	    	if(det_atSign)
		    nState = LOAD_ALARM_5;
		if(det_S)
		    nState = RUN;
		else if(det_cr)
		    nState = STOP;
		else if(det_A)
		    nState = LOAD_ALARM_1;
		else
		    nState = LOAD_ALARM_5;
	    end
	
	    default:
	    begin
	    end

        endcase

        end

   end

    //
    // state machine outputs
    //
    //FSM.2 add code to set the output signals of 
    //      STOP and RUN states
	//      5% of points assigned to Lab3
    always @(*) begin

        /*dicRun = 0;
        dicDspMtens = 0;
        dicDspMones = 0;
        dicDspStens = 0;
        dicDspSones = 0;*/

	dicAMTens = 0;
	dicAMOnes = 0;
	dicASTens = 0;
	dicASOnes = 0;

	dicStrMtens = 0;
	dicStrMones = 0;
	dicStrStens = 0;
	dicStrSones = 0;

        case (cState)
        STOP:
	   begin
	        dicRun = 0;
	        dicDspSones = 1;
		dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
           end

        RUN:
	   begin
           	dicRun = 1;
           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
           end

	//outputs for loading time.
	LOAD_TIME_1:
	    begin
		dicLdMTens = det_num0to5;
		dicLdMOnes = 0;
		dicLdSTens = 0;
		dicLdSOnes = 0;

           	dicDspSones = 0;
           	dicDspStens = 0;
           	dicDspMones = 0;
           	dicDspMtens = 1;
	    end

	LOAD_TIME_2:
	    begin
		dicLdMTens = 0;
		dicLdMOnes = det_num0to9;
		dicLdSTens = 0;
		dicLdSOnes = 0;

           	dicDspSones = 0;
           	dicDspStens = 0;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_TIME_3:
	    begin
		dicLdMTens = 0;
		dicLdMOnes = 0;
		dicLdSTens = det_num0to5;
		dicLdSOnes = 0;

           	dicDspSones = 0;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_TIME_4:
	    begin
		dicLdMTens = 0;
		dicLdMOnes = 0;
		dicLdSTens = 0;
		dicLdSOnes = det_num0to9;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_TIME_5:
	    begin
		dicLdMTens = 0;
		dicLdMOnes = 0;
		dicLdSTens = 0;
		dicLdSOnes = 0;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	//outputs for alarm clock.
	LOAD_ALARM_1:
	    begin
		dicAMTens = det_num0to5;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;
		
		dicStrMtens = 1;
		dicStrMones = 0;
		dicStrStens = 0;
		dicStrSones = 0;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_ALARM_2:
	    begin
		dicAMTens = 0;
		dicAMOnes = det_num0to9;
		dicASTens = 0;
		dicASOnes = 0;

		dicStrMtens = 1;
		dicStrMones = 1;
		dicStrStens = 0;
		dicStrSones = 0;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_ALARM_3:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = det_num0to5;
		dicASOnes = 0;

		dicStrMtens = 1;
		dicStrMones = 1;
		dicStrStens = 1;
		dicStrSones = 0;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_ALARM_4:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = det_num0to9;

		dicStrMtens = 1;
		dicStrMones = 1;
		dicStrStens = 1;
		dicStrSones = 1;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_ALARM_5:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;

		dicStrMtens = 1;
		dicStrMones = 1;
		dicStrStens = 1;
		dicStrSones = 1;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

	LOAD_ALARM_6:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;

		dicStrMtens = 1;
		dicStrMones = 1;
		dicStrStens = 1;
		dicStrSones = 1;

           	dicDspSones = 1;
           	dicDspStens = 1;
           	dicDspMones = 1;
           	dicDspMtens = 1;
	    end

       endcase

   end

   //this always block handles whether our alarm is activated or deactivated.
   always @(*) begin
	if(rst)
	     nextAlarmState = DEACTIVATE_ALARM;
	else
	case(currentAlarmState)
	   DEACTIVATE_ALARM:
	     begin
	     if(det_atSign)
		nextAlarmState = ACTIVATE_ALARM;
	     else
		nextAlarmState = DEACTIVATE_ALARM;
	     end

	   ACTIVATE_ALARM:
	     begin
	     if(det_atSign)
		nextAlarmState = DEACTIVATE_ALARM;
	     else
		nextAlarmState = ACTIVATE_ALARM;
	     end
	endcase
   end

   //this always block handles the output of the alarm's state.
   always @(*) begin
	case(currentAlarmState)
	   DEACTIVATE_ALARM:
	     begin
		alarm_ena = 0;
	     end

	   ACTIVATE_ALARM:
	     begin
		alarm_ena = 1;
	     end
	endcase
   end

   //this always block handles the loading of the alarm into our clock.
   /*always @(*) begin
      case(currentAlarmState)
	 RUN:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    else if(det_A)
		nextAlarmState = LOAD_ALARM_1;
	    end

	 STOP:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    else if(det_A)
		nextAlarmState = LOAD_ALARM_1;
	    end

	 LOAD_ALARM_1:
	    begin
	    if(rst)
	        nextAlarmState = STOP;
	    else if(det_num0to5)
		nextAlarmState = LOAD_ALARM_2;
	    end

	 LOAD_ALARM_2:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    else if(det_num0to9)
		nextAlarmState = LOAD_ALARM_3;
	    end

	 LOAD_ALARM_3:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    else if(det_num0to5)
		nextAlarmState = LOAD_ALARM_4;
	    end

	 LOAD_ALARM_4:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    else if(det_num0to9)
		nextAlarmState = LOAD_ALARM_5;
	    end

	 LOAD_ALARM_5:
	    begin
	    if(rst | det_cr)
		nextAlarmState = STOP;
	    else if(det_S)
		nextAlarmState = RUN;
	    end

	 LOAD_ALARM_6:
	    begin
	    if(rst)
		nextAlarmState = STOP;
	    end

      endcase

   end*/

   //this always block handles the output of the alarm clock.
   /*always @(*) begin
      case(currentAlarmState)
	 LOAD_ALARM_1:
	    begin
		dicAMTens = det_num0to5;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;
	    end

	 LOAD_ALARM_2:
	    begin
		dicAMTens = 0;
		dicAMOnes = det_num0to9;
		dicASTens = 0;
		dicASOnes = 0;
	    end

	 LOAD_ALARM_3:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = det_num0to5;
		dicASOnes = 0;
	    end

	 LOAD_ALARM_4:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = det_num0to9;
	    end

	 LOAD_ALARM_5:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;
	    end

	 LOAD_ALARM_6:
	    begin
		dicAMTens = 0;
		dicAMOnes = 0;
		dicASTens = 0;
		dicASOnes = 0;
	    end

      endcase

   end*/

   always @(posedge clk) begin
      cState <= nState;
      //currentLoadState <= nextLoadState;
      currentAlarmState <= nextAlarmState;
      //currentActivationState <= nextActivationState;
   end
   
endmodule
