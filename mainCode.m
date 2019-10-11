   %      main
PsychDebugWindowConfiguration;
global ep pgb pgb2 bL bR bL2 bR2 is2 keylist ks
% Screen('Preference', 'SkipSyncTests', 1)
ep = exp_psychtoolbox;
ep.setup_window;
[bL, bR, bL2, bR2] = set_bandit(ep);
pgb = progressbar;
pgb.setup(ep.window, 0.8, 0.03, 0.1) ; 
pgb2 = progressbar;
pgb2.setup(ep.window, 0.8, 0.03, 0.9        );
% task parameters
ngame = 10;
ntrial = 20;   
datadir = './Data/';
if ~exist(datadir)
    mkdir(datadir);
end          
   filename = 'test';
is2 = false;
%
keylist = [KbName('leftarrow'), KbName('rightarrow')];
ks = {'left', 'right'};
bL.settppos(0.3, 0.3);
bR.settppos(0.7, 0.3);
bL2.settppos(0.3, 0.7);
bR2.settppos(0.7, 0.7);
%%
clear k1 k2 exploitside r
global k1 k2 exploitside r flag
%%
flag = true;
pgb.flush(300);
pgb2.flush(300);
instructions;     
flag = true;
for gi = 1:ngame
    game(gi) = rungame(ntrial);
    save(fullfile(datadir,filename), 'game');
end
function [bL, bR, bL2, bR2] = set_bandit(ep)
w = 80 * ep.window.scalefactor;
h = 60 * ep.window.scalefactor;
w_lever = 80 * ep.window.scalefactor;
h_lever = 60 * ep.window.scalefactor;
pos_lever = 1;
penwidth = 5 * ep.window.scalefactor;
dotradius = 30 * ep.window.scalefactor;
font_bandit = round(40 * ep.window.scalefactor);
bandit_color = {[0 255 255], [0 255 0]}; %
bL = bandit(ep.window);
bL.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,1,'left', font_bandit, bandit_color);
bR = bandit(ep.window);
bR.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,1,'right', font_bandit, bandit_color);
bandit_color = {[0 255 255], [0 255 0]}; %
bL2 = bandit(ep.window);
bL2.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,1,'left', font_bandit, bandit_color);
bR2 = bandit(ep.window);
bR2.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,1,'right', font_bandit, bandit_color);
end
function out = rungame(ntrial)
    clear k1 k2 exploitside r
    global k1 k2 exploitside r flag rt
    global ep pgb pgb2 bL bR bL2 bR2 is2 keylist ks

     for i = 1:ntrial
        runtrial(i);
        out.exploitside = exploitside;
        out.k1 = k1;
        out.k2 = k2;
        out.r = r;
        out.rt = rt;
    end
end
function runtrial(i)
    global k1 k2 exploitside r flag rt
    global ep pgb pgb2 bL bR bL2 bR2 is2 keylist ks

 rt(i) = NaN;
        % reward setting for this game
        if flag
            flag = false;
            ep.talkAndflip('New Game');
            WaitSecs(1.0);
            exploitside(i) = ceil(rand*2);
            r(i,1) = round(rand * 100);
            r(i,2) = round(rand * 100);
        else
            if r(i-1, exploitside(i-1)) >= r(i-1, 3-exploitside(i-1)) || ...
                    (exploitside(i-1) == k1(i-1) && exploitside(i-1) == k2(i-1))
                exploitside(i) = exploitside(i-1);
                r(i, exploitside(i)) = r(i-1, exploitside(i));
                r(i, 3-exploitside(i)) = round(rand * 100);
            else
                exploitside(i) = 3 - exploitside(i-1);
                r(i, exploitside(i)) = r(i-1, exploitside(i));
                r(i, 3-exploitside(i)) = round(rand * 100);
            end
            if rand < 0.1
                flag = true;
            end
        end
        % reset bandit
        bL.flush;
        bR.flush;
        bL2.flush;
        bR2.flush;
        bL.color_highlight = ep.color.AZcactus;
        bR.color_highlight = ep.color.AZcactus ;
        bL2.color_highlight = ep.color.AZcactus;
        bR2.color_highlight = ep.color.AZcactus;
        
        bL.color = ep.color.lightblue;
        bR.color = ep.color.lightblue;
        bL2.color = ep.color.AZriver;
        bR2.color = ep.color.AZriver;
        
        % draw bandit
        if exploitside(i) == 1
            bL.addreward(num2str(r(i,1)));
            bR.addreward('??');
            bL2.addreward(num2str(r(i,1)));
            bR2.addreward('??');
        else
            bR.addreward(num2str(r(i,2)));
            bL.addreward('??');
            bR2.addreward(num2str(r(i,2)  ));
            bL2.addreward('??');
        end
        bL.draw(0,'forced');
        bR.draw(0,'forced');
        bL2.draw(0,'forced');
        bR2.draw(0,'forced');
        pgb.draw;
        pgb2.draw;
        ep.talk('your choice', 'arbitrary', 20, [0, 0.11]);
        ep.talk('your rivals choice', 'arbitrary', 20, [0, 0.91]);
        ep.flip;
        
        % key press
        [~,~,~,k1(i)] = ep.waitForInputrelease(keylist);
        if k1(i) == 1
            bL.color_highlight = [0 0 255];
            bL.draw(1,'forced');
            bR.draw(0);
            bL.addreward(num2str(r(i,1)));
            
            if k1(i) == exploitside(i)
                bR.addreward('XX');
            end
        else
            bL.draw(0);
            bR.color_highlight = [0 0 255];
            bR.draw(1,'forced');
            bR.addreward(num2str(r(i,2)));
            
            if k1(i) == exploitside(i)
                bL.addreward('XX');
            end
        end
        pgb.draw;
        pgb2.draw;
        bL2.draw(0,'forced');
        bR2.draw(0,'forced');
        ep.talk('waiting for your rival''s choice', 'arbitrary', 20, [0, 0.6]);
        ep.flip;
        WaitSecs(1.0);
        
        % draw reward
        if is2
            fwrite(uS, k1(i));
            k2(i) = fread(uR);
        else
            k2(i) = ceil(rand*2);
            
        end
        if k1(i) == 1
            bL.draw(1,'forced');
            bR.draw(0);
        else
            bL.draw(0);
            bR.draw(1,'forced');
        end
        if k2(i) == 1
            bL2.addreward(num2str(r(i,1)));
            bL2.color_highlight = [0 0 255];
            
            if k2(i) == exploitside(i)
                bR2.addreward('XX');
            end
            bL2.draw(1,'forced');
            bR2.draw(0);
        else
            bR2.addreward(num2str(r(i,2)));
            bR2.color_highlight = [0 0 255];
            
            if k2(i) == exploitside(i)
                bL2.addreward('XX');
            end
            bL2.draw(0);
            bR2.draw(1,'forced');
        end
        pgb.add(r(i,k1(i)));
        pgb2.add(r(i,k2(i)));
        pgb.draw;
        pgb2.draw;
        ep.flip;
        [~,~,~,x] = ep.waitForInputrelease(KbName('space'));
        pgb.update;
