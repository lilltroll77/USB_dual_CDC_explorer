s_bin=serial('COM14');
s_text=serial('COM15');

flushinput(s_bin);
flushinput(s_text);
flushoutput(s_bin);
flushoutput(s_text);


delay=5e-2;
set(s_bin , 'BytesAvailableFcnMode' , 'byte');
s_bin.OutputBufferSize = 512;
s_text.OutputBufferSize = 512;
%set(s1 , 'ReadAsyncMode' , 'manual');
%set(s2 , 'ReadAsyncMode' , 'manual');


fopen(s_bin);
fopen(s_text);
pause(delay);
packages = 25;

prec='uint8';

timeout=25;

for j=1:50
    for i=1:packages
        
        %Maximum USB microframe length is 64 bytes.
        
        %WRITE TEXT
        len_text = 1+randi(61);  %%Total length with newline is 63
        % DONT SEND '\' !
        str= [char(randi('Z'-'0' , 1 , len_text )+'0') newline];
        fprintf(s_text , '%s' , str);
        
         %WRITE BINARY
        len_bin = randi(61)+1;
        fwrite(s_bin , uint8([len_bin 1:len_bin]) , prec);
        
        %READ TEXT
        n=timeout;
        while(s_text.BytesAvailable < len_text)
            pause(delay);
            n=n-1;
            if(n==0)
                fclose(s_bin);
                fclose(s_text);
                error('TEXT TIMED OUT');
            end
        end
        c0 = fscanf(s_text , '%s');
        
        if(~strcmp(str(1:end-1) , c0))
            fclose(s_bin);
            fclose(s_text);
            error('ERROR in text string');
        end
            
        %READ BINARY
         n=timeout;
        while(s_bin.BytesAvailable ==0)
            pause(delay);
            n=n-1;
            if(n==0)
                fclose(s_bin);
                fclose(s_text);
                error('BIN HEADER TIMED OUT');
            end
        end
        len_in = fread(s_bin , 1 , prec );
        n=timeout;
        while(s_bin.BytesAvailable < len_in)
            pause(delay);
            n=n-1;
            if(n==0)
                fclose(s_bin);
                fclose(s_text);
                error('BIN PAYLOAD TIMED OUT');
            end
        end
        [b0, count] = fread(s_bin , len_in , prec );
        if(count ~= len_in)
            disp('NAR');
        end
   
        res = sum( b0(:) -1- (1:len_in)');
        if(res~=0)
            b0'
            (1:len_in)
            len_in-count
            fclose(s_bin);
            fclose(s_text);
            error('ERROR in binary');
        end
    end
    
str_f=sprintf("Iter_%d: %d USB micropackages sent on each port" ,j, i);
disp(str_f); 
    
end

fclose(s_bin);
fclose(s_text);

