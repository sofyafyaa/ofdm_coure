function bits = file_reader(file, filesize)
            fileID = fopen(file,'r','b');
            bitstream = fread(fileID, filesize, 'ubit1'); % Считали QAM_Cells*Bit_Depth бит из файла
            fclose('all');
            bits = reshape(bitstream,1,[]);
end

