% ----------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------
% Last Updated 11/17/24
% created by by HANNAH LEE (hl4693@nyu.edu)
% Last update : 2023-11-17
% Project : NERD 
% Line 27: code sets up the framework for storing and organizing All Parameters (n=18) in a table format, 
% Line 181: parameter data from each trial is being stored in a table called tbl
% You can locate the parameters by their variable names (e.g., tbl.ExampleStart(tablerow)= GetSecs;)
% You can view the output from 'tbl' generated in the workspace
% Please Run the Script, Respond by either pressing A (Left) or L (Right),
% finish the entire trials or ESCAPE midway, and view 'tbl' outcome
 
setting = "MRI";
if setting == "MRI"
    screenside = ["Right", "Right", "Left", "Left"];
    condition = ["Risk","Ambiguity","Risk","Ambiguity"];
    ntrials = 2; % # of trials per each group of Risk or Ambiguity condition
    probability = [18, 35, 73];
    amount = [5, 10, 20, 35, 55];
elseif setting == "PRACTICE"    
    screenside = ["Left", "Right", "Right", "Left"];
    condition = ["Risk","Ambiguity","Risk","Ambiguity"];
    ntrials = 2; % # of trials per each group of Risk or Ambiguity condition
    probability = [18, 35, 73];
    amount = [5, 10, 20, 35, 55];
end    
    parames = [];%ALL relevant parameters will be stored under this 
    timedata = [];
    tbl = table('VariableNames', ["block", "condition", "screenside","choice","RiskLevel","trial","prob","amount",...
        "Cross_StimulusStart", "StimulusStart_Response","Response_FeedbackStart",...
        "WindowOpen","ExampleStart","CrossStart","StimulusStart","ResponseTime","FeedbackStart", "BreakStart"], ...
        'VariableTypes', ["double", "string", "string", "string", "string", "double","double","double",...
        "double","double","double",...
        "double","double","double","double","double","double","double"], ...
        'Size', [1, 18]); %18 parameters
    tablerow = 1;
 
 
Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference','VisualDebugLevel', 0);
PsychDefaultSetup(2);
try 
    screenNumber = max(Screen ('Screens'));
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    
    % Open an on screen window
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    tbl.WindowOpen(tablerow)= GetSecs;
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    ifi = Screen('GetFlipInterval', window);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 36);
    [xCenter, yCenter] = RectCenter(windowRect);
 
 
      
    % Size of fixation cross
    fixCrossDimPix = 40;
    % Coordinate of fixation cross
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
   
   TotalTrials = 0;
   
    for c = 1:numel(condition) % indexing from the condition array
        parames.condition = condition(c); 
        parames.screenside = screenside(c); % left or right or random options
        nrounds = ceil(ntrials/(numel(probability) * numel(amount))); %ceil: rounds up the integer
        Samples = Generate_Samples (probability, amount, nrounds); %create the table (prob x amount x rounds)
        wait_time = [1,2]; % 1s for now, adjust later
        responses = cell(ntrials,1); %to keep the record of key responses letters
        parames_example = parames; 
        parames_example.amount = amount(3);
        parames_example.probability = probability(2);
        
        parames_example.startAngleWOFGray = 0; 
        parames_example.startAngleWOFRed = (parames_example.probability/100)*360;
        parames_example.startAngleSOLIDGray = 0;
        parames_example.sizeAngleWOFGray = (parames_example.probability/100)*360;
        parames_example.sizeAngleWOFRed = 360-(parames_example.probability/100)*360;
        parames_example.sizeAngleSOLIDGray = 360;
        window=draw_wof(window, parames_example);
        [xCenter, yCenter] = RectCenter(windowRect);
        Screen('DrawText', window, 'Example', xCenter-.2*xCenter, yCenter-.8*yCenter, [255, 0, 0, 255]); %coordinates are manually put together
        Screen('Flip', window);
        tbl.ExampleStart(tablerow)= GetSecs;
