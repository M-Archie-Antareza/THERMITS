clc, clear all, close all
 
%% Input data
data.C = uigetfile('*.dat',...
    'Please Select The Cooling Data File'); 
data.H = uigetfile('*.dat',...
    'Please Select The Heating Data File'); 
 
SN = 'SAMPLENAME'; %Sample Name
 
%% Parameters
SF = 1; %Smoothing Factor
 
MinTemp_H = 0; %Estimation Boundary
MinTemp_C = 0;
MaxTemp_H = 1000;
MaxTemp_C = 1000;
 
 
%% Cooling
data.C = load(data.C);
C.T = data.C(:,1);
C.M = smooth(data.C(:,2)/max(data.C(:,2)),SF); 
 
C.deriv_1 = diff(C.M)./diff(C.T);
C.deriv_2 = diff(C.deriv_1)./diff(C.T(2:end));
 
%Finding highest value of 2nd derivative 
%for Curie temperature estimation
ind=find((C.T>MinTemp_C).*(C.T<MaxTemp_C)); 
ind([1:2, end-10:end])=[]; 
a = C.T(ind);
b = C.deriv_2(ind-2);
curieT_C = a(b==max(b));
curieM_C = C.M(C.T==curieT_C);
curieD1_C = C.deriv_1(C.T(2:end)==curieT_C);
curieD2_C = C.deriv_2(C.T(3:end)==curieT_C);
 
%% Heating
data.H = load(data.H);
H.T = data.H(:,1);
H.M = smooth(data.H(:,2)/max(data.H(:,2)),SF);
 
H.deriv_1 = diff(H.M)./diff(H.T);
H.deriv_2 = diff(H.deriv_1)./diff(H.T(2:end));
 
ind = find((H.T>MinTemp_H).* (H.T<MaxTemp_H));
ind([1:2, end-10:end])=[];
a = H.T(ind);
b = H.deriv_2(ind-2);
curieT_H = a(b==max(b));
curieM_H = H.M(H.T==curieT_H);
curieD1_H = H.deriv_1(H.T(2:end)==curieT_H);
curieD2_H = H.deriv_2(H.T(3:end)==curieT_H);
 
%% Figures
MS = 5; %MarkerSize
 
%Thermomagnetic data curves
figure
set(gcf,'Units','Normalized',...
    'OuterPosition',[0.017 0.01 0.5 0.98])
subplot(3,1,1)
plot(C.T,C.M,'b',H.T,H.M,'r')
hold on
plot(curieT_C,curieM_C,'*b','MarkerSize',MS)
plot(curieT_H,curieM_H,'*r','MarkerSize',MS)  
 
lgd_CT_C = ['CurieTemp_C = ' num2str(curieT_C)];
lgd_CT_H = ['CurieTemp_H = ' num2str(curieT_H)];
lgd_est_C = ['C : ' num2str(MinTemp_H) '-' num2str(MaxTemp_H) ' K'];
lgd_est_H = ['H : ' num2str(MinTemp_H) '-' num2str(MaxTemp_H) ' K'];
lgd = {'Cooling', 'Heating', lgd_CT_C, lgd_CT_H};
legend(lgd,'location','eastoutside')
 
str = {'CurieTemp estimated using data',lgd_est_C,lgd_est_H};
annotation('textbox',[0.68 0.78 0.4 0.2], 'String',str,...
    'FitBoxToText','on', 'FontSize',8,'LineStyle','none')
xlabel('Temperature (K)'), ylabel('Normalized Moment (emu)')
title(['Data (smoothing span = ' num2str(SF) ')'])
 
 
%1st derivative curves
subplot(3,1,2)
plot(C.T(2:end),C.deriv_1,'b',H.T(2:end),H.deriv_1,'r')
hold on
plot(curieT_C,curieD1_C,'*b','MarkerSize',MS)
plot(curieT_H,curieD1_H,'*r','MarkerSize',MS)
lgd = {'dM/dT (Cooling)','dM/dT (Heating)',...
    ['CurieTemp_C = ' num2str(curieT_C)],...
    ['CurieTemp_H = ' num2str(curieT_H)]};
legend(lgd,'location','eastoutside')
xlabel('Temperature (K)'), ylabel('dM/dT (emu/K)')
title('1st Derivative')
 
 
%2nd derivative curves
subplot(3,1,3)
plot(C.T(3:end),C.deriv_2,'b',H.T(3:end),H.deriv_2,'r')
hold on
plot(curieT_C,curieD2_C,'*b','MarkerSize',MS)
plot(curieT_H,curieD2_H,'*r','MarkerSize',MS)
lgd = {'d^2M/dT^2 (Cooling)','d^2M/dT^2 (Heating)',...
    ['CurieTemp_C = ' num2str(curieT_C)],...
    ['CurieTemp_H = ' num2str(curieT_H)]};
legend(lgd,'location','eastoutside')
xlabel('Temperature (K)')
ylabel('d^2M/dT^2 (emu/K^2)')
title('2nd Derivative')
 
suptitle(SN)
