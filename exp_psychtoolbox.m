classdef exp_psychtoolbox < handle
    properties
        font
        color
        window
        keyhistory
        istest
         sound
        
        pahandle
        sampleRate
        nrchannels
        reqlatencyclass
        correctSound

    end
    methods
        function obj = exp_psychtoolbox()
            obj.istest = false;
            PsychDefaultSetup(2);
            obj.setup_font;
            obj.setup_color;
            obj.keyhistory.n = 0;
%             obj.initializePsychToolboxSound;
        end
        function setup_keylist(obj, KL)
            disp('restricting keys');
            RestrictKeysForKbCheck(KL);
        end
        function setup_font(obj, fontsize, fontcolor, fonttype, fontwrapat, fontstyle)
            if nargin < 6 || isempty(fontstyle)
                font.fontstyle = 0;
            else
                font.fontstyle = fontstyle;
            end
            if nargin < 5 || isempty(fontwrapat)
                font.fontwrapat = 70;
            else
                font.fontwrapat = fontwrapat;
            end
            if nargin < 4 || isempty(fonttype)
                font.fonttype = 'Arial';
            else
                font.fonttype = fonttype;
            end
            if nargin < 3 || isempty(fontcolor)
                font.fontcolor = [1 1 1];
            else
                font.fontcolor = fontcolor;
            end
            if nargin < 2 || isempty(fontsize)
                font.fontsize = 40;
            else
                font.fontsize = fontsize;
            end
            obj.font = font;
        end
        function setup_color(obj)
            colors.AZred = [171,5,32]/256;
            colors.AZblue = [12,35,75]/256;
            colors.AZcactus = [92, 135, 39]/256;
            colors.AZsky = [132, 210, 226]/256;
            colors.AZriver = [7, 104, 115]/256;
            colors.AZsand = [241, 158, 31]/256;
            colors.AZmesa = [183, 85, 39]/256;
            colors.AZbrick = [74, 48, 39]/256;
            colors.lightred = 0.5*colors.AZred + 0.5*ones(1,3);
            colors.lightblue = 0.5*colors.AZblue + 0.5*ones(1,3);
            colors.lightsky = 0.5*colors.AZsky + 0.5*ones(1,3);
            colors.lightcactus = 0.5*colors.AZcactus + 0.5*ones(1,3);
            colors.black = [0 0 0];
            colors.white = [1 1 1];
            obj.color = colors;
        end
        function setup_window(obj, window, windowmode, color_background, synctest)
            if nargin < 2
                window = [];
            end
            if nargin < 3
                windowmode = [];
            end
            if nargin < 4
                color_background = obj.color.black;
            end
            if ~isempty(window)
                obj.window = window;
            else
                screens = Screen('Screens');
                screenNumber = max(screens);
                
                
                Screen('Preference', 'SkipSyncTests', 1);
                window.synctest = 0;
                [window.id window.windowRect] = PsychImaging('OpenWindow', screenNumber, color_background, windowmode);
                [window.w window.h] = Screen('WindowSize', window.id);
                [center.x center.y] = RectCenter(window.windowRect);
                window.center = center;
                obj.window = window;
                obj.reset_size(window.h);
                Screen('TextFont', window.id, obj.font.fonttype);
                Screen('TextSize', window.id, obj.font.fontsize);
                Screen('TextStyle', window.id, obj.font.fontstyle);
                Screen('TextColor', window.id, obj.font.fontcolor);
            end
        end
        function reset_size(obj, winh)
            obj.window.scalefactor = winh/1080;
            obj.font.fontsize = round(obj.font.fontsize * obj.window.scalefactor);
        end
        function time = flip(obj)
            time = Screen('Flip',obj.window.id);
        end
        function time = talkAndflip(obj, str, option, fontsize, windowrect)
            if nargin == 5
                obj.talk(str, option, fontsize, windowrect);
            elseif nargin == 4
                obj.talk(str, option, fontsize);
            elseif nargin == 3
                obj.talk(str, option);
            elseif nargin == 2
                obj.talk(str);
            else
            end
            time = obj.flip;
        end
        function talk(obj, str, option, fontsize, windowrect, fontcolor)
            if nargin < 6
                fontcolor = obj.font.fontcolor;
            end
            if nargin == 1
                return;
            end
            if nargin < 5
                windowrect = [0 0 obj.window.w obj.window.h];
            end
            if nargin >= 4 && ~isempty(fontsize)
                oldTextSize = Screen('TextSize', obj.window.id);
                Screen('TextSize', obj.window.id, fontsize);
            end
            if nargin <= 2 || isempty(option)
                option = 'default';
            end
            w = obj.window.w;
            h = obj.window.h;
            switch option
                case 'default'
                    DrawFormattedText(obj.window.id, str, ...
                        'center', 'center', fontcolor, obj.font.fontwrapat);
                case 'instructions'
                    DrawFormattedText(obj.window.id, str, ...
                        0.05*w, 0.07*h, fontcolor, obj.font.fontwrapat);
                case 'pageturner'
                    DrawFormattedText(obj.window.id, ...
                        'Press space to continue or delete to go back', ...
                        'center', 0.93*h, fontcolor, obj.font.fontwrapat);
                case 'pagenumber'
                    DrawFormattedText(obj.window.id, ...
                        ['Page ' num2str(str(1)) ' of ' num2str(str(2))], ...
                        [w*0.05],[h*0.93], fontcolor, obj.font.fontwrapat);
                case 'window'
