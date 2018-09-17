%
% define_music_globals.m
%
% Defines constants used by the whole parsing infrastructure.
%
% This is generally run first in most of the scripts in this collection.
%

sharp_key_names = {'c','c#','d','d#','e','f','f#','g','g#','a','a#','b'};
flat_key_names =  {'c','db','d','eb','e','f','gb','g','ab','b','bb','b'};

TRIAD_UNKNOWN = -1;
TRIAD_MAJOR = 0;
TRIAD_MINOR = 1;
TRIAD_DIMINISHED = 2;
TRIAD_AUGMENTED = 3;
TRIAD_SUSPENDED = 4;
NUM_TRIADS = 5;


triad_names = { 'maj', 'min', 'dim', 'aug', 'sus'  };

KEY_MAJOR = 0;
KEY_MINOR = 1;
NUM_KEYS = 2;

SYLLABLE_SINGLESYLLABLE = 0;
SYLLABLE_WORDBEGIN = 1;
SYLLABLE_WORDCONTINUATION = 2;
SYLLABLE_WORDEND = 3;

word_position_names = { 'single','begin','continue','end' };

all_triad_notes = {[0 4 7],
                   [0 3 7],
                   [0 3 6],
                   [0 4 8],
                   [0 5 7]};

all_key_notes = {[0 2 4 5 7 9 11],
                 [0 2 4 5 6 7 8 9 11]};
             
UNKNOWN_MODE_TAG = 'unknown';

