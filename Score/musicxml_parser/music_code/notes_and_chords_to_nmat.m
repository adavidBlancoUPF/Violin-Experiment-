%
% function nmat = notes_and_chords_to_nmat(notes,chords,tempo_bpm)
%
% Converts notes and chords as output by get_notes_and_chords to
% a midi toolbox note matrix, suitable for playback.
%
% You can also call notes_and_chords_to_nmat(notes,chords,tempo_bpm,beats)
% to add a beat track.
%
function [notes_nmat,chords_nmat,merged_nmat] = notes_and_chords_to_nmat(notes,chords,chord_names,tempo_bpm,varargin)

% fprintf(1,'Warning: I haven''t handled chord synthesis yet...\n');
% fprintf(1,'Warning: nmat creation assumes 4/4 time\n');

% Extract the beat matrix.
if (length(varargin) == 1)
    beats = varargin{1};
else
    beats = zeros(0,2);
end

% First build the notes nmat

nnotes = size(notes,1);

notes_nmat = zeros(nnotes,7);

% Onset (beats)
notes_nmat(:,1) = notes(:,1);

% Duration (beats)
notes_nmat(:,2) = (notes(:,2)-notes(:,1));

% MIDI channel
notes_nmat(:,3) = 2*ones(nnotes,1);

% MIDI pitch
notes_nmat(:,4) = midi_note_number_from_index_and_octave(notes(:,3),notes(:,4));

% MIDI velocity
notes_nmat(:,5) = ones(nnotes,1) * 127;

% Onset (s)
notes_nmat(:,6) = notes_nmat(:,1) * 60 / tempo_bpm;

% Duration (s)
notes_nmat(:,7) = notes_nmat(:,2) * 60 / tempo_bpm;


% Now the chords nmat

nchords = size(chords,1);

n_chord_notes = 0;
chords_nmat = [];

% Is there a good way to vectorize this?
for(i=1:nchords)
   
   % Get the notes for this chord, in the right octave
   chord_notes = get_chord_notes(chords(i,3),chords(i,4),chord_names{i});
   chord_notes = chord_notes(:);
   
   % Stick them in our chord note matrix
   n_notes_in_chord = length(chord_notes);
   
   % MIDI onset
   chords_nmat(n_chord_notes+1:n_chord_notes+n_notes_in_chord,1) = chords(i,1);
   
   % MIDI duration
   chords_nmat(n_chord_notes+1:n_chord_notes+n_notes_in_chord,2) = (chords(i,2)-chords(i,1));
   
   % MIDI pitch
   chords_nmat(n_chord_notes+1:n_chord_notes+n_notes_in_chord,4) = chord_notes;

   % Update the number of chord notes so far
   n_chord_notes = n_chord_notes+n_notes_in_chord;
end

% MIDI channel
chords_nmat(:,3) = 1;
   
% MIDI velocity
chords_nmat(:,5) = 80;

% Onset (s)
chords_nmat(:,6) = chords_nmat(:,1) * 60 / tempo_bpm;

% Duration (s)
chords_nmat(:,7) = chords_nmat(:,2) * 60 / tempo_bpm;

% Now do the beats

nbeats = size(beats,1);

beats_nmat = zeros(nbeats,7);

% Onset (beats)
beats_nmat(:,1) = beats(:,1);

% Duration (beats)
beats_nmat(:,2) = 1;

% MIDI channel
beats_nmat(:,3) = 10*ones(nbeats,1);

% MIDI pitch
% not sure what to do with this
j_first = find(beats(:,2) == 1);
j_notfirst = find(beats(:,2) ~= 1);
beats_nmat(j_first,4) = 36;
beats_nmat(j_notfirst,4) = 37;

% MIDI velocity
%kill drums for now
beats_nmat(:,5) = zeros(nbeats,1);
%beats_nmat(:,5) = ones(nbeats,1) * 64;

%remove non-first beats
beats_nmat(j_notfirst,5) = 0;

% Onset (s)
beats_nmat(:,6) = beats_nmat(:,1) * 60 / tempo_bpm;

% Duration (s)
beats_nmat(:,7) = beats_nmat(:,2) * 60 / tempo_bpm;

% Merge these three matrices
merged_nmat = [notes_nmat; chords_nmat; beats_nmat];

% Sort the merged note matrix by onset
onsets = merged_nmat(:,1);
[sorted_onsets,indices] = sort(onsets);
merged_nmat = merged_nmat(indices,:);
