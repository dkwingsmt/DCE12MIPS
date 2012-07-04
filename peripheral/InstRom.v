`ifdef __TEST1__
14'h0000:    data = 32'h00004027;
14'h0001:    data = 32'h00088822;
14'h0002:    data = 32'h02319020;
14'h0003:    data = 32'h02409020;
14'h0004:    data = 32'h08100003;
`endif
`ifdef __TEST2__
14'h0000:    data = 32'h20020005;
14'h0001:    data = 32'h2003000e;
14'h0002:    data = 32'h20050013;
14'h0003:    data = 32'h2006fff7;
14'h0004:    data = 32'h20070003;
14'h0005:    data = 32'h20080014;
14'h0006:    data = 32'h20090002;
14'h0007:    data = 32'h200a0010;
14'h0008:    data = 32'h200b001e;
14'h0009:    data = 32'h200cffe1;
14'h000a:    data = 32'h200dfffd;
14'h000b:    data = 32'h200e0001;
14'h000c:    data = 32'h10420001;
14'h000d:    data = 32'h08100027;
14'h000e:    data = 32'h1442fffe;
14'h000f:    data = 32'h00432020;
14'h0010:    data = 32'h1485fffc;
14'h0011:    data = 32'h00432022;
14'h0012:    data = 32'h1486fffa;
14'h0013:    data = 32'h00032082;
14'h0014:    data = 32'h1487fff8;
14'h0015:    data = 32'h00062083;
14'h0016:    data = 32'h148dfff6;
14'h0017:    data = 32'h00022080;
14'h0018:    data = 32'h1488fff4;
14'h0019:    data = 32'h00a82024;
14'h001a:    data = 32'h148afff2;
14'h001b:    data = 32'h00682025;
14'h001c:    data = 32'h148bfff0;
14'h001d:    data = 32'h00682027;
14'h001e:    data = 32'h148cffee;
14'h001f:    data = 32'h0065202a;
14'h0020:    data = 32'h148effec;
14'h0021:    data = 32'h3c011001;
14'h0022:    data = 32'h34320000;
14'h0023:    data = 32'h8e400000;
14'h0024:    data = 32'hae440000;
14'h0025:    data = 32'h8e500000;
14'h0026:    data = 32'h12040003;
14'h0027:    data = 32'h0042c820;
14'h0028:    data = 32'h0019c820;
14'h0029:    data = 32'h08100028;
14'h002a:    data = 32'h0063b020;
14'h002b:    data = 32'h00001027;
14'h002c:    data = 32'h3c014000;
14'h002d:    data = 32'h34230010;
14'h002e:    data = 32'hac620000;
14'h002f:    data = 32'h08100028;
`endif
`ifdef __TESTGCD__
`include "../asmblr/script/gcd_text.v"
`endif
`ifdef __TESTDIGI__

14'h0000:    data = 32'h20050001;
14'h0001:    data = 32'h00051021;
14'h0002:    data = 32'h3c011001;
14'h0003:    data = 32'h34280000;
14'h0004:    data = 32'h00021080;
14'h0005:    data = 32'h01024020;
14'h0006:    data = 32'h8d090000;
14'h0007:    data = 32'h00094900;
14'h0008:    data = 32'h21290000;
14'h0009:    data = 32'h3c014000;
14'h000a:    data = 32'h34280018;
14'h000b:    data = 32'had090000;
14'h000c:    data = 32'h08100000;
`endif
