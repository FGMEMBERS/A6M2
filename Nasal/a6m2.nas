# Mitsubishi A6M2 model 21 
var force = 1.0;
var alt_m = 0.0;

toggle_canopy = func{
}

updates = func{
  setprop("/instrumentation/altimeter/indicated-altitude-m",getprop("/instrumentation/altimeter/indicated-altitude-ft") * 0.3048);
   force = getprop("/accelerations/pilot-g");
   if(force == nil) {force = 1.0;}
   eyepoint = getprop("sim/view/config/y-offset-m") +0.01;
   eyepoint -= (force * 0.01);
   if(getprop("/sim/current-view/view-number") < 1){
      setprop("/sim/current-view/y-offset-m",eyepoint);
      }
  registerTimer();    
   }


registerTimer = func {
    settimer(updates, 0);
}

setlistener("/controls/canopy/opened", func {
    var position = cmdarg().getValue();
    interpolate("/controls/canopy/position-norm", position, 2);},1);

registerTimer();
