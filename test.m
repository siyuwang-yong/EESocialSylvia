data = [1 2 3 4]; 
s = whos('data');
tcpipServer = tcpip('128.196.99.8',55000,'NetworkRole','Server');
set(tcpipServer,'OutputBufferSize',s.bytes);
fopen(tcpipServer);
fwrite(tcpipServer,data(:),'double');
fclose(tcpipServer);

%%
% echoudp('on', 53031);
ipA = '10.134.182.236';   portA = 53051;   % Modify these values to be those of your first computer.
ipB = '10.142.190.243';  portB = 54954;  % Modify these values to be those of your second computer.
%%Create UDP Object
udpA = udp(ipB,portB, 'LocalPort', portA)
%%Connect to UDP Object
fopen(udpA)
%%
udpB = udp(ipA,portA, 'LocalPort', portB)
fopen(udpB)