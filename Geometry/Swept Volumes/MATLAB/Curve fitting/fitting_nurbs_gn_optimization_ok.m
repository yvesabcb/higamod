clear all
close all
clc
addpath('C:\Users\Leo\Documents\MATLAB\Add-Ons\Collections\NURBS',...
'C:\Users\Leo\Documents\MATLAB\Add-Ons\Collections\nurbs_toolbox',...
'C:\Users\Leo\Documents\MATLAB\Add-Ons\Collections\My_Function');
%% actual curve
curve=[1.88536000000000 19.7359800000000 -0.0391000000000000;1.90008000000000 19.7460100000000 -0.247480000000000;1.90250000000000 19.7476600000000 -0.290010000000000;1.94751000000000 19.7785000000000 -0.563290000000000;1.95537000000000 19.7838900000000 -0.607350000000000;2.03007000000000 19.8351500000000 -0.867380000000000;2.04443000000000 19.8450100000000 -0.905240000000000;2.14701000000000 19.9154800000000 -1.08360000000000;2.16936000000000 19.9308300000000 -1.12340000000000;2.29772000000000 20.0190300000000 -1.28888000000000;2.33012000000000 20.0412900000000 -1.33563000000000;2.47644000000000 20.1418300000000 -1.53823000000000;2.51974000000000 20.1715800000000 -1.59310000000000;2.67783000000000 20.2802800000000 -1.64726000000000;2.73290000000000 20.3181300000000 -1.69138000000000;2.89644000000000 20.4305500000000 -1.77498000000000;2.96347000000000 20.4766400000000 -1.80050000000000;3.12675000000000 20.5888900000000 -1.86907000000000;3.20526000000000 20.6428700000000 -1.88533000000000;3.36369000000000 20.7518100000000 -1.90153000000000;3.45261000000000 20.8129500000000 -1.91594000000000;3.60207000000000 20.9157300000000 -1.91957000000000;3.69935000000000 20.9826300000000 -1.90989000000000;3.83574000000000 21.0764400000000 -1.85777000000000;3.93787000000000 21.1466800000000 -1.83256000000000;4.05989000000000 21.2306100000000 -1.78170000000000;4.16406000000000 21.3022700000000 -1.72840000000000;4.26959000000000 21.3748700000000 -1.63053000000000;4.37124000000000 21.4448100000000 -1.54899000000000;4.46086000000000 21.5064800000000 -1.45813000000000;4.55717000000000 21.5727500000000 -1.35811000000000;4.63079000000000 21.6234200000000 -1.25033000000000;4.71797000000000 21.6834200000000 -1.12905000000000;4.77563000000000 21.7231100000000 -1.02347000000000;4.84980000000000 21.7741700000000 -0.877230000000000;4.89158000000000 21.8029600000000 -0.748830000000000;4.94905000000000 21.8425400000000 -0.585840000000000;4.97462000000000 21.8601700000000 -0.478040000000000;5.01150000000000 21.8856100000000 -0.304670000000000;5.02008000000000 21.8915600000000 -0.177930000000000;5.03279000000000 21.9003600000000 -0.000830000000000000;5.02380000000000 21.8942300000000 0.117800000000000;5.01048000000000 21.8851400000000 0.289490000000000;4.98484000000000 21.8675600000000 0.410610000000000;4.94771000000000 21.8420900000000 0.581270000000000;4.90601000000000 21.8134700000000 0.692470000000000;4.84839000000000 21.7739100000000 0.862140000000000;4.79081000000000 21.7343600000000 0.970300000000000;4.71644000000000 21.6832700000000 1.11140000000000;4.64292000000000 21.6327600000000 1.22220000000000;4.55576000000000 21.5728800000000 1.34943000000000;4.46591000000000 21.5111300000000 1.44225000000000;4.36972000000000 21.4450300000000 1.54806000000000;4.26331000000000 21.3719000000000 1.65483000000000;4.16196000000000 21.3022300000000 1.73381000000000;4.03633000000000 21.2158700000000 1.80237000000000;3.93142000000000 21.1437500000000 1.84891000000000;3.79585000000000 21.0505200000000 1.86030000000000;3.69756000000000 20.9829500000000 1.89471000000000;3.54635000000000 20.8789700000000 1.90464000000000;3.45210000000000 20.8141600000000 1.92434000000000;3.29106000000000 20.7034200000000 1.91071000000000;3.20561000000000 20.6446500000000 1.89897000000000;3.03900000000000 20.5300600000000 1.84004000000000;2.96423000000000 20.4786300000000 1.81983000000000;2.79716000000000 20.3637100000000 1.74537000000000;2.73405000000000 20.3203000000000 1.70280000000000;2.57213000000000 20.2088900000000 1.55903000000000;2.52073000000000 20.1735300000000 1.53295000000000;2.37066000000000 20.0702800000000 1.40343000000000;2.33050000000000 20.0426500000000 1.35603000000000;2.20225000000000 19.9543900000000 1.18118000000000;2.17293000000000 19.9342000000000 1.13605000000000;2.06700000000000 19.8612900000000 0.956350000000000;2.04592000000000 19.8467800000000 0.918310000000000;1.97062000000000 19.7948900000000 0.657440000000000;1.95715000000000 19.7856100000000 0.614930000000000;1.91125000000000 19.7539300000000 0.335120000000000;1.90360000000000 19.7486500000000 0.285680000000000;1.88791000000000 19.7377400000000 0.00455000000000000;1.88536000000000 19.7359800000000 -0.0391000000000000];
x=curve(:,1); y=curve(:,2); z=curve(:,3);
figure; plot3(x,y,z,'r'); grid on; title('curva iniziale')
%%
approx=nrb_approx(x',y',z',7,2,1.e-5,20,100);
%%
hold on; plot3(approx(1,:),approx(2,:),approx(3,:),'b'); grid on; title('curva iniziale r, approx in b')
%%
sud=round(numel(x)/4);
x1=x(1:sud)';
y1=y(1:sud)';
z1=z(1:sud)';
x4=x(sud:2*sud)';
y4=y(sud:2*sud)';
z4=z(sud:2*sud)';
x3=x(end:-1:end-sud)';
y3=y(end:-1:end-sud)';
z3=z(end:-1:end-sud)';
x2=x(end-sud:-1:2*sud)';
y2=y(end-sud:-1:2*sud)';
z2=z(end-sud:-1:2*sud)';
N1=[x1' y1' z1'];
N2=[x2' y2' z2'];
N3=[x3' y3' z3'];
N4=[x4' y4' z4'];
surf=discrete_coons_patch(N1,N2,N3,N4);
figure; hold on;
%plot3(point_surf(:,1)',point_surf(:,2)',point_surf(:,3)','r')
%% mettendo assiem le 4 curve
srf_recostr = nrbcoons(N1, N2, N3, N4);
nrbplot(srf_recostr,[20 20]);