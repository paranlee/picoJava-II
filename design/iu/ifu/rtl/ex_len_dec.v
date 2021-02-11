/****************************************************************
 ---------------------------------------------------------------
     Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
     Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
     The contents of this file are subject to the current
     version of the Sun Community Source License, picoJava-II
     Core ("the License").  You may not use this file except
     in compliance with the License.  You may obtain a copy
     of the License by searching for "Sun Community Source
     License" on the World Wide Web at http://www.sun.com.
     See the License for the rights, obligations, and
     limitations governing use of the contents of this file.

     Sun, Sun Microsystems, the Sun logo, and all Sun-based
     trademarks and logos, Java, picoJava, and all Java-based
     trademarks and logos are trademarks or registered trademarks 
     of Sun Microsystems, Inc. in the United States and other
     countries.
 ----------------------------------------------------------------
******************************************************************/

module ex_len_dec (

opcode,
valid,
len0,
len1,
len2,
len3,
len4,
len5

);

input	[7:0]	opcode;
input	[4:0]	valid;
output		len0;
output		len1;
output		len2;
output		len3;
output		len4;
output		len5;

reg	len1,len2,len3,len4,len5;

always @(opcode or valid) begin

	len1 = 1'b0;
	len2 = 1'b0;
	len3 = 1'b0;
	len4 = 1'b0;
	len5 = 1'b0;

	case(opcode[7:0])

		8'd0:	len1 = valid[0];
		8'd1:	len1 = valid[0];
		8'd2:	len1 = valid[0];
		8'd3:	len1 = valid[0];
		8'd4:	len1 = valid[0];
		8'd5:	len1 = valid[0];
		8'd6:	len1 = valid[0];
		8'd7:	len1 = valid[0];
		8'd8:	len1 = valid[0];
		8'd9:	len1 = valid[0];
		8'd10:	len1 = valid[0];
		8'd11:	len1 = valid[0];
		8'd12:	len1 = valid[0];
		8'd13:	len1 = valid[0];
		8'd14:	len1 = valid[0];
		8'd15:	len1 = valid[0];
		8'd16:	len2 = valid[0] & valid[1];
		8'd17:	len3 = valid[0] & valid[1] & valid[2];
		8'd18:	len2 = valid[0] & valid[1];
		8'd19:	len3 = valid[0] & valid[1] & valid[2];
		8'd20:	len3 = valid[0] & valid[1] & valid[2];
		8'd21:	len2 = valid[0] & valid[1];
		8'd22:	len2 = valid[0] & valid[1];
		8'd23:	len2 = valid[0] & valid[1];
		8'd24:	len2 = valid[0] & valid[1];
		8'd25:	len2 = valid[0] & valid[1];
		8'd26:	len1 = valid[0];
		8'd27:	len1 = valid[0];
		8'd28:	len1 = valid[0];
		8'd29:	len1 = valid[0];
		8'd30:	len1 = valid[0];
		8'd31:	len1 = valid[0];
		8'd32:	len1 = valid[0];
		8'd33:	len1 = valid[0];
		8'd34:	len1 = valid[0];
		8'd35:	len1 = valid[0];
		8'd36:	len1 = valid[0];
		8'd37:	len1 = valid[0];
		8'd38:	len1 = valid[0];
		8'd39:	len1 = valid[0];
		8'd40:	len1 = valid[0];
		8'd41:	len1 = valid[0];
		8'd42:	len1 = valid[0];
		8'd43:	len1 = valid[0];
		8'd44:	len1 = valid[0];
		8'd45:	len1 = valid[0];
		8'd46:	len1 = valid[0];
		8'd47:	len1 = valid[0];
		8'd48:	len1 = valid[0];
		8'd49:	len1 = valid[0];
		8'd50:	len1 = valid[0];
		8'd51:	len1 = valid[0];
		8'd52:	len1 = valid[0];
		8'd53:	len1 = valid[0];
		
		8'd54:	len2 = valid[0] & valid[1];
		8'd55:	len2 = valid[0] & valid[1];
		8'd56:	len2 = valid[0] & valid[1];
		8'd57:	len2 = valid[0] & valid[1];
		8'd58:	len2 = valid[0] & valid[1];
		8'd59:	len1 = valid[0];
		8'd60:	len1 = valid[0];
		8'd61:	len1 = valid[0];
		8'd62:	len1 = valid[0];
		8'd63:	len1 = valid[0];
		8'd64:	len1 = valid[0];
		8'd65:	len1 = valid[0];
		8'd66:	len1 = valid[0];
		8'd67:	len1 = valid[0];
		8'd68:	len1 = valid[0];
		8'd69:	len1 = valid[0];
		8'd70:	len1 = valid[0];
		8'd71:	len1 = valid[0];
		8'd72:	len1 = valid[0];
		8'd73:	len1 = valid[0];
		8'd74:	len1 = valid[0];
		8'd75:	len1 = valid[0];
		8'd76:	len1 = valid[0];
		8'd77:	len1 = valid[0];
		8'd78:	len1 = valid[0];
		8'd79:	len1 = valid[0];
		8'd80:	len1 = valid[0];
		8'd81:	len1 = valid[0];
		8'd82:	len1 = valid[0];
		8'd83:	len1 = valid[0];
		8'd84:	len1 = valid[0];
		8'd85:	len1 = valid[0];
		8'd86:	len1 = valid[0];
		8'd87:	len1 = valid[0];
		8'd88:	len1 = valid[0];
		8'd89:	len1 = valid[0];
		8'd90:	len1 = valid[0];
		8'd91:	len1 = valid[0];
		8'd92:	len1 = valid[0];
		8'd93:	len1 = valid[0];
		8'd94:	len1 = valid[0];
		8'd95:	len1 = valid[0];
		8'd96:	len1 = valid[0];
		8'd97:	len1 = valid[0];
		8'd98:	len1 = valid[0];
		8'd99:	len1 = valid[0];
		8'd100:	len1 = valid[0];
		8'd101:	len1 = valid[0];
		8'd102:	len1 = valid[0];
		8'd103:	len1 = valid[0];
		8'd104:	len1 = valid[0];
		8'd105:	len1 = valid[0];
		8'd106:	len1 = valid[0];
		8'd107:	len1 = valid[0];
		8'd108:	len1 = valid[0];
		8'd109:	len1 = valid[0];
		8'd110:	len1 = valid[0];
		8'd111:	len1 = valid[0];
		8'd112:	len1 = valid[0];
		8'd113:	len1 = valid[0];
		8'd114:	len1 = valid[0];
		8'd115:	len1 = valid[0];
		8'd116:	len1 = valid[0];
		8'd117:	len1 = valid[0];
		8'd118:	len1 = valid[0];
		8'd119:	len1 = valid[0];
		8'd120:	len1 = valid[0];
		8'd121:	len1 = valid[0];
		8'd122:	len1 = valid[0];
		8'd123:	len1 = valid[0];
		8'd124:	len1 = valid[0];
		8'd125:	len1 = valid[0];
		8'd126:	len1 = valid[0];
		8'd127:	len1 = valid[0];
		8'd128:	len1 = valid[0];
		8'd129:	len1 = valid[0];
		8'd130:	len1 = valid[0];
		8'd131:	len1 = valid[0];
		8'd132:	len3 = valid[0] & valid[1] & valid[2];
		8'd133:	len1 = valid[0];
		8'd134:	len1 = valid[0];
		8'd135:	len1 = valid[0];
		8'd136:	len1 = valid[0];
		8'd137:	len1 = valid[0];
		8'd138:	len1 = valid[0];
		8'd139:	len1 = valid[0];
		8'd140:	len1 = valid[0];
		8'd141:	len1 = valid[0];
		8'd142:	len1 = valid[0];
		8'd143:	len1 = valid[0];
		8'd144:	len1 = valid[0];
		8'd145:	len1 = valid[0];
		8'd146:	len1 = valid[0];
		8'd147:	len1 = valid[0];
		8'd148:	len1 = valid[0];
		8'd149:	len1 = valid[0];
		8'd150:	len1 = valid[0];
		8'd151:	len1 = valid[0];
		8'd152:	len1 = valid[0];
		8'd153:	len3 = valid[0] & valid[1] & valid[2];
		8'd154:	len3 = valid[0] & valid[1] & valid[2];
		8'd155:	len3 = valid[0] & valid[1] & valid[2];
		8'd156:	len3 = valid[0] & valid[1] & valid[2];
		8'd157:	len3 = valid[0] & valid[1] & valid[2];
		8'd158:	len3 = valid[0] & valid[1] & valid[2];
		8'd159:	len3 = valid[0] & valid[1] & valid[2];
		8'd160:	len3 = valid[0] & valid[1] & valid[2];
		8'd161:	len3 = valid[0] & valid[1] & valid[2];
		8'd162:	len3 = valid[0] & valid[1] & valid[2];
		8'd163:	len3 = valid[0] & valid[1] & valid[2];
		8'd164:	len3 = valid[0] & valid[1] & valid[2];
		8'd165:	len3 = valid[0] & valid[1] & valid[2];
		8'd166:	len3 = valid[0] & valid[1] & valid[2];
		8'd167:	len3 = valid[0] & valid[1] & valid[2];
		8'd168:	len3 = valid[0] & valid[1] & valid[2];
		8'd169:	len2 = valid[0] & valid[1];
		8'd170:	len1 = valid[0];
		8'd171:	len1 = valid[0];
		8'd172:	len1 = valid[0];
		8'd173:	len1 = valid[0];
		8'd174:	len1 = valid[0];
		8'd175:	len1 = valid[0];
		8'd176:	len1 = valid[0];
		8'd177:	len1 = valid[0];
		8'd178:	len3 = valid[0] & valid[1] & valid[2];
		8'd179:	len3 = valid[0] & valid[1] & valid[2];
		8'd180:	len3 = valid[0] & valid[1] & valid[2];
		8'd181:	len3 = valid[0] & valid[1] & valid[2];
		8'd182:	len3 = valid[0] & valid[1] & valid[2];
		8'd183:	len3 = valid[0] & valid[1] & valid[2];
		8'd184:	len3 = valid[0] & valid[1] & valid[2];
		8'd185:	len5 = valid[0] & valid[1] & valid[2] & valid[3] & valid[4];
		8'd186:	len1 = valid[0]; 
		8'd187:	len3 = valid[0] & valid[1] & valid[2];
		8'd188:	len2 = valid[0] & valid[1];
		8'd189:	len3 = valid[0] & valid[1] & valid[2];
		8'd190:	len1 = valid[0];
		8'd191:	len1 = valid[0];
		8'd192:	len3 = valid[0] & valid[1] & valid[2];
		8'd193:	len3 = valid[0] & valid[1] & valid[2];
		8'd194:	len1 = valid[0];
		8'd195:	len1 = valid[0];
		8'd196:	len1 = valid[0];
		8'd197:	len4 = valid[0] & valid[1] & valid[2] & valid[3];
		8'd198:	len3 = valid[0] & valid[1] & valid[2];
		8'd199:	len3 = valid[0] & valid[1] & valid[2];
		8'd200:	len5 = valid[0] & valid[1] & valid[2] & valid[3] & valid[4];
		8'd201:	len5 = valid[0] & valid[1] & valid[2] & valid[3] & valid[4];
		8'd202:	len1 = valid[0];
		8'd203:	len2 = valid[0] & valid[1];
		8'd204:	len3 = valid[0] & valid[1] & valid[2];
		8'd205:	len3 = valid[0] & valid[1] & valid[2];
		8'd206:	len3 = valid[0] & valid[1] & valid[2];
		8'd207:	len3 = valid[0] & valid[1] & valid[2];
		8'd208:	len3 = valid[0] & valid[1] & valid[2];
		8'd209:	len3 = valid[0] & valid[1] & valid[2];
		8'd210:	len3 = valid[0] & valid[1] & valid[2];
		8'd211:	len3 = valid[0] & valid[1] & valid[2];
		8'd212:	len3 = valid[0] & valid[1] & valid[2];
		8'd213:	len3 = valid[0] & valid[1] & valid[2];
		8'd214:	len3 = valid[0] & valid[1] & valid[2];
		8'd215:	len3 = valid[0] & valid[1] & valid[2];
		8'd216:	len3 = valid[0] & valid[1] & valid[2];
		8'd217:	len3 = valid[0] & valid[1] & valid[2];
		8'd218:	len3 = valid[0] & valid[1] & valid[2];
		8'd219:	len3 = valid[0] & valid[1] & valid[2];