%         WaitSecs(5)
        KeyName = CheckForEscape(5);
        if strcmp(KeyName,"ESCAPE") 
            return 
        end
        
        %     prev_sample = [0,0,0]; % placeholder for the real Sample
        for i=1:ntrials %for loop begins
            TotalTrials = TotalTrials+1;
            Screen('DrawLines', window, allCoords,...
                lineWidthPix, white, [xCenter yCenter], 2);
            Screen('Flip', window);
            tbl.CrossStart(tablerow)= GetSecs;
            KeyName = CheckForEscape(5);
            if strcmp(KeyName,"ESCAPE")
                return
            end
%             WaitSecs(5)
 
            Sample = Samples(i,:);
            parames.amount = Sample(3);
            parames.probability = Sample(2)/360;
            
            parames.startAngleWOFGray = 0;
            parames.startAngleWOFRed = Sample(2);
            parames.startAngleSOLIDGray = 0;
            parames.sizeAngleWOFGray = Sample(2);
            parames.sizeAngleWOFRed = 360-Sample(2);
            parames.sizeAngleSOLIDGray = 360;
 
            window=draw_wof(window, parames);
            Screen('Flip', window);
            tbl.StimulusStart(tablerow)= GetSecs;
            tbl.Cross_StimulusStart(tablerow) = tbl.StimulusStart(tablerow) - tbl.CrossStart(tablerow); 
            KeyName = '';
            tStart = GetSecs;
            KeyLog = []; %recording the key responses relative to the onset of the visual stimuli!
            while ~strcmp(KeyName,'a')&& ~strcmp(KeyName,'l') && ~strcmp(KeyName,'ESCAPE')
                Keyboard = GetKeyboardIndices();
                KbQueueCreate(Keyboard);
                KbQueueStart(Keyboard);
                tKey = GetSecs;
                tbl.ResponseTime(tablerow)= GetSecs;
                tbl.StimulusStart_Response(tablerow) = tbl.ResponseTime(tablerow) - tbl.StimulusStart(tablerow);
                KbStrokeWait(Keyboard, tKey + 1);
                ch = KbEventGet(Keyboard);
                if ~isempty(ch)
                    KeyName = KbName(ch.Keycode);
                    disp(KeyName)
                    KeyLog = vertcat(KeyLog, {i, KeyName,GetSecs - tStart,NaN}); %vertically concatenate (Get the trial time following the start)
                    if strcmp(KeyName,'ESCAPE')
                        Screen('CloseAll');
                        return;
                    end
                end
                FlushEvents();
                tCurrent = GetSecs;
                if tCurrent - tStart >= 9
                    break
                end
            end
            
            [window,SquareRectLeft,SquareRectRight]=draw_wof(window, parames);
            
            if KeyName == 'a'
                Screen('FrameRect', window, [0 200 0], SquareRectLeft,3);
                random_choice = random("Binomial",1,parames.probability);
                KeyLog {end,4} = random_choice;
                tbl.choice(tablerow) = "Left";
%                 tbl.Keychoice(tablerow) = KeyName;
            elseif KeyName == 'l'
                Screen('FrameRect', window, [0 200 0], SquareRectRight,3);
                tbl.choice(tablerow) = "Right";
%                 tbl.Keychoice(tablerow) = KeyName;
            end
            if tbl.choice(tablerow) == parames.screenside
                tbl.RiskLevel(tablerow) = "Risky";
            elseif ~(tbl.choice(tablerow) == parames.screenside) && ~ismissing(tbl.choice(tablerow))
                tbl.RiskLevel(tablerow) = "Safe";
            end
            
            Screen('Flip', window);
            tbl.FeedbackStart(tablerow)= GetSecs;
            tbl.Response_FeedbackStart(tablerow) = tbl.FeedbackStart(tablerow) - tbl.ResponseTime(tablerow);
            WaitSecs(5);
            
           
            ShowCursor;
            %     psychrethrow(psychlasterror);
            % data from each trial is being stored in a table called tbl 
            tbl.block(tablerow) = c; %save parameters for each trial in a table format
            tbl.condition(tablerow) = parames.condition;
            tbl.screenside(tablerow) = parames.screenside;
            tbl.trial(tablerow) = i;
            tbl.prob(tablerow) = parames.probability;
            tbl.amount(tablerow) = parames.amount;
            % tbl.
            tablerow = tablerow+1;
        end
        
        if TotalTrials == 4% Black Screen (Break Point)
            Screen('DrawLines', window, allCoords,...
                lineWidthPix, black, [xCenter yCenter], 2);
            Screen('Flip', window);
            tbl.BreakStart(tablerow) = GetSecs;
            KeyName = CheckForEscape(5);
            if strcmp(KeyName,"ESCAPE")
                return
            end
        end
    end
    sca; %close all the screens
   
