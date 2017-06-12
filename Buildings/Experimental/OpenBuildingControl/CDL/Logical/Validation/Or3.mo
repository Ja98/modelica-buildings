within Buildings.Experimental.OpenBuildingControl.CDL.Logical.Validation;
model Or3 "Validation model for the Or3 block"
extends Modelica.Icons.Example;

  Buildings.Experimental.OpenBuildingControl.CDL.Sources.BooleanPulse booPul1(
    width = 0.5,
    period = 1.5)
    "Block that outputs cyclic on and off"
    annotation (Placement(transformation(extent={{-26,24},{-6,44}})));
   Buildings.Experimental.OpenBuildingControl.CDL.Sources.BooleanPulse booPul2(
     width = 0.5,
     period = 3)
     "Block that outputs cyclic on and off"
     annotation (Placement(transformation(extent={{-26,-10},{-6,10}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Logical.Or3 or1
    annotation (Placement(transformation(extent={{26,-10},{46,10}})));

   Buildings.Experimental.OpenBuildingControl.CDL.Sources.BooleanPulse booPul3(
     width = 0.5, period=5)
     "Block that outputs cyclic on and off"
     annotation (Placement(transformation(extent={{-26,-44},{-6,-24}})));
equation
  connect(booPul3.y, or1.u3) annotation (Line(points={{-5,-34},{8,-34},{8,-8},{
          24,-8}},
                color={255,0,255}));
  connect(booPul2.y, or1.u2)
    annotation (Line(points={{-5,0},{9.5,0},{24,0}}, color={255,0,255}));
  connect(booPul1.y, or1.u1) annotation (Line(points={{-5,34},{10,34},{10,8},{
          24,8}},
                color={255,0,255}));
  annotation (
  experiment(StopTime=10.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/Logical/Validation/Or3.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.CDL.Logical.Or3\">
Buildings.Experimental.OpenBuildingControl.CDL.Logical.Or3</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
April 10, 2017, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>

</html>"));
end Or3;