%                     windowrect = round(windowrect);
                    DrawFormattedText(obj.window.id, ...
                        str,'center', 'center', fontcolor, ...
                        obj.font.fontwrapat, 0, 0, 1, 0, windowrect);
                case 'arbitrary'
                    xx = windowrect(1);
                    yy = windowrect(2);
                     DrawFormattedText(obj.window.id, str, ...
                        'center', yy*h, fontcolor, obj.font.fontwrapat);

            end
            if exist('oldTextSize')
                Screen('TextSize', obj.window.id, oldTextSize);
            end
        end
        function playsound(obj)
                        obj.initializePsychToolboxSound;

            toneCorrect = MakeBeep(1000, 0.1, obj.sampleRate);
            obj.correctSound(1,:) = toneCorrect*0.5;
            obj.correctSound(2,:) = toneCorrect*0.5;
            obj.setSound(obj.correctSound);
            obj.playSound;
        end        
        function setSound(obj, sound)
            obj.sound = sound;
        end
           function initializePsychToolboxSound(obj)
            
            InitializePsychSound(1);
            
            % Request latency mode 2, which used to be the best one in
            % our measurement: classes 3 and 4 didn't yield any
            % improvements, sometimes they even caused problems.
            % class 2 empirically the best, 3 & 4 == 2
            reqlatencyclass = 2;
            
            % Sampling rate. Must set this. 96khz, 48khz, 44.1khz.
            obj.sampleRate = 44100;
            
            % Open the default audio device [], with default mode []
            % (==Only playback), and a required latencyclass of zero
            % 0 == no
            % low-latency mode, as well as a frequency of freq and
            % nrchannels sound channels.  This returns a handle to the
            % audio device:
            nrchannels = 2;
            
            obj.pahandle = PsychPortAudio('Open', ...
                [], [], reqlatencyclass, ...
                obj.sampleRate, nrchannels);
            % reqlatencyclass - minimize latency vs syste load;
            % how accurate is the timing?
            % set to 2, take full control over the audio device, even if
            % this cuases other sound apps to fail or shutdown
            
            
        end
        function [soundOn, soundOff] = playSound(obj, onTime)
            if ~exist('onTime')
                onTime = 0;
            end
            reqlatencyclass = obj.reqlatencyclass;
            sampleRate      = obj.sampleRate;
            nrchannels      = obj.nrchannels;
            pahandle        = obj.pahandle;
            
            % Fill buffer with data:
            PsychPortAudio('FillBuffer', pahandle, obj.sound);
            
            % Start the playback engine with an infinite start
            % deadline, i.e., start hardware, but don't play sound:
            PsychPortAudio('Start', pahandle, 1, inf, 0);
            
            % Play sound
            PsychPortAudio('RescheduleStart', pahandle, onTime, 0);
            
            % Stop playback - NOT NECESSARY
            [soundOn, SoundEndPosSecs, SoundXruns, soundOff] ...
                = PsychPortAudio('Stop', pahandle, 1);
            
        end

        function [KeyNum, when, deltawhen] = waitForInput(obj, validkeys, timeout, delay)
            if nargin < 4
                delay = 0.2;
            end
            if nargin < 3
                timeout = inf;
            end
            Pressed = 0;
            time_0 = GetSecs();
            while ~Pressed && (GetSecs - time_0 < timeout)
                [Pressed, when, KeyNum, deltawhen] = KbCheck;
                KeyNum = [find(KeyNum)];
                if length(KeyNum) == 4 || sum(ismember(KeyNum, KbName({'s','c','a','p'}))) == 4
                    sca;
                    pause;
                end
                if length(KeyNum) ~= 1 || ~ismember(KeyNum,validkeys)
                    Pressed = 0;
                end
                if length(KeyNum) == 1
                    obj.keyhistory.n = obj.keyhistory.n + 1;
                    obj.keyhistory.pressed(obj.keyhistory.n) = Pressed;
                    obj.keyhistory.when(obj.keyhistory.n) = when;
                    obj.keyhistory.KeyNum{obj.keyhistory.n} = KeyNum;
                    obj.keyhistory.deltawhen(obj.keyhistory.n) = deltawhen;
                    obj.keyhistory.validkeys{obj.keyhistory.n} = validkeys;
                end
            end
            if ~Pressed
                KeyNum = [];
                when = [];
                deltawhen = [];
            end
            WaitSecs(delay);
        end
        function [KeyNum, when, deltawhen, KeyCode] = waitForInputrelease(obj, validkeys, timeout, delay)
            if nargin < 4
                delay = 0.2;
            end
            if nargin < 3
                timeout = inf;
            end
            Pressed = 0;
            History = [];
            time_0 = GetSecs();
            while (Pressed~=-1) && (GetSecs - time_0 < timeout)
                [Pressed, when, KeyNum, deltawhen] = KbCheck;
                KeyNum = [find(KeyNum)];
                if length(KeyNum) == 4 || sum(ismember(KeyNum, KbName({'s','c','a','p'}))) == 4
                    sca;
                    pause;
                end
                if length(KeyNum) == 0
                    Pressed = 0;
                end
                if sum(ismember(KeyNum,validkeys) == 0) > 0
                    Pressed = 2;
                end
                if Pressed == 1 && length(KeyNum) == 1
                    History = KeyNum;
                    historywhen = when;
                    historydeltawhen = deltawhen;
                end
                if length(KeyNum) == 1
                    obj.keyhistory.n = obj.keyhistory.n + 1;
                    obj.keyhistory.pressed(obj.keyhistory.n) = Pressed;
                    obj.keyhistory.when(obj.keyhistory.n) = when;
                    obj.keyhistory.KeyNum{obj.keyhistory.n} = KeyNum;
                    obj.keyhistory.deltawhen(obj.keyhistory.n) = deltawhen;
                    obj.keyhistory.validkeys{obj.keyhistory.n} = validkeys;
                end
                if Pressed == 0 && ~isempty(History)
                    Pressed = -1;
                    KeyNum = History;
                    when = historywhen;
                    deltawhen = historydeltawhen;
                end
            end
            if ~Pressed
                KeyNum = [];
                when = [];
                deltawhen = [];
            end
            if ~isempty(KeyNum)
                KeyCode = find(KeyNum == validkeys);
            end
            WaitSecs(delay);
        end
    end
end