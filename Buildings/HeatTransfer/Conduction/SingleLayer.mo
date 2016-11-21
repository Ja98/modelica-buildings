within Buildings.HeatTransfer.Conduction;
model SingleLayer "Model for single layer heat conductance"
  extends Buildings.HeatTransfer.Conduction.BaseClasses.PartialConductor(
   final R=if (material.R < Modelica.Constants.eps) then material.x/material.k/A else material.R/A);
   // if material.R == 0, then the material specifies material.k, and this model specifies x
   // For resistances, material.k need not be specified, and hence we use material.R
  // The value T[:].start is used by the solver when finding initial states
  // that satisfy dT/dt=0, which requires solving a system of nonlinear equations
  // if the convection coefficient is a function of temperature.
  Modelica.SIunits.Temperature T[nSta](start=
   if placeCapacityAtSurf_a then
     cat(1,
       {T_a_start},
       {(T_a_start + (T_b_start - T_a_start)*UA*sum(RNod[k] for k in 1:i-1)) for i in 2:nSta})
   else
    {(T_a_start + (T_b_start - T_a_start)*UA*sum(RNod[k] for k in 1:i)) for i in 1:nSta},
   each nominal=300)
    "Temperature at the states";
        // placeCapacityAtSurf_a == false
  Modelica.SIunits.HeatFlowRate Q_flow[nSta+1]
    "Heat flow rates to each state";
  Modelica.SIunits.SpecificInternalEnergy u[nSta](each nominal=270000)
    "Definition of specific internal energy";

  // fixme: the parameter below is for testing only and may be removed
  //        for the production release
  parameter Boolean placeCapacityAtSurf_a=false
    "Set to true to place the capacity at the surface a of the layer"
    annotation (Dialog(tab="Dynamics"),
                Evaluate=true);
  parameter Boolean placeCapacityAtSurf_b=false
    "Set to true to place the capacity at the surface a of the layer"
    annotation (Dialog(tab="Dynamics"),
                Evaluate=true);

  replaceable parameter Data.BaseClasses.Material material
    "Material from Data.Solids, Data.SolidsPCM or Data.Resistances"
    annotation (choicesAllMatching=true, Placement(transformation(extent={{60,60},
            {80,80}})));

  parameter Boolean steadyStateInitial=false
    "=true initializes dT(0)/dt=0, false initializes T(0) at fixed temperature using T_a_start and T_b_start"
        annotation (Dialog(group="Initialization"), Evaluate=true);
  parameter Modelica.SIunits.Temperature T_a_start=293.15
    "Initial temperature at port_a, used if steadyStateInitial = false"
    annotation (Dialog(group="Initialization", enable=not steadyStateInitial));
  parameter Modelica.SIunits.Temperature T_b_start=293.15
    "Initial temperature at port_b, used if steadyStateInitial = false"
    annotation (Dialog(group="Initialization", enable=not steadyStateInitial));
   parameter Integer nSta2=material.nSta "Number of states in a material"
     annotation (Evaluate=true);
