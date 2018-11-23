function  compute()






nBlocks = 3;
trialsPerBlock = 4;
numberOfNotes = 4;
error_cents_block = zeros(nBlocks,trialsPerBlock*(numberOfNotes-1));
error_freq_block = zeros(nBlocks,trialsPerBlock*(numberOfNotes-1));
for i=1:nBlocks
    m = csvread(['tony_files\block_',num2str(i),'_Alfonso_normal.csv']);
    j=1;
    for n=1:trialsPerBlock
        pitch_ref = m(((n-1)*numberOfNotes*3+1):(numberOfNotes+(n-1)*numberOfNotes*3),2);
        pitch_ref_cents = freq2cents(pitch_ref/pitch_ref(1));
        pitch_prod = m((numberOfNotes)+((n-1)*numberOfNotes*3+1):(numberOfNotes*2+(n-1)*numberOfNotes*3),2);
        pitch_prod_cents = freq2cents(pitch_prod/pitch_prod(1));
        error_cents_block(i,j:j+numberOfNotes-2) = (pitch_prod_cents(2:end) - pitch_ref_cents(2:end))';
        error_freq_block(i,j:j+numberOfNotes-2) = freq2cents(pitch_prod(2:end)'./pitch_ref(2:end,1)');
        j=j+numberOfNotes-1;
    end

end
end


