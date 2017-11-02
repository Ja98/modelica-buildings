within Buildings.Examples.VAVReheat;
model Guideline36
  "Variable air volume flow system with terminal reheat and five thermal zones"
  extends Modelica.Icons.Example;
  extends Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop;

  parameter Modelica.SIunits.VolumeFlowRate maxSysPriFlo=m_flow_nominal/1.2
    "Maximum expected system primary airflow at design stage";
  parameter Modelica.SIunits.VolumeFlowRate minZonPriFlo[numZon]={
      mCor_flow_nominal,mSou_flow_nominal,mEas_flow_nominal,mNor_flow_nominal,
      mWes_flow_nominal}/1.2 "Minimum expected zone primary flow rate";

  parameter Modelica.SIunits.Time samplePeriod=120
    "Sample period of component, set to the same value as the trim and respond that process yPreSetReq";

  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ReheatController
                                                           conVAVCor(
    m_flow_nominal=mCor_flow_nominal,
    zonAre=AFloCor,
    final samplePeriod=samplePeriod) "Controller for terminal unit corridor"
    annotation (Placement(transformation(extent={{530,32},{550,52}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ReheatController
                                                           conVAVSou(
    m_flow_nominal=mSou_flow_nominal,
    zonAre=AFloSou,
    final samplePeriod=samplePeriod) "Controller for terminal unit south"
    annotation (Placement(transformation(extent={{700,30},{720,50}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ReheatController
                                                           conVAVEas(
    m_flow_nominal=mEas_flow_nominal,
    zonAre=AFloEas,
    final samplePeriod=samplePeriod) "Controller for terminal unit east"
    annotation (Placement(transformation(extent={{880,30},{900,50}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ReheatController
                                                           conVAVNor(
    m_flow_nominal=mNor_flow_nominal,
    zonAre=AFloNor,
    final samplePeriod=samplePeriod) "Controller for terminal unit north"
    annotation (Placement(transformation(extent={{1040,30},{1060,50}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ReheatController
                                                           conVAVWes(
    m_flow_nominal=mWes_flow_nominal,
    zonAre=AFloWes,
    final samplePeriod=samplePeriod) "Controller for terminal unit west"
    annotation (Placement(transformation(extent={{1240,28},{1260,48}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Controller
                                                       conAHU(
    numZon=numZon,
    maxSysPriFlo=maxSysPriFlo,
    minZonPriFlo=minZonPriFlo,
    zonAre=zonAre,
    have_occSen=fill(false, numZon))
    "AHU controller"
    annotation (Placement(transformation(extent={{392,334},{432,442}})));
  Buildings.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ZoneModeAndSetPoints
                                                                 TSetZon(
    THeaOn=THeaOn,
    THeaOff=THeaOff,
    TCooOff=TCooOff,
    numZon=numZon) "Zone temperature set points" annotation (Placement(
        transformation(rotation=0, extent={{60,300},{80,320}})));
  Modelica.Blocks.Routing.Multiplex5 TDis "Discharge air temperatures"
    annotation (Placement(transformation(extent={{220,280},{240,300}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant nOcc[numZon](each final
            k=0)
    "Occupany signal (set to zero as the control is configured to have no occupancy sensors)"
    annotation (Placement(transformation(extent={{320,460},{340,480}})));
  Modelica.Blocks.Routing.Multiplex5 VBox_flow
    "Air flow rate at the terminal boxes"
    annotation (Placement(transformation(extent={{220,240},{240,260}})));
  Buildings.Controls.OBC.CDL.Integers.MultiSum TZonResReq(nin=5)
    "Number of zone temperature requests"
    annotation (Placement(transformation(extent={{340,280},{360,300}})));
  Buildings.Controls.OBC.CDL.Integers.MultiSum PZonResReq(nin=5)
    "Number of zone pressure requests"
    annotation (Placement(transformation(extent={{340,240},{360,260}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant zonSta(k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Constants.ZoneStates.deadband)
    "Zone state signal"
    annotation (Placement(transformation(extent={{300,330},{320,350}})));
  parameter Modelica.SIunits.PressureDifference dpDisRetMax=40
    "Maximum return fan discharge static pressure setpoint";
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yOutDam(k=1)
    "Outdoor air damper control signal"
    annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));

equation
  connect(fanSup.port_b, dpDisSupFan.port_a) annotation (Line(
      points={{320,-40},{320,0},{320,-10},{320,-10}},
      color={0,0,0},
      smooth=Smooth.None,
      pattern=LinePattern.Dot));

  connect(conVAVCor.TRoo, TRooAir.y5[1]) annotation (Line(
      points={{529,41},{520,41},{520,162},{511,162}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conVAVSou.TRoo, TRooAir.y1[1]) annotation (Line(
      points={{699,39},{690,39},{690,40},{680,40},{680,178},{511,178}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRooAir.y2[1], conVAVEas.TRoo) annotation (Line(
      points={{511,174},{868,174},{868,39},{879,39}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRooAir.y3[1], conVAVNor.TRoo) annotation (Line(
      points={{511,170},{1028,170},{1028,39},{1039,39}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRooAir.y4[1], conVAVWes.TRoo) annotation (Line(
      points={{511,166},{1220,166},{1220,37},{1239,37}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conVAVCor.TDis, TSupCor.T) annotation (Line(points={{529,39},{522,39},
          {522,40},{514,40},{514,92},{569,92}},              color={0,0,127}));
  connect(TSupSou.T, conVAVSou.TDis) annotation (Line(points={{749,92},{688,92},
          {688,37},{699,37}},           color={0,0,127}));
  connect(TSupEas.T, conVAVEas.TDis) annotation (Line(points={{929,90},{872,90},
          {872,37},{879,37}},           color={0,0,127}));
  connect(TSupNor.T, conVAVNor.TDis) annotation (Line(points={{1089,94},{1032,
          94},{1032,37},{1039,37}},           color={0,0,127}));
  connect(TSupWes.T, conVAVWes.TDis) annotation (Line(points={{1289,90},{1228,
          90},{1228,35},{1239,35}},           color={0,0,127}));
  connect(cor.yVAV, conVAVCor.yDam) annotation (Line(points={{566,50},{556,50},
          {556,48},{551,48}}, color={0,0,127}));
  connect(cor.yVal, conVAVCor.yVal) annotation (Line(points={{566,34},{560,34},
          {560,43},{551,43}},           color={0,0,127}));
  connect(conVAVSou.yDam, sou.yVAV) annotation (Line(points={{721,46},{730,46},
          {730,48},{746,48}}, color={0,0,127}));
  connect(conVAVSou.yVal, sou.yVal) annotation (Line(points={{721,41},{732.5,41},
          {732.5,32},{746,32}},                color={0,0,127}));
  connect(conVAVEas.yVal, eas.yVal) annotation (Line(points={{901,41},{912.5,41},
          {912.5,32},{926,32}},                color={0,0,127}));
  connect(conVAVEas.yDam, eas.yVAV) annotation (Line(points={{901,46},{910,46},
          {910,48},{926,48}}, color={0,0,127}));
  connect(conVAVNor.yDam, nor.yVAV) annotation (Line(points={{1061,46},{1072.5,
          46},{1072.5,48},{1086,48}}, color={0,0,127}));
  connect(conVAVNor.yVal, nor.yVal) annotation (Line(points={{1061,41},{1072.5,
          41},{1072.5,32},{1086,32}},             color={0,0,127}));

  connect(conVAVCor.TRooHeaSet, TSetZon.THeaSet[1]) annotation (Line(points={{529,47},
          {480,47},{480,313},{81,313}},              color={0,0,127}));
  connect(conVAVCor.TRooCooSet, TSetZon.TCooSet[1]) annotation (Line(points={{529,45},
          {480,45},{480,317},{81,317}},                         color={0,0,127}));
  connect(conVAVSou.TRooHeaSet, TSetZon.THeaSet[2]) annotation (Line(points={{699,45},
          {660,45},{660,313},{81,313}},              color={0,0,127}));
  connect(conVAVSou.TRooCooSet, TSetZon.TCooSet[2]) annotation (Line(points={{699,43},
          {660,43},{660,317},{81,317}},                         color={0,0,127}));
  connect(conVAVEas.TRooHeaSet, TSetZon.THeaSet[3]) annotation (Line(points={{879,45},
          {850,45},{850,313},{81,313}},              color={0,0,127}));
  connect(conVAVEas.TRooCooSet, TSetZon.TCooSet[3]) annotation (Line(points={{879,43},
          {850,43},{850,317},{81,317}},                         color={0,0,127}));
  connect(conVAVNor.TRooHeaSet, TSetZon.THeaSet[4]) annotation (Line(points={{1039,45},
          {1020,45},{1020,313},{81,313}},               color={0,0,127}));
  connect(conVAVNor.TRooCooSet, TSetZon.TCooSet[4]) annotation (Line(points={{1039,43},
          {1020,43},{1020,317},{81,317}},                         color={0,0,
          127}));
  connect(conVAVWes.TRooHeaSet, TSetZon.THeaSet[5]) annotation (Line(points={{1239,43},
          {1202,43},{1202,313},{81,313}},               color={0,0,127}));
  connect(conVAVWes.TRooCooSet, TSetZon.TCooSet[5]) annotation (Line(points={{1239,41},
          {1202,41},{1202,317},{81,317}},                         color={0,0,
          127}));
  connect(conVAVWes.yVal, wes.yVal) annotation (Line(points={{1261,39},{1272.5,
          39},{1272.5,32},{1286,32}},             color={0,0,127}));
  connect(wes.yVAV, conVAVWes.yDam) annotation (Line(points={{1286,48},{1274,48},
          {1274,44},{1261,44}}, color={0,0,127}));
  connect(TSetZon.uOcc, occSch.occupied) annotation (Line(points={{59,306.025},{
          -92,306.025},{-92,300},{-240,300},{-240,-216},{-297,-216}},
                        color={255,0,255}));
  connect(occSch.tNexOcc, TSetZon.tNexOcc) annotation (Line(points={{-297,-204},
          {-254,-204},{-254,318},{59,318}},
        color={0,0,127}));
  connect(TSetZon.TZon, flo.TRooAir) annotation (Line(points={{59,315},{59,314},
          {46,314},{46,626},{1164,626},{1164,491.333},{1094.14,491.333}},
                     color={0,0,127}));
  connect(conAHU.THeaSet, TSetZon.THeaSet[1]) annotation (Line(points={{391,
          444.077},{120,444.077},{120,313},{81,313}},
                                                  color={0,0,127}));
  connect(conAHU.TCooSet, TSetZon.TCooSet[1]) annotation (Line(points={{391,
          439.923},{128,439.923},{128,317},{81,317}},
                                                  color={0,0,127}));
  connect(conAHU.TZon, flo.TRooAir) annotation (Line(points={{391,427.462},{280,
          427.462},{280,622},{1164,622},{1164,491.333},{1094.14,491.333}},
                                                                  color={0,0,
          127}));
  connect(conAHU.TOut, TOut.y) annotation (Line(points={{391,431.615},{-266,
          431.615},{-266,180},{-279,180}},
                            color={0,0,127}));
  connect(TRet.T, conAHU.TOutCut)
    annotation (Line(points={{100,151},{100,410.846},{391,410.846}},
                                                             color={0,0,127}));
  connect(conAHU.TSup, TSup.T) annotation (Line(points={{391,396.308},{140,
          396.308},{140,-20},{340,-20},{340,-29}},
                                         color={0,0,127}));
  connect(dpDisSupFan.p_rel, conAHU.ducStaPre) annotation (Line(points={{311,0},
          {150,0},{150,383.846},{391,383.846}},
                                        color={0,0,127}));
  connect(conAHU.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{391,361},{130,
          361},{130,307},{81,307}},               color={255,127,0}));
  connect(conAHU.uFreProSta, TSetZon.yFreProSta) annotation (Line(points={{391,
          348.538},{134,348.538},{134,303},{81,303}},   color={255,127,0}));
  connect(conAHU.TDis, TDis.y) annotation (Line(points={{391,419.154},{254,
          419.154},{254,290},{241,290}},
                               color={0,0,127}));
  connect(conAHU.nOcc, nOcc.y) annotation (Line(points={{391,392.154},{360,
          392.154},{360,470},{341,470}},
                               color={0,0,127}));
  connect(conAHU.VBox_flow, VBox_flow.y) annotation (Line(points={{391,377.615},
          {260,377.615},{260,250},{241,250}},
                                         color={0,0,127}));
  connect(conVAVCor.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{529,35},
          {520,35},{520,16},{400,16},{400,200},{88,200},{88,307},{81,307}},
                     color={255,127,0}));
  connect(conVAVSou.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{699,33},
          {690,33},{690,16},{400,16},{400,200},{88,200},{88,307},{81,307}},
                     color={255,127,0}));
  connect(conVAVEas.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{879,33},
          {868,33},{868,16},{400,16},{400,200},{88,200},{88,307},{81,307}},
                     color={255,127,0}));
  connect(conVAVNor.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{1039,33},
          {1032,33},{1032,16},{400,16},{400,200},{88,200},{88,307},{81,307}},
                                       color={255,127,0}));
  connect(conVAVWes.uOpeMod, TSetZon.yOpeMod) annotation (Line(points={{1239,31},
          {1228,31},{1228,16},{400,16},{400,200},{88,200},{88,307},{81,307}},
                     color={255,127,0}));
  connect(conAHU.uZonTemResReq, TZonResReq.y) annotation (Line(points={{391,
          340.231},{368,340.231},{368,290},{361.7,290}},
                                            color={255,127,0}));
  connect(conVAVCor.yZonTemResReq, TZonResReq.u[1]) annotation (Line(points={{551,38},
          {554,38},{554,220},{328,220},{328,295.6},{338,295.6}},
        color={255,127,0}));
  connect(conVAVSou.yZonTemResReq, TZonResReq.u[2]) annotation (Line(points={{721,36},
          {726,36},{726,220},{328,220},{328,292.8},{338,292.8}},
        color={255,127,0}));
  connect(conVAVEas.yZonTemResReq, TZonResReq.u[3]) annotation (Line(points={{901,36},
          {904,36},{904,220},{328,220},{328,290},{338,290}},
        color={255,127,0}));
  connect(conVAVNor.yZonTemResReq, TZonResReq.u[4]) annotation (Line(points={{1061,36},
          {1064,36},{1064,220},{328,220},{328,287.2},{338,287.2}},
                   color={255,127,0}));
  connect(conVAVWes.yZonTemResReq, TZonResReq.u[5]) annotation (Line(points={{1261,34},
          {1266,34},{1266,220},{328,220},{328,284.4},{338,284.4}},
                   color={255,127,0}));
  connect(conVAVCor.yZonPreResReq, PZonResReq.u[1]) annotation (Line(points={{551,34},
          {558,34},{558,214},{332,214},{332,255.6},{338,255.6}},
        color={255,127,0}));
  connect(conVAVSou.yZonPreResReq, PZonResReq.u[2]) annotation (Line(points={{721,32},
          {728,32},{728,214},{332,214},{332,252.8},{338,252.8}},
        color={255,127,0}));
  connect(conVAVEas.yZonPreResReq, PZonResReq.u[3]) annotation (Line(points={{901,32},
          {906,32},{906,214},{332,214},{332,250},{338,250}},
        color={255,127,0}));
  connect(conVAVNor.yZonPreResReq, PZonResReq.u[4]) annotation (Line(points={{1061,32},
          {1066,32},{1066,214},{332,214},{332,247.2},{338,247.2}},
                   color={255,127,0}));
  connect(conVAVWes.yZonPreResReq, PZonResReq.u[5]) annotation (Line(points={{1261,30},
          {1268,30},{1268,214},{332,214},{332,244.4},{338,244.4}},
                   color={255,127,0}));
  connect(conAHU.uZonPreResReq, PZonResReq.y) annotation (Line(points={{391,
          336.077},{372,336.077},{372,250},{361.7,250}},
                                            color={255,127,0}));
  connect(VSupCor_flow.V_flow, VBox_flow.u1[1]) annotation (Line(points={{569,
          130},{472,130},{472,206},{180,206},{180,260},{218,260}}, color={0,0,
          127}));
  connect(VSupSou_flow.V_flow, VBox_flow.u2[1]) annotation (Line(points={{749,
          130},{742,130},{742,206},{180,206},{180,255},{218,255}}, color={0,0,
          127}));
  connect(VSupEas_flow.V_flow, VBox_flow.u3[1]) annotation (Line(points={{929,
          128},{914,128},{914,206},{180,206},{180,250},{218,250}}, color={0,0,
          127}));
  connect(VSupNor_flow.V_flow, VBox_flow.u4[1]) annotation (Line(points={{1089,
          132},{1080,132},{1080,206},{180,206},{180,245},{218,245}}, color={0,0,
          127}));
  connect(VSupWes_flow.V_flow, VBox_flow.u5[1]) annotation (Line(points={{1289,
          128},{1284,128},{1284,206},{180,206},{180,240},{218,240}}, color={0,0,
          127}));
  connect(TSupCor.T, TDis.u1[1]) annotation (Line(points={{569,92},{466,92},{
          466,210},{176,210},{176,300},{218,300}}, color={0,0,127}));
  connect(TSupSou.T, TDis.u2[1]) annotation (Line(points={{749,92},{720,92},{
          720,92},{688,92},{688,210},{176,210},{176,295},{218,295}}, color={0,0,
          127}));
  connect(TSupEas.T, TDis.u3[1]) annotation (Line(points={{929,90},{872,90},{
          872,210},{176,210},{176,290},{218,290}}, color={0,0,127}));
  connect(TSupNor.T, TDis.u4[1]) annotation (Line(points={{1089,94},{1032,94},{
          1032,210},{176,210},{176,285},{218,285}}, color={0,0,127}));
  connect(TSupWes.T, TDis.u5[1]) annotation (Line(points={{1289,90},{1228,90},{
          1228,210},{176,210},{176,280},{218,280}}, color={0,0,127}));
  connect(conAHU.yOutDamPos, eco.yOut) annotation (Line(points={{433,400.462},{
          450,400.462},{450,36},{-10,36},{-10,-34}},
                                        color={0,0,127}));
  connect(conVAVCor.VDis, VSupCor_flow.V_flow) annotation (Line(points={{529,43},
          {522,43},{522,130},{569,130}},               color={0,0,127}));
  connect(VSupSou_flow.V_flow, conVAVSou.VDis) annotation (Line(points={{749,130},
          {690,130},{690,41},{699,41}},                color={0,0,127}));
  connect(VSupEas_flow.V_flow, conVAVEas.VDis) annotation (Line(points={{929,128},
          {874,128},{874,41},{879,41}},                color={0,0,127}));
  connect(VSupNor_flow.V_flow, conVAVNor.VDis) annotation (Line(points={{1089,
          132},{1034,132},{1034,41},{1039,41}},           color={0,0,127}));
  connect(VSupWes_flow.V_flow, conVAVWes.VDis) annotation (Line(points={{1289,
          128},{1230,128},{1230,39},{1239,39}},           color={0,0,127}));
  connect(TSup.T, conVAVCor.TSupAHU) annotation (Line(points={{340,-29},{340,
          -20},{514,-20},{514,37},{529,37}},           color={0,0,127}));
  connect(TSup.T, conVAVSou.TSupAHU) annotation (Line(points={{340,-29},{340,
          -20},{686,-20},{686,35},{699,35}},           color={0,0,127}));
  connect(TSup.T, conVAVEas.TSupAHU) annotation (Line(points={{340,-29},{340,
          -20},{864,-20},{864,35},{879,35}},           color={0,0,127}));
  connect(TSup.T, conVAVNor.TSupAHU) annotation (Line(points={{340,-29},{340,
          -20},{1028,-20},{1028,35},{1039,35}},           color={0,0,127}));
  connect(TSup.T, conVAVWes.TSupAHU) annotation (Line(points={{340,-29},{340,
          -20},{1224,-20},{1224,33},{1239,33}},           color={0,0,127}));
  connect(VOut1.V_flow, conAHU.VOut_flow) annotation (Line(points={{-61,-20.9},{
          -61,388},{391,388}}, color={0,0,127}));
  connect(conAHU.uZonSta, zonSta.y) annotation (Line(points={{391,354.769},{330,
          354.769},{330,340},{321,340}},
                                color={255,127,0}));
  connect(fanSup.y, conAHU.ySupFanSpe) annotation (Line(points={{310,-28},{310,
          -14},{460,-14},{460,413.338},{433,413.338}},
                                           color={0,0,127}));
  connect(conAHU.yHea, gaiHeaCoi.u) annotation (Line(points={{433,361},{456,361},
          {456,-280},{80,-280},{80,-210},{98,-210}}, color={0,0,127}));
  connect(conAHU.yCoo, gaiCooCoi.u) annotation (Line(points={{433,348.538},{446,
          348.538},{446,-274},{88,-274},{88,-248},{98,-248}},
                                                     color={0,0,127}));
  connect(conAHU.TMix, TMix.T)
    annotation (Line(points={{391,369.308},{40,369.308},{40,-29}},
                                                           color={0,0,127}));
  connect(conAHU.yRetDamPos, eco.yRet) annotation (Line(points={{433,388},{436,388},
          {436,40},{-16.8,40},{-16.8,-34}},
                                          color={0,0,127}));
  connect(yOutDam.y, eco.yExh)
    annotation (Line(points={{-19,-10},{-3,-10},{-3,-34}}, color={0,0,127}));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-400,-400},{
            1660,640}})),
    Documentation(info="<html>
<p>
This model consist of an HVAC system, a building envelope model and a model
for air flow through building leakage and through open doors.
</p>
<p>
The HVAC system is a variable air volume (VAV) flow system with economizer
and a heating and cooling coil in the air handler unit. There is also a
reheat coil and an air damper in each of the five zone inlet branches.
</p>
<p>
See the model
<a href=\"modelica://Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop\">
Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop</a>
for a description of the HVAC system and the building envelope.
</p>
<p>
The control is based on ASHRAE Guideline 36, and implemented
using the sequences from the library
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36_PR1\">
Buildings.Controls.OBC.ASHRAE.G36_PR1</a> for
multi-zone VAV systems with economizer. The schematic diagram of the HVAC and control
sequence is shown in the figure below.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://Buildings/Resources/Images/Examples/VAVReheat/vavControlSchematics.png\" border=\"1\"/>
</p>
<p>
A similar model but with a different control sequence can be found in
<a href=\"modelica://Buildings.Examples.VAVReheat.ASHRAE2006\">
Buildings.Examples.VAVReheat.ASHRAE2006</a>.
Note that this model, because of the frequent time sampling,
has longer computing time than
<a href=\"modelica://Buildings.Examples.VAVReheat.ASHRAE2006\">
Buildings.Examples.VAVReheat.ASHRAE2006</a>.
The reason is that the time integrator cannot make large steps
because it needs to set a time step each time the control samples
its input.
</p>
</html>", revisions="<html>
<ul>
<li>
May 19, 2016, by Michael Wetter:<br/>
Changed chilled water supply temperature to <i>6&circ;C</i>.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/509\">#509</a>.
</li>
<li>
April 26, 2016, by Michael Wetter:<br/>
Changed controller for freeze protection as the old implementation closed
the outdoor air damper during summer.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/511\">#511</a>.
</li>
<li>
January 22, 2016, by Michael Wetter:<br/>
Corrected type declaration of pressure difference.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/404\">#404</a>.
</li>
<li>
September 24, 2015 by Michael Wetter:<br/>
Set default temperature for medium to avoid conflicting
start values for alias variables of the temperature
of the building and the ambient air.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/426\">issue 426</a>.
</li>
</ul>
</html>"),
    __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/Examples/VAVReheat/Guideline36.mos"
        "Simulate and plot"),
    experiment(StopTime=172800, Tolerance=1e-08));
end Guideline36;