within Buildings.Experimental.OpenBuildingControl.CDL.Logical.Validation;
model Less "Validation model for the Less block"
extends Modelica.Icons.Example;

  Buildings.Experimental.OpenBuildingControl.CDL.Sources.Ramp ramp1(
    duration=1,
    offset=-2,
    height=4)  "Block that generates ramp signal"
    annotation (Placement(transformation(extent={{-26,10},{-6,30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Sources.Ramp ramp2(
    duration=1,
    offset=-1,
    height=2) "Block that generates ramp signal"
    annotation (Placement(transformation(extent={{-26,-32},{-6,-12}})));

  Buildings.Experimental.OpenBuildingControl.CDL.Logical.Less less1
    annotation (Placement(transformation(extent={{26,-10},{46,10}})));

equation
  connect(ramp1.y, less1.u1)
    annotation (Line(points={{-5,20},{8,20},{8,0},{24,0}}, color={0,0,127}));
  connect(ramp2.y, less1.u2) annotation (Line(points={{-5,-22},{10,-22},{10,-8},
          {24,-8}}, color={0,0,127}));
  annotation (
  experiment(StopTime=1.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/Logical/Validation/Less.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.CDL.Logical.Less\">
Buildings.Experimental.OpenBuildingControl.CDL.Logical.Less</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
April 1, 2017, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>

</html>"));
end Less;