catch % 
  
    sca; 
    psychrethrow(psychlasterror);
end
 
%pre-allocate = faster processing
function Samples=Generate_Samples(Probs,Amounts,nrounds)% create a nested for loop
nsamples = numel(Probs)*numel(Amounts)*nrounds; % number of rows = combinations * number of rounds
Sample_num = 0; %initializing the variables
Samples=zeros(nsamples,3); %1st:sample index (number) 2nd: Probs 3rd: Amounts
for r = 1:nrounds % for each probxamount comb * nrounds times (=4)
    for p = Probs %take all the values in Probs
        for a = Amounts %take all the values in Amounts
            Sample_num = Sample_num+1;
            Samples(Sample_num,:)=[Sample_num,p,a]; %selecting all the columns
        end
    end
end
both_zeros = ones(nsamples,1);% vector: nsamples row %pre-allocate
while any(both_zeros)
    rand_samples = Samples(randperm(nsamples),:); % gen rand perm 1 ~ 60
    diff_samples = diff(rand_samples(:,2:3),1,1); % (only on the columns probs & amt),default,1st column
    both_zeros = all(diff_samples == 0,2);
end
Samples = rand_samples;
Samples(:,2) = (Samples(:,2)./100).*360; %probs to degrees
end
 
function [window,SquareRectLeft,SquareRectRight]=draw_wof(window, parames)
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
CircleRect = [0 0 screenXpixels/4 screenXpixels/4];
CircleRectAmb = [0 0 screenXpixels/3.75 screenXpixels/3.75];%by diameter
SquareRect = 1.1.*CircleRect;%element wise multiplication (place dots avoid default matrix multiplications)
LabelRect = [0 0 screenXpixels/10 screenXpixels/12]; %label
xCenter1 = screenXpixels/4;
xCenter2 = (screenXpixels/4)*3;
yCenter = screenYpixels/2;
CircleRectLeft = CenterRectOnPointd(CircleRect, xCenter1, yCenter);
SquareRectLeft = CenterRectOnPointd(SquareRect, xCenter1, yCenter);
CircleRectAmbLeft = CenterRectOnPointd(CircleRectAmb, xCenter1, yCenter);
CircleRectAmbRight = CenterRectOnPointd(CircleRectAmb, xCenter2, yCenter);
CircleRectRight = CenterRectOnPointd(CircleRect, xCenter2, yCenter);
SquareRectRight = CenterRectOnPointd(SquareRect, xCenter2, yCenter);
LabelLeftLeft = CenterRectOnPointd(LabelRect, xCenter1-CircleRect(3)/4, yCenter*1.7); 
LabelLeftRight = CenterRectOnPointd(LabelRect, xCenter1+CircleRect(3)/4, yCenter*1.7);
LabelRightLeft = CenterRectOnPointd(LabelRect, xCenter2-CircleRect(3)/4, yCenter*1.7);
LabelRightRight = CenterRectOnPointd(LabelRect, xCenter2+CircleRect(3)/4, yCenter*1.7);
LabelLeft = CenterRectOnPointd(LabelRect, xCenter1, yCenter*1.7);
LabelRight = CenterRectOnPointd(LabelRect, xCenter2, yCenter*1.7);
HideCursor;
 