protected
  final parameter Integer nSta=
    max(nSta2,
        if placeCapacityAtSurf_a or placeCapacityAtSurf_b then 2 else 1)
    "Number of state variables";
  final parameter Integer nR=nSta+1 "Number of thermal resistances";
  parameter Modelica.SIunits.ThermalResistance RNod[nR]=
    if (placeCapacityAtSurf_a and placeCapacityAtSurf_b) then
      if (nSta==2) then
        {(if i==1 or i==nR then 0 else R/(nSta-1)) for i in 1:nR}
      else
        {(if i==1 or i==nR then 0 elseif i==2 or i==nR-1 then R/(2*(nSta-2)) else R/(nSta-2)) for i in 1:nR}
      elseif (placeCapacityAtSurf_a and (not placeCapacityAtSurf_b)) then
        {(if i==1 then 0 elseif i==2 or i==nR then R/(2*(nSta-1)) else R/(nSta-1)) for i in 1:nR}
    elseif (placeCapacityAtSurf_b and (not placeCapacityAtSurf_a)) then
       {(if i==nR then 0 elseif i==1 or i==nR-1 then R/(2*(nSta-1)) else R/(nSta-1)) for i in 1:nR}
    else
      {R/(if i==1 or i==nR then (2*nSta) else nSta) for i in 1:nR}
    "Thermal resistance";

  parameter Modelica.SIunits.Mass m[nSta]=
   (A*material.x*material.d) *
   (if (placeCapacityAtSurf_a and placeCapacityAtSurf_b) then
     if (nSta==2) then
       {1/(2*(nSta-1)) for i in 1:nSta}
     else
       {1/(if i==1 or i==nSta or i==2 or i==nSta-1 then (2*(nSta-2)) else (nSta-2)) for i in 1:nSta}
     elseif (placeCapacityAtSurf_a and (not placeCapacityAtSurf_b)) then
       {1/(if i==1 or i==2 then (2*(nSta-1)) else (nSta-1)) for i in 1:nSta}
     elseif (placeCapacityAtSurf_b and (not placeCapacityAtSurf_a)) then
       {1/(if i==nSta or i==nSta-1 then (2*(nSta-1)) else (nSta-1)) for i in 1:nSta}
     else
       {1/(nSta) for i in 1:nSta})
    "Mass associated with the temperature state";

  final parameter Modelica.SIunits.HeatCapacity C[nSta] = m*material.c
    "Heat capacity associated with the temperature state";
  final parameter Real CInv[nSta]=
    if material.steadyState then zeros(nSta) else {1/C[i] for i in 1:nSta}
    "Inverse of heat capacity associated with the temperature state";

  parameter Modelica.SIunits.SpecificInternalEnergy ud[Buildings.HeatTransfer.Conduction.nSupPCM](
    each fixed=false)
    "Support points for derivatives (used for PCM)";
  parameter Modelica.SIunits.Temperature Td[Buildings.HeatTransfer.Conduction.nSupPCM](
    each fixed=false)
    "Support points for derivatives (used for PCM)";
  parameter Real dT_du[Buildings.HeatTransfer.Conduction.nSupPCM](
    each fixed=false,
    each unit="kg.K2/J")
    "Derivatives dT/du at the support points (used for PCM)";

initial equation
  assert(abs(sum(RNod) - R) < 1E-10, "Error in computing resistances.");
  assert(abs(sum(m) - A*material.x*material.d) < 1E-10, "Error in computing mass.");

  // The initialization is only done for materials that store energy.
    if not material.steadyState then
      if steadyStateInitial then
        if material.phasechange then
          der(u) = zeros(nSta);
        else
          der(T) = zeros(nSta);
        end if;
      else
        if placeCapacityAtSurf_a then
          T[1] = T_a_start;
          for i in 2:nSta loop
            T[i] =T_a_start + (T_b_start - T_a_start)*UA*sum(RNod[k] for k in 1:i-1);
          end for;
        else // placeCapacityAtSurf_a == false
          for i in 1:nSta loop
            T[i] = T_a_start + (T_b_start - T_a_start)*UA*sum(RNod[k] for k in 1:i);
          end for;
        end if;
      end if;
    end if;

   if material.phasechange then
     (ud, Td, dT_du) = Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u(
       c =  material.c,
       TSol=material.TSol,
       TLiq=material.TLiq,
       LHea=material.LHea,
       ensureMonotonicity=material.ensureMonotonicity);
   else
     ud    = zeros(Buildings.HeatTransfer.Conduction.nSupPCM);
     Td    = zeros(Buildings.HeatTransfer.Conduction.nSupPCM);
     dT_du = zeros(Buildings.HeatTransfer.Conduction.nSupPCM);
   end if;
