within Buildings.Electrical.AC.ThreePhasesUnbalanced.Lines;
model TwoPortResistance "Model of a resistance with two electrical ports"
  extends Modelica.Electrical.Analog.Interfaces.ConditionalHeatPort;
  extends Buildings.Electrical.AC.ThreePhasesUnbalanced.Interfaces.TwoPort;
  parameter Modelica.SIunits.Temperature T_ref = 298.15 "Reference temperature"
                                                                                annotation(Evaluate=true);
  parameter Modelica.SIunits.Temperature M = 507.65
    "Temperature constant (R_actual = R*(M + T_heatPort)/(M + T_ref))" annotation(Evaluate=true);
  parameter Modelica.SIunits.Resistance R(start=1)
    "Resistance at temperature T_ref";
  OnePhase.Lines.TwoPortResistance  phase1(
    T_ref=T_ref,
    M=M,
    R=R/3,
    useHeatPort=useHeatPort) "Resistance line 1"
    annotation (Placement(transformation(extent={{-10,20},{10,40}})));
  OnePhase.Lines.TwoPortResistance phase2(
    T_ref=T_ref,
    M=M,
    R=R/3,
    useHeatPort=useHeatPort) "Resistance line 2"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  OnePhase.Lines.TwoPortResistance phase3(
    T_ref=T_ref,
    M=M,
    R=R/3,
    useHeatPort=useHeatPort) "Resistance line 3"
    annotation (Placement(transformation(extent={{-10,-40},{10,-20}})));
equation
  LossPower = 0;
  connect(terminal_n.phase[1], phase1.terminal_n) annotation (Line(
      points={{-100,0},{-20,0},{-20,30},{-10,30}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(terminal_n.phase[2], phase2.terminal_n) annotation (Line(
      points={{-100,0},{-10,0}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(terminal_n.phase[3], phase3.terminal_n) annotation (Line(
      points={{-100,4.44089e-16},{-20,4.44089e-16},{-20,-30},{-10,-30}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(phase1.terminal_p, terminal_p.phase[1]) annotation (Line(
      points={{10,30},{20,30},{20,0},{100,0}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(phase2.terminal_p, terminal_p.phase[2]) annotation (Line(
      points={{10,0},{100,0}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(phase3.terminal_p, terminal_p.phase[3]) annotation (Line(
      points={{10,-30},{20,-30},{20,0},{100,0}},
      color={0,120,120},
      smooth=Smooth.None));

  connect(phase1.heatPort, heatPort) annotation (Line(
      points={{0,20},{0,14},{-32,14},{-32,-72},{0,-72},{0,-100}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(phase3.heatPort, heatPort) annotation (Line(
      points={{4.44089e-16,-40},{0,-40},{0,-100},{4.44089e-16,-100}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(phase2.heatPort, heatPort) annotation (Line(
      points={{4.44089e-16,-10},{4.44089e-16,-16},{-32,-16},{-32,-72},{
          4.44089e-16,-72},{4.44089e-16,-100}},
      color={191,0,0},
      smooth=Smooth.None));
  annotation (
  defaultComponentName="line",
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics), Icon(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                                               graphics={
          Text(
            extent={{-140,-28},{138,-60}},
            lineColor={0,0,0},
          textString="R=%R"),
          Line(points={{-92,0},{-72,0}}, color={0,0,0}),
          Line(points={{68,0},{88,0}}, color={0,0,0}),
        Rectangle(
          extent={{-72,32},{68,-28}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
          Text(
            extent={{-142,80},{138,40}},
            lineColor={0,0,0},
          textString="%name")}),
    Documentation(info="<html>
<p>
Resistive model that connects two AC three phases 
unbalanced interfaces. This model can be used to represent a
cable in a three phases unbalanced AC system.
</p>

<p align=\"center\">
<img alt=\"image\" src=\"modelica://Buildings/Resources/Images/Electrical/AC/ThreePhasesUnbalanced/Lines/twoPortR.png\"/>
</p>

<p>
The model represents the lumped resistance as shown in the figure above.
Assuming that the resistance <i>R</i> is the overall resistance of the cable,
each line has a resistance equal to <i>R/3</i>.
</p>

</html>", revisions="<html>
<ul>
<li>
October 3, 2014, by Marco Bonvini:<br/>
Added model and documentation.
</li>
</ul>
</html>"));
end TwoPortResistance;