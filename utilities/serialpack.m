%%
function [ success, answer ] = serial_eval(command, port, response)

timeout = 50;

s = serial(port,'BaudRate', 115200, 'Terminator', 'CR/LF');
fopen(s);

fprintf(s,command);

for i=1:timeout
    
    str = fgetl(s)
    
    if strcmp(str, 'nack') == 1
        warning('Wrong command!');
        answer = str;
        success = 0;
        break;
        
    elseif strcmp(str, response) == 1
        disp('Command acknowledged!');
        answer = response;
        success = 1;
        break;
    end
    
    if(i==timeout)
        warning('Timeout');
        answer = 'Timeout';
        success = -1;
        break;
    end
end

all_instr = instrfind;
fclose(all_instr);
clear s;
end