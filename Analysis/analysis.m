m = csvread('audio_1.csv');

numberOfNotes = 4;

ref = 1;
play = 0;
passive = 0;
n_ref=1;
n_play = 1;
note_play = 1;
n_passive = 1;
pitch_ref = zeros(numberOfNotes,1);
first_time_play = 1;
j=1;

for i=1:length(m)
    % Save pitch reference
    if ref == 1
        pitch_ref(j) = m(i,2);
        j=j+1;
        %If we have already saved all the references notes
        % we continue through the next section in the next
        %iteration
        if j>numberOfNotes
            ref = 0;
            play = 1;
            j=1; 
        end
    else
        %Save play reference notes
        if play==1
            %if it is the first time we enter, we just compare
            %error cents with the first pitch_ref note and save it
            %in pitch_play
            if first_time_play == 0
                %First, we check that the note we are reading
                % is a new one and not the result of a correction
                % due to an error with the violin. We use time for that
                time_diff = m(i,1) - (m(i-1,1)+m(i-1,3));
                if time_diff > 0.05
                    note_play = note_play + 1;
                end
            else
                first_index = n_play;
            end
            %If we have already saved all the notes, we go through
            %the next section
            if note_play == 5
                play = 0;
                passive = 1;
                first_time_play = 1;
                note_play = 1;
                n_trials = n_play - first_index;
            else
                error_cents(n_play) = freq2cents(m(i,2)/pitch_ref(note_play));
                pitch_play(n_play) = m(i,2);
                n_play = n_play+1;
                first_time_play = 0;
            end
                
                
        end
        if passive == 1
            n_passive = n_passive + 1;
            if n_passive > n_trials
                n_passive = 1;
                passive = 0;
                ref = 1;
                pitch_ref = zeros(numberOfNotes,1);
            end
        end
    end
            
end
