function NPVNow = NPVEngine(x,z,swtProjectLife,swtWACC,swtTaxRate,swtCostOfEquip,swtSalvValue,swtMktValue, ... 
    swtDeprecLife,swtPGrowth,swtQGrowth,swtFixOpCost, ...
    swtFixOpCostGr,swtVarOpCost,swtVarOpCostGr,swtInvent,swtAR,swtAP,swtMC)

CFCS = zeros(7,swtProjectLife+1); 

k = swtProjectLife+1;
for c = 3:k;
CFCS(1,1) = -1 * swtCostOfEquip; % Purchases of Equipment.
CFCS(2,swtProjectLife+1) =  swtMktValue; % Sale of Equipment

i = 2; % set the counter to 2.0 initially
while i <= swtDeprecLife;
CFCS(3,i:swtDeprecLife+1) = (swtCostOfEquip - swtSalvValue)/swtDeprecLife; % Depreciation per Year
i = i + 1; % increment the counter by one
end; % end while i <= swtDeprecLife;

CFCS(4,c-1) = CFCS(3,c-1) + CFCS(4,c-2);
CFCS(4,c) = CFCS(3,c) + CFCS(4,c-1); % Accumulated Depreciation:
CFCS(5,1) = swtCostOfEquip;
CFCS(5,c-1) = CFCS(5,c-2) - CFCS(3,c-1); 
CFCS(5,c) = CFCS(5,c-1) - CFCS(3,c); % Implied Book value of equipment:

j = 2;
while j <= swtProjectLife+1;
    if CFCS(2,j) > 0;
       CFCS(6,j) = (CFCS(5,j) - CFCS(2,j))*swtTaxRate;
    else
       CFCS(6,j) = 0;
    end;
j = j + 1;
end;
% tax due (- #) or tax shield (+#) on sale of equip:

CFCS(7,c-2) = CFCS(1,c-2) + CFCS(2,c-2) + CFCS(6,c-2);
CFCS(7,c) = CFCS(1,c) + CFCS(2,c) + CFCS(6,c);% Total:  CF from Cap. Spending:
end;
%%

%%
CFOP  = zeros(9,swtProjectLife+2);  % CF from OPerations 
CFOP(1,2) = x; % price at t=0 (CB)

k = swtProjectLife+1;
for c = 3:k;
CFOP(1,c) = (1 + swtPGrowth) * CFOP(1,c-1); % price growth

CFOP(2,2) = z; % quantity at t=0 (CB)
CFOP(2,c) = CFOP(2,c-1) * (1 + swtQGrowth); % quantity growth
CFOP(3,2) = swtFixOpCost; % fixed cost at t=0
CFOP(3,c) = CFOP(3,c-1) * (1 + swtFixOpCostGr); % fixed cost growth
CFOP(4,2) = swtVarOpCost; % variable per unit cost at t=0
CFOP(4,c) = CFOP(4,c-1) * (1 + swtVarOpCostGr); % per unit variable cost growth
CFOP(5,c-1) = CFOP(1,c-1) * CFOP(2,c-1);
CFOP(5,c) = CFOP(1,c) * CFOP(2,c); % Accounting revenue
CFOP(6,c-2) = CFOP(3,c-2); % Fixed operating costs In Accounting Terms
CFOP(6,c) = CFOP(3,c);
CFOP(7,c-2) = CFOP(2,c-2) * CFOP(4,c-2);
CFOP(7,c) = CFOP(2,c) * CFOP(4,c); % Variable Op. Costs/unit in Accounting Terms
CFOP(8,c-2) = CFCS(3,c-2); 
CFOP(8,c) = CFCS(3,c); % Depreciation/yr
CFOP(9,c-2) = (((CFOP(5,c-2) - CFOP(6,c-2) - ... 
                               CFOP(7,c-2) - CFOP(8,c-2)) * (1-swtTaxRate)) ...
                              +CFOP(8,c-2)); 
CFOP(9,c) = (((CFOP(5,c) - CFOP(6,c) - ... 
                               CFOP(7,c) - CFOP(8,c)) * (1-swtTaxRate)) ...
                              +CFOP(8,c)); % Total: CF from Operations:
end;                        
%%                         
CFWC  = zeros(10,swtProjectLife+1); % CF from changes in Working Capital 

k = swtProjectLife+1;
for c = 3:k;

CFWC(1,c-2) = swtInvent * CFOP(5,c-1);
CFWC(1,c) = swtInvent * CFOP(5,c+1); % row 1 = inventory levels
CFWC(2,c-1) = swtAR * CFOP(5,c-1); 
CFWC(2,c) = swtAR * CFOP(5,c); % row 2 = A/R levels 
CFWC(3,c-1) = swtAP * CFOP(5,c-1);
CFWC(3,c) = swtAP * CFOP(5,c); % row 3 = A/P levels
CFWC(4,1) = CFWC(1,1);
CFWC(4,c-1) = CFWC(1,c-1) - CFWC(1,c-2);
CFWC(4,2) = CFWC(1,2) - CFWC(1,1); % (CB) - this should be deleted
CFWC(4,c) = CFWC(1,c) - CFWC(1,c-1); % row 4 = Changes in inventory levels
CFWC(5,1) = CFWC(2,1);
CFWC(5,c-1) = CFWC(2,c-1) - CFWC(2,c-2); 
CFWC(5,c) = CFWC(2,c) - CFWC(2,c-1); 
CFWC(5,swtProjectLife+1) = -1 * CFWC(2,swtProjectLife); % row 5 = Changes in A/R levels
CFWC(6,c-1) = CFWC(3,c-1) - CFWC(3,c-2);
CFWC(6,c) = CFWC(3,c) - CFWC(3,c-1); 
CFWC(6,swtProjectLife+1) = -1 * CFWC(3,swtProjectLife); % row 6 = Changes in A/P levels   
CFWC(7,:) = -1 * CFWC(4,:); % row 7 = CF implication from the change in inventory levels = row 4 * -1 
CFWC(8,:) = -1 * CFWC(5,:); % row 8 = CF implication from the change in A/R levels = row 5 * -1 
CFWC(9,:) =  1 * CFWC(6,:); % row 9 = CF implication from the change in A/P levels = row 6
CFWC(10,:) = sum(CFWC(7:9,:)); % row 10 = sum of rows 7,8,9 = CF from changes in Working Capital
end;
%%
CFMC  = zeros(3,swtProjectLife+1);  % CF from changes in Maint Cash (MC)

k = swtProjectLife+1;
for c = 3:k;
CFMC(1,c-1) = CFOP(5,c-1) * swtMC;
CFMC(1,c) = CFOP(5,c) * swtMC; % Maint Cash Level
CFMC(2,1) = CFMC(1,1);
CFMC(2,c-1) = CFMC(1,c-1) - CFMC(1,c-2); % Change in Maint Cash Level
CFMC(2,swtProjectLife+1) = CFMC(1,swtProjectLife) * -1;
CFMC(3,:) = -1 * CFMC(2,:); % Cash Impact from Maint Cash Change
end;
%%
CFTOT = zeros(3,swtProjectLife+1); % Total CF's
CFTOT(1,:) = (0:swtProjectLife);

k = swtProjectLife+1;
for c = 1:k;
CFTOT(2,c) = CFCS(7,c) + CFOP(9,c) + CFWC(10,c) + CFMC(3,c);
CFTOT(3,c) = CFTOT(2,c)/(1+swtWACC)^CFTOT(1,c);
NPVNow = sum(CFTOT(3,:));
end;
