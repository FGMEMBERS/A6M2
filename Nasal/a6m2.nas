# A6M2 Zero-Flighter

#
# Zero Flight's Gear class
# This class simulates the Zero's landing gears that
# one gear moves at a time.
#

var view_list =[];
var view = props.globals.getNode("/sim").getChildren("view");
    for(var i=0; i<size(view); i+=1){
        append(view_list,"sim/view["~i~"]/config/default-field-of-view-deg");
        }
aircraft.data.add(view_list);

ZeroGear = {
    new : func {
        obj = { parents : [ZeroGear],
            gear_direction : 1,
            gear_changing : 0,
            delay : 6,
            first_gear : "/gear/gear[0]/position-norm",
            second_gear : "/gear/gear[1]/position-norm" };
    setlistener("/controls/gear/gear-down", func { obj.transform(); });
    setprop(obj.first_gear, 1);
    setprop(obj.second_gear, 1);
    return obj;
    },

#
# transform the gears
#
    transform : func {
        last_direction = me.gear_direction;
        me.gear_direction = getprop("/controls/gear/gear-down");
        if (last_direction != me.gear_direction) {
            interpolate(me.first_gear, me.gear_direction, me.delay);
            settimer(func { me.transformSecondGear(); }, me.delay);
            me.gear_changing = 1;
        }
    },

  #
  # Starts changing the position of the second gear
  #
    transformSecondGear : func {
        interpolate(me.second_gear, me.gear_direction, me.delay);
        me.gear_changing = 0;
    }
};

var a6m2 = JapaneseWarbird.new();
var observers = [Altimeter.new(), BoostGauge.new(), CylinderTemperature.new(), ExhaustGasTemperature.new(27.9)];
foreach (observer; observers) {
    a6m2.addObserver(observer);
}

var zero_gear = ZeroGear.new();
