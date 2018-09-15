Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference', 'ConserveVRAM', 64)
%% SETTINGS

%%%%% Paths %%%%%
image_path = 'Escalas\Escala';

%%%%% Screen settings %%%%%
backcolor = [255 255 255]; % color for display window background: black.
textcolor = [0 0 0]; % color for text: white
redcolor = [255 0 0];
rect = [0 0 1400 700];
textfontsize = 20;
textfont = 'Arial';
countdownfontsize = 50;

screens = Screen('Screens');
screenNumber = 2;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window using PsychImaging and color it grey.
[EXPWIN, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% open the display window with the defined parameters:
%EXPWIN = Screen('OpenWindow',0,backcolor,rect); % Open fullscreen

% specify a font for any text that is written in this display window
Screen('TextSize', EXPWIN, textfontsize); % set text size for this display
Screen('TextFont', EXPWIN, textfont); % set the text font for this display
%%%%% Sound settings %%%%%
fs = 44100; % sampling frequency for the sound generated, in Hz (usually 44100Hz) - also called "sampling rate"
clickDur = 0.0001; % duration of click in seconds
amplitude = 10000;
click = ones(1,round(clickDur*fs)).*amplitude;
click = [click; click]; % make stereo

% Start audio device
InitializePsychSound; % Initialize the sound device
paHandle = PsychPortAudio('Open'); % Open the Audio port and get a handle to refer to it in subsequent calls
% [6 7] are the headphones channels in the lab
buffer(1) = PsychPortAudio('Createbuffer',paHandle,click);
PsychPortAudio('FillBuffer', paHandle,buffer(1)); % Fill the audio buffer with click

if screenNumber == 1
    %%% Drawing arrow and text settings in 16:9 screens
    init_x_arr = 230;
    first_x_arr = 340;
    last_x_arr = 1120;
    y_arr     = 300;
    instructions_text = 700;
    countdownText = 550;
    countdownNumberText = 600;
end
if screenNumber == 2
    %%% Drawing arrow and text settings in 4:3 screens
    init_x_arr = 185;
    first_x_arr = 305;
    last_x_arr = 1075;
    y_arr     = 430;
    instructions_text = 1003;
    countdownText = 788;
    countdownNumberText = 860;
end



%%%%% Block settings %%%%%
nTrials = 2;%8
nNotes  = 8;
nCountdown = 5;
Playdur = 25; % Time in seconds we give them to play each scale 25s
ClickSOA = 1; % Time in seconds between clicks
Instruction1 = 'Please, play the following melodies with staccato \n\n use the countdown as a reference for the tempo \n\n\n\n\n\n Press any key to start';
Instruction2 = 'Listen';
Instruction3 = 'Ready!';
Instruction4 = 'GO!';
Instruction5 = 'End of Trial';
Instruction6 = 'Stop!';
Instruction7 = 'Get ready to play in:';

%%% arrow points
val_arrow = linspace(first_x_arr,last_x_arr, nNotes);
val_arrow = [init_x_arr,val_arrow];


%% Experiment Start
TrialTimes = [];
ClickTimes = {};

%%%%% Initial instructions %%%%%

% draw the text in the display backbuffer.
DrawFormattedText(EXPWIN, Instruction1, 'center', 'center',textcolor); % draw the question centered

% Show the instructions
Screen('Flip', EXPWIN);

% Wait for a keyboard key press to start block
KbPressWait;

%%%%% Trial loop %%%%%
%(Trial = 1 escala completa)
tStart = GetSecs;
ClickTime = GetSecs;

disp("Había que añadir esta linea y solo esta linea para funcionar");

for iTrial=1:nTrials
    %Send Click
    ClickTime = PsychPortAudio('Start', paHandle,1,ClickTime+ClickSOA,1); % Play sound immediately
    
    % Show melody to be played
    image_path = [num2str(iTrial) '.jpg'];
    pict = imread(image_path);
    pict = imresize(pict,0.5);
    t_handle = Screen('MakeTexture',EXPWIN,pict);
    %Screen('DrawTexture',EXPWIN,t_handle);
    instructions = 'Listen to the scale';
    textfontsize = 50;
    Screen('TextSize', EXPWIN, textfontsize);
    %DrawFormattedText(EXPWIN, instructions, 'center', 700,textcolor); % draw the question centered
    
    
   
    for sec=1:length(val_arrow)       
        % create a triangle
        head   = [ val_arrow(sec), y_arr ]; % coordinates of head
        width  = 10;           % width of arrow head
        points = [ head-[width,0]         % left corner
                   head+[width,0]         % right corner
                   head+[0,width] ];      % vertex
        
        
        Screen('DrawTexture',EXPWIN,t_handle);
        Screen('FillPoly', EXPWIN,[200,0,0], points);
        DrawFormattedText(EXPWIN, instructions, 'center', instructions_text,textcolor); % draw the question centered
        if sec > nCountdown
            DrawFormattedText(EXPWIN, Instruction7, 'center', countdownText,textcolor);
            DrawFormattedText(EXPWIN, num2str((nNotes+3)-sec), 'center', countdownNumberText,redcolor);
        end
        Screen('Flip', EXPWIN);
        WaitSecs(1);
    end
    
    
    tStart = GetSecs;
    ClickTime = GetSecs;
    
    %ClickTime = PsychPortAudio('Start', paHandle,1,ClickTime+ClickSOA,1); % Play sound immediately
    Screen('DrawTexture',EXPWIN,t_handle);
    DrawFormattedText(EXPWIN, Instruction7, 'center', countdownText,textcolor);
    DrawFormattedText(EXPWIN, num2str(1), 'center', countdownNumberText,redcolor); % draw the question centered
    
    Screen('Flip', EXPWIN);
    WaitSecs(1);
    
    Screen('DrawTexture',EXPWIN,t_handle);
    ClickTime = PsychPortAudio('Start', paHandle,1,ClickTime+ClickSOA,1); % Play sound immediately
    DrawFormattedText(EXPWIN, Instruction4, 'center', countdownNumberText,textcolor); % draw the question centered
    
    Screen('Flip', EXPWIN);
    WaitSecs(nNotes);
    
    Screen('DrawTexture',EXPWIN,t_handle);
    ClickTime = PsychPortAudio('Start', paHandle,1,ClickTime+ClickSOA,1); % Play sound immediately
    DrawFormattedText(EXPWIN, Instruction6, 'center', countdownNumberText,textcolor); % draw the question centered
    
    Screen('Flip', EXPWIN);
    WaitSecs(1);
      
    Screen('DrawTexture',EXPWIN,t_handle);
    ClickTime = PsychPortAudio('Start', paHandle,1,ClickTime+ClickSOA,1); % Play sound immediately
    DrawFormattedText(EXPWIN, Instruction2, 'center', countdownNumberText,textcolor); % draw the question centered
    
    Screen('Flip', EXPWIN);
    WaitSecs(nNotes);
    
    
end

DrawFormattedText(EXPWIN, 'Fin de bloque', 'center', 'center',textcolor); % draw the question centered
Screen('Flip', EXPWIN);
WaitSecs(2);

%% Cleanup
Screen('Close',EXPWIN); % close the display window
PsychPortAudio('Close'); % Close the audio device
sca;

% %% Save log
% logname =[sprintf('%02d',iSub) '_' sprintf('%02d',iBlock)];
% logfile.TrialTimes = TrialTimes;
% logfile.ClickTimes = ClickTimes;
% save(logname,'logfile');
% 



