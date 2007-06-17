#
# jwarbirds.nas - A common nas script for Japanese warbirds.
# Feb. 03, 2006: Tat Nishioka
#
# Overview:
# JapaneseWarbirds class has a collection of property "observers",
# which updates or overrides some FlightGear property.
#
# Once this class is instanciated, its object will automatically register
# timer. It, then, invoke "update" methods of all registered observers on
# each timer event. When you add a new observer for a new gauge, write a
# new observer class in your aircraft's nasal script (say ki-84.nas).
#
# Usage:
# The following code in an aircraft specific nasal file (say ki-84.nas) let
# Ki-84 use three predefined observers.
#
# var ki84 = JapaneseWarbirds.new();
# var observers = [Altimeter.new(), BoostGauge.new(), GForce.new()];
# foreach(observer; observers) { ki84.addObserver(observer)
#
# Design Note:
# This script helps Japanese War-birds developers concentrate on making
# aircraft specific observers since the common code and the aircraft specific
# code are separated. When you make a new aircraft, copy jwarbirds.nas
# into its Nasal directory. Then write <aircraft_name>.nas file that contains
# the instanciation of JapaneseWarbirds class and aircraft specific observers.
# If you find several aircraft have the same observers, put these into
# jwarbirds.nas. Do not put aircraft specific observers into jwarbird.nas
#

#
# Canopy class - this is not an observer
#
Canopy = {
  new : func {
    obj = { parents : [Canopy],
          canopy : aircraft.door.new("/controls/canopy", 2) };
    setlistener("/controls/canopy/opened", me.toggleOpenClose(), 1);
    return obj;
  },

  toggleOpenClose : func {
    me.canopy.move(cmdarg().getBoolValue());
  }
};

#
# G-Force observer.
# This class updates the viewpoint of the pilot regarding the G-force.
#
GForce = {
  new : func {
   obj = { parents : [GForce] };
    return obj;
  },

  update : func {
    force = getprop("/accelerations/pilot-g");
    if (force == nil) { force = 1.0; }
    eyepoint = getprop("sim/view/config/y-offset-m") + 0.01;
    eyepoint -= (force * 0.01);
    if (getprop("/sim/current-view/view-number") < 1) {
      setprop("/sim/current-view/y-offset-m", eyepoint);
    }
  }
};

#
# Altimeter observer - unit converter (ft to m) for altimeter.
#
Altimeter = {
  new : func {
    obj = { parents : [Altimeter] };
    setprop("/instrumentation/altimeter/indicated-altitude-m", 0.0);
    return obj;
  },

  update: func {
    setprop("/instrumentation/altimeter/indicated-altitude-m", getprop("/instrumentation/altimeter/indicated-altitude-ft") * 0.3048);
  }
};

#
# Cylinder temperature observer - simulates the cylinder temperature
#
CylinderTemperature = {
  new: func {
    obj = { parents : [CylinderTemperature] };
    setprop("/engines/engine/cyl-temp", 0.0);
    return obj;
  },

  update: func {
    if (getprop("/engines/engine/running") != 0) {
      interpolate("/engines/engine/cyl-temp", 0.5 + (getprop("/controls/engines/engine/throttle") * 0.5), 150);
    } else {
      interpolate("/engines/engine/cyl-temp", 0.0, 500);
    }
  }
};

#
# BoostGause observer - unit converter from inHg to mmHg
#
BoostGauge = {
  new: func {
    obj = { parents: [BoostGauge] };
    return obj;
  },

  update: func {
      mp_osi = getprop("/engines/engine/mp-osi");
      interpolate("/engines/engine/boost-gauge-mmhg", mp_osi * 25.4 - 750.006168, 0.2);
  }
};

#
# Japanese Warbird class - adds and updates observers
#
JapaneseWarbird = {
  new : func {
    obj = { parents : [JapaneseWarbird],
	    observers : [] };
    obj.registerTimer();
    return obj;
  },

  #
  # addObserver(observer)
  # add an observer object to the JapaneseWarbird object
  # each observer must have a method named "update"
  #
  addObserver : func(observer) {
    append(me.observers, observer);
  },

  #
  # update()
  # update each observer in turn
  #
  update : func {
    # checks if fdm is initialized by reading the engine's running status
    if (getprop("/engines/engine/running") != nil) {
      foreach (observer; me.observers) {
        observer.update();
      }
    }
    me.registerTimer();
  },

  #
  # timer driven function
  #
  registerTimer : func {
    settimer(func { me.update() }, 0);
  }
}