end

function instructions()
    global ep pgb pgb2              
    [ev, iStr] = instructionList;

    endFlag = false;  
         count = 1;  
    while ~endFlag
        [A, B] = Screen('WindowSize', ep.window.id);


        ef = false;
        fontins = ceil(ep.font.fontsize * ep.window.scalefactor);
        ep.talk([count length(iStr)],'pagenumber',fontins);

        switch ev{count}

            case 'blank' % blank screen
                ep.talk(iStr{count},'instructions', fontins);                  
                ep.talkAndflip([],'pageturner', fontins);
            case 'exampleplay1'
                Screen('FillRect',ep.window.id,[0 0 0]);
                Screen('Flip',ep.window.id);
                nnn = 100;
                pgb.flush(100);                
                pgb2.flush(100);
                g = 1;
                while ~pgb.isstop
                    runtrial(g);
                    g = g + 1;
                    if g > 5
                        g = 1;
                    end
                end
                ep.talk(iStr{count},'instructions', fontins);
                ep.talkAndflip([],'pageturner', fontins);

        end

        keyspace = KbName('space');
        if ismac
            keybackspace = KbName('delete');
        else
            keybackspace =  KbName('backspace');
        end
        % press button to move on or not
        if ~ef
            flag = 1;
            while flag
                [KeyNum, when] = ep.waitForInputrelease([keyspace keybackspace],Inf);

                switch KeyNum

                    case keyspace % go forwards
                        count = count + 1;
                        if count > length(iStr)
                            endFlag = true;
                        end
                        flag = 0;
                    case keybackspace % go backwards
                        ef = true;
                        count = count - 1;
                        if count < 1
                            count = 1;
                        end
                        endFlag = false;
                        flag = 0;
                   otherwise
                        flag =1;
                end
            end
        end
    end
    WaitSecs(0.1);
    end
function [ev, iStr] = instructionList()

i = 0;

% instructions without sound
i=i+1; ev{i} = 'blank';      iStr{i} = 'Welcome! Thank you for volunteering for this experiment. \nIn the next hour you will be playing a series of games competing against an opponent to get as many points as you can as fast as possible. ';
i=i+1; ev{i} = 'blank';      iStr{i} = 'So ... to be sure that everything makes sense let''s work through a few example games ... \n Press the left arrow key (<-) to play the left bandit \n Press the right arrow key (->) to play the right bandit';
i=i+1; ev{i} = 'exampleplay1'; iStr{i} = 'Great job! Now you know the rules!';
i=i+1; ev{i} = 'blank';      iStr{i} = 'We want to see how well two human beings can do in this task, try your best to get as many points as you can!';
i=i+1; ev{i} = 'blank';      iStr{i} = 'Press space when you are ready to begin. \nGood luck!';
end