equation
    port_a.Q_flow = +Q_flow[1];
    port_b.Q_flow = -Q_flow[end];

    port_a.T-T[1]    = if placeCapacityAtSurf_a then 0 else Q_flow[1]*RNod[1];
    T[nSta]-port_b.T = if placeCapacityAtSurf_b then 0 else Q_flow[end]*RNod[end];

    for i in 1:nSta-1 loop
       // Q_flow[i+1] is heat flowing from (i) to (i+1)
       // because T[1] has Q_flow[1] and Q_flow[2] acting on it.
       T[i]-T[i+1] = Q_flow[i+1]*RNod[i];
    end for;

    // Steady-state heat balance
    if material.steadyState then
      for i in 2:nSta+1 loop
        Q_flow[i] = port_a.Q_flow;
      end for;

      for i in 1:nSta loop
        if material.phasechange then
          // Phase change material
          T[i]=Buildings.HeatTransfer.Conduction.BaseClasses.temperature_u(
                    ud=ud,
                    Td=Td,
                    dT_du=dT_du,
                    u=u[i]);
        else
          // Regular material
          u[i]=0; // u is not required in this case
        end if;
      end for;
    else
      // Transient heat conduction
      if material.phasechange then
        // Phase change material
        for i in 1:nSta loop
          der(u[i]) = (Q_flow[i]-Q_flow[i+1])/m[i];
          // Recalculation of temperature based on specific internal energy
          T[i]=Buildings.HeatTransfer.Conduction.BaseClasses.temperature_u(
                    ud=ud,
                    Td=Td,
                    dT_du=dT_du,
                    u=u[i]);
        end for;
      else
        // Regular material
        for i in 1:nSta loop
          der(T[i]) = (Q_flow[i]-Q_flow[i+1])*CInv[i];
          u[i]=0; // u is not required in this case
        end for;
      end if;
    end if;

  annotation ( Icon(coordinateSystem(
          preserveAspectRatio=false,extent={{-100,-100},{100,100}}), graphics={
        Text(
          extent={{-100,-80},{6,-98}},
          lineColor={0,0,255},
          textString="%material.x"),
        Text(
          extent={{8,-74},{86,-104}},
          lineColor={0,0,255},
          textString="%nSta"),
   Rectangle(
    extent={{-60,80},{60,-80}},     fillColor={215,215,215},
   fillPattern=FillPattern.Solid,    lineColor={175,175,175}),
   Line(points={{-92,0},{90,0}},      color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None),
   Line(points={{8,-40},{-6,-40}},        color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None),
   Line(points={{14,-32},{-12,-32}},      color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None),            Line(
          points={{0,0},{0,-32}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None),       Rectangle(extent={{-40,6},{-20,-6}},
   lineColor = {0, 0, 0}, lineThickness =  0.5, fillColor = {255, 255, 255},
   fillPattern = FillPattern.Solid), Rectangle(extent={{20,6},{40,-6}},
   lineColor = {0, 0, 0}, lineThickness =  0.5, fillColor = {255, 255, 255},
   fillPattern = FillPattern.Solid),
   Line(points={{66,-40},{52,-40}},       color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None,
   visible=placeCapacityAtSurf_b),
   Line(points={{72,-32},{46,-32}},       color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None,
   visible=placeCapacityAtSurf_b),            Line(points={{59,0},{59,-32}},
   color = {0, 0, 0}, thickness = 0.5, smooth = Smooth.None,
   visible=placeCapacityAtSurf_b),
   Line(points={{-59,0},{-59,-32}},
   color = {0, 0, 0}, thickness = 0.5, smooth = Smooth.None,
   visible=placeCapacityAtSurf_a),
   Line(points={{-46,-32},{-72,-32}},     color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None,
   visible=placeCapacityAtSurf_a),
   Line(points={{-52,-40},{-66,-40}},     color = {0, 0, 0}, thickness = 0.5,
   smooth = Smooth.None,
   visible=placeCapacityAtSurf_a)}),
defaultComponentName="lay",
    Documentation(info="<html>
This is a model of a heat conductor for a single layer of homogeneous material
that computes transient or steady-state heat conduction.

<h4>Transient heat conduction in materials without phase change</h4>
<p>
If the material is a record that extends
<a href=\"modelica://Buildings.HeatTransfer.Data.Solids\">
Buildings.HeatTransfer.Data.Solids</a> and its
specific heat capacity (as defined by the record <code>material.c</code>)
is non-zero, then this model computes <i>transient</i> heat conduction, i.e., it
computes a numerical approximation to the solution of the heat equation
</p>
<p align=\"center\" style=\"font-style:italic;\">
   &rho; c (&part; T(s,t) &frasl; &part;t) =
    k (&part;&sup2; T(s,t) &frasl; &part;s&sup2;),
</p>
<p>
where
<i>&rho;</i>
is the mass density,
<i>c</i>
is the specific heat capacity per unit mass,
<i>T</i>
is the temperature at location <i>s</i> and time <i>t</i> and
<i>k</i> is the heat conductivity.
At the locations <i>s=0</i> and <i>s=x</i>, where <i>x</i> is the
material thickness, the temperature and heat flow rate is equal to the
temperature and heat flow rate of the heat ports.
</p>
<h4>Transient heat conduction in phase change materials</h4>
<p>
If the material is declared using a record of type
<a href=\"modelica://Buildings.HeatTransfer.Data.SolidsPCM\">
Buildings.HeatTransfer.Data.SolidsPCM</a>, the heat transfer
in a phase change material is computed.
The record <a href=\"modelica://Buildings.HeatTransfer.Data.SolidsPCM\">
Buildings.HeatTransfer.Data.SolidsPCM</a>
declares the solidus temperature <code>TSol</code>,
the liquidus temperature <code>TLiq</code> and the latent heat of
phase transformation <code>LHea</code>.
For heat transfer with phase change, the specific internal energy <i>u</i>
is the dependent variable, rather than the temperature.
Therefore, the governing equation is
</p>
<p align=\"center\" style=\"font-style:italic;\">
   &rho; (&part; u(s,t) &frasl; &part;t) =
    k (&part;&sup2; T(s,t) &frasl; &part;s&sup2;).
</p>
<p>
The constitutive
relation between specific internal energy <i>u</i> and temperature <i>T</i> is defined in
<a href=\"modelica://Buildings.HeatTransfer.Conduction.BaseClasses.enthalpyTemperature\">
Buildings.HeatTransfer.Conduction.BaseClasses.enthalyTemperature</a> by using
cubic hermite spline interpolation with linear extrapolation.
</p>
<h4>Steady-state heat conduction</h4>
<p>
If <code>material.c=0</code>, or if the material extends
<a href=\"modelica://Buildings.HeatTransfer.Data.Resistances\">
Buildings.HeatTransfer.Data.Resistances</a>,
then steady-state heat conduction is computed. In this situation, the heat
flow between its heat ports is
</p>
<p align=\"center\" style=\"font-style:italic;\">
   Q = A &nbsp; k &frasl; x &nbsp; (T<sub>a</sub>-T<sub>b</sub>),
</p>
<p>
where
<i>A</i> is the cross sectional area,
<i>x</i> is the layer thickness,
<i>T<sub>a</sub></i> is the temperature at port a and
<i>T<sub>b</sub></i> is the temperature at port b.
</p>
<h4>Spatial discretization</h4>
<p>
To spatially discretize the heat equation, the construction is
divided into compartments or control volumes with <code>material.nSta &ge; 1</code> state variables.
Each control volume has the same material properties.
The state variables are connected to each other through thermal resistances.
If <code>placeCapacityAtSurf_a = true</code>, a heat capacity is placed
at the surface a, and similarly, if
<code>placeCapacityAtSurf_b = true</code>, a heat capacity is placed
at the surface b.
Otherwise, these heat capacities are placed inside the material, away
from the surface.
Thus, to obtain
the surface temperature, use <code>port_a.T</code> (or <code>port_b.T</code>)
and not the variable <code>T[1]</code>.
</p>

As an example, we assume a material with a length of <code>x</code> 
and a discretization with 4 state variables and 4 control volumes.
<ul>
<li>
If <code>placeCapacityAtSurf_a = false and placeCapacityAtSurf_b = false</code>, 
then the 4 state variables are distributed equally over the
length <code>x/4</code>.
<p align=\"left\"><img alt=\"image\" src=\"modelica://Buildings/Resources/Images/HeatTransfer/Conduction/noStateAtSurface.png\"/>
</li>
<li>
If <code>placeCapacityAtSurf_a = true or placeCapacityAtSurf_b = true</code>, 
then the remaining 3 states will be distributed equally over the length of the material.
<p align=\"left\"><img alt=\"image\" src=\"modelica://Buildings/Resources/Images/HeatTransfer/Conduction/oneStateAtSurface.png\"/>
</li>
<li>
If <code>placeCapacityAtSurf_a = true and placeCapacityAtSurf_b = true</code>, 
then the remaining 2 states will be distributed equally over the length of the material.
<p align=\"left\"><img alt=\"image\" src=\"modelica://Buildings/Resources/Images/HeatTransfer/Conduction/twoStatesAtSurface.png\"/>
</li>
</ul>

<p>
To build multi-layer constructions,
use
<a href=\"Buildings.HeatTransfer.Conduction.MultiLayer\">
Buildings.HeatTransfer.Conduction.MultiLayer</a> instead of this model.
</p>
<h4>Boundary conditions</h4>
<p>
Note that if <code>placeCapacityAtSurf_a = true</code>
and <code>steadyStateInitial = false</code>, then 
there is temperature state on the surface a with prescribed
initial value. Hence, in this situation, it is not possible to
connect a temperature boundary condition such as
<a href=\"modelica://Buildings.HeatTransfer.Sources.FixedTemperature\">
Buildings.HeatTransfer.Sources.FixedTemperature</a> as this would
overspecify the initial condition. Rather, place a thermal resistance
between the boundary condition and the surface of this model.
</p>
</html>",
revisions="<html>
<ul>
<li>
November 17, 2016, by Thierry S. Nouidui:<br/>
Added parameter <code>nSta2</code> to avoid translation error
in Dymola 2107. This is a work-around for a bug in Dymola 
which will be addressed in future releases.
</li>
<li>
November 11, 2016, by Thierry S. Nouidui:<br/>
Revised the implementation for adding a state at the surface.
</li>
<li>
October 29, 2016, by Michael Wetter:<br/>
Added option to place a state at the surface.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/565\">issue 565</a>.
</li>
<li>
March 1, 2016, by Michael Wetter:<br/>
Removed test for equality of <code>Real</code> variables.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/493\">issue 493</a>.
</li>
<li>
May 21, 2015, by Michael Wetter:<br/>
Reformulated function to reduce use of the division macro
in Dymola.
This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/417\">issue 417</a>.
</li>
<li>
October 17, 2014, by Michael Wetter:<br/>
Changed the input argument for the function
<code>Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u</code>
from type
<code>Buildings.HeatTransfer.Data.BaseClasses.Material</code>
to the elements of this type as OpenModelica fails to translate the
model if the input to this function is a record.
</li>
<li>
May 30, 2014, by Michael Wetter:<br/>
Removed undesirable annotation <code>Evaluate=true</code>.
</li>
<li>
January 22, 2013, by Armin Teskeredzic:<br/>
Implementation of phase-change materials based on enthalpy-linearisation method.
Phase-change properties defined in <code>material</code> record and relationship
between enthalpy and temperature defined in the <code>EnthalpyTemperature</code> function.
</li>
<li>
March 9, 2012, by Michael Wetter:<br/>
Removed protected variable <code>der_T</code> as it is not required.
</li>
<li>
March 6 2010, by Michael Wetter:<br/>
Changed implementation to allow steady-state and transient heat conduction
depending on the specific heat capacity of the material. This allows using the
same model in composite constructions in which some layers are
computed steady-state and other transient.
</li><li>
February 5 2009, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end SingleLayer;
