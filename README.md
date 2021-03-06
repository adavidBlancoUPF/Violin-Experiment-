# Violin-Experiment-
This repository contains the code used for the EEG experiments that are being carried out in close collaboration between the Brainlab (UB) and the MTG (UPF). 

# Brief Description:

In Score we have all the code used for the generation of the scores that we show to the participants. 
The output of "generate_scores.m" is saved in the folder called "New_generated_scores" in musicxml format. We used MuseScore to
convert the xml files to images in png. 

In Max_code we have the software developed in Max to process the sound in real-time during the experiment (pitch shifting).  

In Violin_Sample_sounds we have all the code used for the generation of the melodies that participants hear as reference in our
experiment. The reference sound used to create the melodies was a G3 with a length of 0.25seg, played Mezzo-Forte with arco normal 
acquired from here: 
https://www.philharmonia.co.uk/explore/sound_samples/violin&filter_pitch=G3&filter_articulation= 
The sound was later processed with Audacity to generate the rest of the notes that will compose the melodies (7 semitones in total, 
from G to D) using the Sliding Time Scale/Pitch Shift tool. In this way, we achieved more homogeneity in the timbre and loudness of 
each note presented to the participants. Melodies are later generated by permutation of notes inside different musical modes (dorian,
aeolian, myxolidian...). 

Finally, in Screen we have the code for the commands that will appear in the visual screen of participants developed using Psychtoolbox.


