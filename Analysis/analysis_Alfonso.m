

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

mean_blocks = mean(abs(error_freq_block),2);
std_blocks = std(abs(error_freq_block),[],2);


mean_blocks_mod = mean(abs(error_freq_block_mod),2);
std_blocks_mod = std(abs(error_freq_block_mod),[],2);

mean_blocks_jonico = mean_blocks(1:5:end);
std_blocks_jonico = std_blocks(1:5:end);

mean_blocks_eolico = mean_blocks(2:5:end);
std_blocks_eolico = std_blocks(2:5:end);

mean_blocks_frigio = mean_blocks(3:5:end);
std_blocks_frigio = std_blocks(3:5:end);

mean_blocks_lidio = mean_blocks(4:5:end);
std_blocks_lidio = std_blocks(4:5:end);

mean_blocks_locrio = mean_blocks(5:5:end);
std_blocks_locrio = std_blocks(5:5:end);

mean_blocks_1 = ([mean_blocks_jonico(1:4), mean_blocks_eolico, mean_blocks_frigio,...
    mean_blocks_lidio, mean_blocks_locrio]);
std_blocks_1 = ([std_blocks_jonico(1:4), std_blocks_eolico, std_blocks_frigio,...
    std_blocks_lidio, std_blocks_locrio]);
mean_5_blocks = mean(mean_blocks_1,2);
std_5_blocks = std(std_blocks_1,[],2);

mean_5_modes = mean(mean_blocks_1,1);
std_5_modes = std(std_blocks_1,[],1);

bar_names = ['Block1','Block2', 'Block3', 'Block4'];
bar_names_jonico = ['Results for Jonico'];
bar_names_eolico = ['Results for Eolico'];
bar_names_frigio = ['Results for Frigio'];
bar_names_lidio = ['Results for Lidio'];
bar_names_locrio = ['Results for Locrio'];


errorbar_groups(mean_blocks_jonico,std_blocks_jonico,'bar_names',bar_names_jonico)

errorbar_groups(mean_blocks_eolico,std_blocks_eolico,'bar_names',bar_names_eolico)

errorbar_groups(mean_blocks_frigio,std_blocks_frigio,'bar_names',bar_names_frigio)

errorbar_groups(mean_blocks_lidio,std_blocks_lidio,'bar_names',bar_names_lidio)

errorbar_groups(mean_blocks_locrio,std_blocks_locrio,'bar_names',bar_names_locrio)

errorbar_groups(mean_5_blocks, std_5_blocks,'bar_names','time')

errorbar_groups(mean_5_modes', std_5_modes','bar_names','Mode')



errorbar_groups([mean(mean_blocks_mod), mean(mean_blocks)]',[mean(std_blocks_mod), mean(std_blocks)]');