//		8'd220:	len3 = valid[0] & valid[1] & valid[2];
		8'd220:	len1 = valid[0];
		8'd221:	len3 = valid[0] & valid[1] & valid[2];
		8'd222:	len3 = valid[0] & valid[1] & valid[2];
		8'd223:	len3 = valid[0] & valid[1] & valid[2];
		8'd224:	len3 = valid[0] & valid[1] & valid[2];
		8'd225:	len3 = valid[0] & valid[1] & valid[2];
		8'd226:	len3 = valid[0] & valid[1] & valid[2];
		8'd227:	len3 = valid[0] & valid[1] & valid[2];
		8'd228:	len3 = valid[0] & valid[1] & valid[2];
		8'd229:	len1 = valid[0];
		8'd230:	len3 = valid[0] & valid[1] & valid[2];
		8'd231:	len3 = valid[0] & valid[1] & valid[2];
		8'd232:	len3 = valid[0] & valid[1] & valid[2];
		8'd233:	len3 = valid[0] & valid[1] & valid[2];
		8'd234:	len2 = valid[0] & valid[1];
		8'd235:	len3 = valid[0] & valid[1] & valid[2];
		8'd236:	len1 = valid[0];
		8'd237:	len3 = valid[0] & valid[1] & valid[2];
		8'd238:	len3 = valid[0] & valid[1] & valid[2];
		8'd239:	len3 = valid[0] & valid[1] & valid[2];
		8'd240:	len3 = valid[0] & valid[1] & valid[2];
		8'd241:	len3 = valid[0] & valid[1] & valid[2];
		8'd242:	len3 = valid[0] & valid[1] & valid[2];
		8'd243:	len3 = valid[0] & valid[1] & valid[2];
		8'd244:	len3 = valid[0] & valid[1] & valid[2];
		8'd245:	len3 = valid[0] & valid[1] & valid[2];
		8'd246:	len3 = valid[0] & valid[1] & valid[2];
		8'd255:	len2 = valid[0] & valid[1];
		default: len1 = valid[0];
		
	endcase

end

assign	len0 = !(len1 | len2 | len3 | len4 | len5);

endmodule
