within Buildings.Fluid.HeatExchangers.DXCoils.BaseClasses.Examples;
model EvaporationPulse "Test model for evaporation with pulse signal"
  extends Modelica.Icons.Example;
  package Medium =Buildings.Media.GasesConstantDensity.MoistAirUnsaturated;

  parameter
    Buildings.Fluid.HeatExchangers.DXCoils.Data.BaseClasses.NominalValues nomVal(
          Q_flow_nominal=-5000,
          COP_nominal=3,
          SHR_nominal=0.8,
          m_flow_nominal=5000/1006/10) "Nominal values for DX coil"
    annotation (Placement(transformation(extent={{80,80},{100,100}})));

  parameter Modelica.SIunits.Temperature TOut_nominal=
    nomVal.TIn_nominal + nomVal.SHR_nominal * nomVal.Q_flow_nominal/nomVal.m_flow_nominal/1006
    "Nominal air outlet temperature";

  parameter Modelica.SIunits.MassFraction XIn_nominal=
    Buildings.Utilities.Psychrometrics.Functions.X_pSatpphi(
     pSat=Medium.saturationPressure(nomVal.TIn_nominal),
     p=nomVal.p_nominal,
     phi=nomVal.phiIn_nominal) "Mass fraction at nominal inlet conditions";

  parameter Modelica.SIunits.MassFraction XOut_nominal = XIn_nominal +
   (1-nomVal.SHR_nominal) * nomVal.Q_flow_nominal/nomVal.m_flow_nominal/Medium.enthalpyOfVaporization(293.15)
    "Nominal air outlet humidity";

  Modelica.Blocks.Sources.Pulse pulSho(period=30*60)
    "Control signal for short-cycling coil"
    annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
  Evaporation evaSho(redeclare package Medium = Medium, nomVal=nomVal)
    "Evaporation model"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Modelica.Blocks.Math.RealToBoolean realToBoolean
    annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));
  Modelica.Blocks.Sources.Constant TWat(k=293.15)
    annotation (Placement(transformation(extent={{-60,110},{-40,130}})));
  Modelica.Blocks.Sources.Constant mAir_flow(k=nomVal.m_flow_nominal)
    "Air flow rate"
    annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
  Modelica.Blocks.Sources.Constant XOut(k=XOut_nominal)
    "Outlet water vapor mass fraction"
    annotation (Placement(transformation(extent={{-60,10},{-40,30}})));
  Modelica.Blocks.Sources.Constant TOut(k=TOut_nominal) "Outlet Temperature"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Modelica.Blocks.Continuous.Integrator intSho
    "Mass of water that evaporates into air stream"
    annotation (Placement(transformation(extent={{80,40},{100,60}})));
  Evaporation evaNor(redeclare package Medium = Medium, nomVal=nomVal)
    "Evaporation model"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
  Modelica.Blocks.Continuous.Integrator intNor
    "Mass of water that evaporates into air stream"
    annotation (Placement(transformation(extent={{80,0},{100,20}})));
  Modelica.Blocks.Sources.Pulse pulNor(period=3600)
    "Control signal for normal-cycling coil"
    annotation (Placement(transformation(extent={{-100,-140},{-80,-120}})));
  Modelica.Blocks.Math.RealToBoolean realToBoolean1
    annotation (Placement(transformation(extent={{-60,-140},{-40,-120}})));
  Modelica.Blocks.Math.Gain mWat_flow(k=nomVal.Q_flow_nominal*(1 - nomVal.SHR_nominal)
        /Medium.enthalpyOfVaporization(293.15))
    "Water mass flow rate from air to coil surface"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Modelica.Blocks.Math.Gain mWat_flow1(k=nomVal.Q_flow_nominal*(1 - nomVal.SHR_nominal)
        /Medium.enthalpyOfVaporization(293.15))
    "Water mass flow rate from air to coil surface"
    annotation (Placement(transformation(extent={{-60,-110},{-40,-90}})));
  Modelica.Blocks.Sources.Constant XIn(k=XIn_nominal)
    "Inlet water vapor mass fraction"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
equation

  connect(pulSho.y, realToBoolean.u)
                                    annotation (Line(
      points={{-79,-70},{-62,-70}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realToBoolean.y, evaSho.on) annotation (Line(
      points={{-39,-70},{-18,-70},{-18,58},{38,58}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(evaSho.TWat, TWat.y) annotation (Line(
      points={{38,50},{12,50},{12,120},{-39,120}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(evaSho.mAir_flow, mAir_flow.y) annotation (Line(
      points={{38,44},{0,44},{0,90},{-39,90}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(XOut.y, evaSho.XOut) annotation (Line(
      points={{-39,20},{50,20},{50,38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TOut.y, evaSho.TOut) annotation (Line(
      points={{-39,-10},{56,-10},{56,38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(evaSho.mEva_flow, intSho.u) annotation (Line(
      points={{61,50},{78,50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(evaNor.TWat, TWat.y) annotation (Line(
      points={{38,-30},{12,-30},{12,120},{-39,120}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(evaNor.mAir_flow, mAir_flow.y) annotation (Line(
      points={{38,-36},{0,-36},{0,90},{-39,90}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(XOut.y, evaNor.XOut) annotation (Line(
      points={{-39,20},{20,20},{20,-60},{50,-60},{50,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TOut.y, evaNor.TOut) annotation (Line(
      points={{-39,-10},{-6,-10},{-6,-70},{56,-70},{56,-42},{56,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(evaNor.mEva_flow, intNor.u) annotation (Line(
      points={{61,-30},{70,-30},{70,10},{78,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pulNor.y, realToBoolean1.u)
                                    annotation (Line(
      points={{-79,-130},{-62,-130}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realToBoolean1.y, evaNor.on)
                                      annotation (Line(
      points={{-39,-130},{34,-130},{34,-22},{38,-22}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(pulNor.y, mWat_flow1.u) annotation (Line(
      points={{-79,-130},{-72,-130},{-72,-100},{-62,-100}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(mWat_flow1.y, evaNor.mWat_flow) annotation (Line(
      points={{-39,-100},{32,-100},{32,-26},{38,-26}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pulSho.y, mWat_flow.u) annotation (Line(
      points={{-79,-70},{-68,-70},{-68,-40},{-62,-40}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(mWat_flow.y, evaSho.mWat_flow) annotation (Line(
      points={{-39,-40},{-12,-40},{-12,54},{38,54}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(XIn.y, evaSho.XIn) annotation (Line(
      points={{-39,50},{-30,50},{-30,28},{44,28},{44,38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(XIn.y, evaNor.XIn) annotation (Line(
      points={{-39,50},{-30,50},{-30,-54},{44,-54},{44,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(extent={{-120,-160},{120,140}},
          preserveAspectRatio=true),
                      graphics),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatExchangers/DXCoils/BaseClasses/Examples/EvaporationPulse.mos"
        "Simulate and plot"),
          Documentation(info="<html>
<p>
This example illustrates the evaporation of water vapor that 
accumulated on the coil.
Input to the model is a pulse signal that switches the coil on and off.
The two instances have a different frequency of the on and off signal
to illustrate that the reevaporation of mass is larger if the coil
short-cycles.
</p>
</html>",
revisions="<html>
<ul>
<li>
August 23, 2012 by Michael Wetter:<br>
First implementation. 
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-120,-160},{120,140}})));
end EvaporationPulse;