% define colors
white = WhiteIndex(window) ;
gray = white/2;
darkgray = white/4;
red = [200 0 0] ;
green = [0 200 0];
 
% Clear screen to black background:
Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);
if parames.screenside == "random"
    randomchoice = randi(2,1); %1 = left; 2 = right/ for each trial
    if randomchoice == 1
        screenside = "Left";
    elseif randomchoice == 2
        screenside = "Right";
    end
else
    screenside = parames.screenside;
end
if screenside == "Left"
    CircleRectWOF = CircleRectLeft;
    CircleRectSOLID = CircleRectRight;
    CircleRectAmbWOF = CircleRectAmbLeft;
    LabelWOFLeft = LabelLeftLeft;
    LabelWOFLeftText = LabelLeftLeft.*[1.2,1.05,1,1];
    LabelWOFRight = LabelLeftRight;
    LabelWOFRightText = LabelLeftRight.*[1.08,1.05,1,1];
    LabelSOLID = LabelRight;
    LabelSOLIDText = LabelRight.*[1.03,1.05,1,1];
elseif screenside == "Right"
    CircleRectWOF = CircleRectRight;
    CircleRectSOLID = CircleRectLeft;
    LabelWOFLeftText = LabelRightLeft.*[1.04,1.05,1,1];
    %     LabelWOFLeftText = LabelRightLeft;
    LabelWOFRightText = LabelRightRight.*[1.02,1.05,1,1];
    %     LabelWOFRightText = LabelRightRight;
    LabelSOLIDText = LabelLeft.*[1.03,1.05,1,1];
    CircleRectAmbWOF = CircleRectAmbRight;
    LabelWOFLeft = LabelRightLeft;
    LabelWOFRight = LabelRightRight;
    LabelSOLID = LabelLeft;
end
 
% Draw filled arcs:
Screen('FillArc',window, gray,CircleRectSOLID,parames.startAngleSOLIDGray,parames.sizeAngleSOLIDGray);
if parames.condition == "Risk"
    Screen('FillArc',window, red,CircleRectWOF,parames.startAngleWOFRed,parames.sizeAngleWOFRed);
    Screen('FillArc',window, gray,CircleRectWOF,parames.startAngleWOFGray,parames.sizeAngleWOFGray);
elseif parames.condition == "Ambiguity"
    Screen('FillArc',window, gray,CircleRectWOF,0,180);
    Screen('FillArc',window, red,CircleRectWOF,180,180);
    Screen('FillArc',window, darkgray,CircleRectAmbWOF,120,120); %ambiguity WOF
end
Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 50);
Screen('TextStyle', window, 1+2);
Screen('FillRect', window, red, LabelWOFLeft) ;
Screen('FillRect', window, gray, LabelWOFRight);
Screen('FillRect', window, gray, LabelSOLID);
Screen('DrawText', window, '$0', LabelWOFLeftText(1),LabelWOFLeftText(2), [0, 0, 255, 255]);
Screen('DrawText', window, sprintf('$%i',parames.amount), LabelWOFRightText(1), LabelWOFRightText(2), [0, 0, 255, 255]);
Screen('DrawText', window, '$5', LabelSOLIDText(1), LabelSOLIDText(2), [0, 0, 255, 255]);
% Screen('FrameRect', window, [0 200 0], SquareRectRight);
end
 
function KeyName = CheckForEscape(time)
KeyName = ""; 
tStart = GetSecs;
while ~strcmp(KeyName, "ESCAPE")
Keyboard = GetKeyboardIndices();
KbQueueCreate(Keyboard);
KbQueueStart(Keyboard);
tKey = GetSecs;
KbStrokeWait(Keyboard, tKey + 1);
ch = KbEventGet(Keyboard);
if ~isempty(ch)
    KeyName = KbName(ch.Keycode);
    disp(KeyName)
    if strcmp(KeyName,'ESCAPE')
        Screen('CloseAll');
        return;
    end
end
 
FlushEvents();
tCurrent = GetSecs;
if tCurrent - tStart >= time
    break
end
end
end 
 
 

