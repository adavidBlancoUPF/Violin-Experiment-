nBlocks = 21;
trialsPerBlock = 4;
numberOfNotes = 4;
error_index_exp = {};
error_freq_block = {};
%error_cents_block = zeros(nBlocks,trialsPerBlock*(numberOfNotes-1));
%error_freq_block = zeros(nBlocks,trialsPerBlock*(numberOfNotes-1));
for i=1:nBlocks
    m = csvread(['tony_files\block_',num2str(i),'_Alfonso_err.csv']);
    j=1;
    error_index_exp{i} = [];
    error_freq_block{i} = [];
    index = 1;
    for n=1:trialsPerBlock
        
        pitch_ref = m(index:index+numberOfNotes-1,2);
        index = index + numberOfNotes;
        bol=1;
        j=1;
        number_notes_play = 0;
        pitch_prod = [];
        error_index = [];
        while bol~=0
            %time_diff = m(index,1) - (m(index-1,1)+m(index-1,3));
            pitch_prod(j) = m(index+(j-1),2);
            j=j+1;
            error_index = [error_index 0]; 
            number_notes_play = number_notes_play + 1;
            if abs((m(index+(j-2),1) + m(index+(j-2),3))-m(index+(j-1),1))<0.01
                pitch_prod(j) = m(index+(j-1),2);
                j=j+1;
                error_index = [error_index 1]; 
            end
            if number_notes_play == numberOfNotes
                bol=0;  
            end
        end                  
        note_number = 1;
        for p=2:length(pitch_prod)
            if error_index(p) == 0
                note_number = note_number+1;
                error_freq_block{i} = [error_freq_block{i} freq2cents(pitch_prod(p)'/pitch_ref(note_number)')];
            else
                error_freq_block{i} = [error_freq_block{i} freq2cents(pitch_prod(p)'/pitch_ref(note_number)')];
            end
        end
        error_index_exp{i} = [error_index_exp{i} error_index(2:end)];
        while (m(index+(j-1),2)<198)
            j=j+1;
        end
        while (m(index+(j-1),2)>198) && (index+(j-1)) ~= length(m)
            j=j+1;
        end
        index = index + (j-1);
        
    end

end


aux_freq_block = cell2mat(error_freq_block);
index_error_corr = find([error_index_exp{:}]==1);
aux_freq_block(index_error_corr) = [];
error_10_index = find(abs(aux_freq_block)>10);
no_error_index = find(abs(aux_freq_block)<10);
vector_errors_10 = aux_freq_block(error_10_index);
vector_no_errors = aux_freq_block(no_error_index);
error_15_index = find(abs(aux_freq_block)>15);
vector_errors_15 = aux_freq_block(error_15_index);
error_20_index = find(abs(aux_freq_block)>20);
vector_errors_20 = aux_freq_block(error_20_index);
error_30_index = find(abs(aux_freq_block)>30);
vector_errors_30 = aux_freq_block(error_30_index);
error_40_index = find(abs(aux_freq_block)>40);
vector_errors_40 = aux_freq_block(error_40_index);
error_50_index = find(abs(aux_freq_block)>50);
vector_errors_50 = aux_freq_block(error_50_index);



index_error_no_corr = find([error_index_exp{:}]==0);
aux_freq_block = cell2mat(error_freq_block);
aux_freq_block(index_error_no_corr) = [];
