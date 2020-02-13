takeSamples = 250 * 5 * 60;
bufSz = 512;
totalBuf = 0;
memAddr = 0;
nloop = 0;
clc
while (memAddr  < takeSamples * 4)
    nloop = nloop + 1;
    if ((takeSamples * 4 - 1) < (memAddr + bufSz))
      bufSz = takeSamples * 4 - memAddr;
    end
    totalBuf = totalBuf + bufSz;
    disp([num2str(nloop),'- memAddr: ',num2str(memAddr), ' @ ', num2str(bufSz),' bytes']);
    
    memAddr = memAddr + bufSz;
end
disp(['Wrote ',num2str(totalBuf),' bytes, ',num2str(totalBuf/4),' int32s']);