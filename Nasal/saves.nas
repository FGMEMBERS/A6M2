var view_list =[];
var view = props.globals.getNode("/sim").getChildren("view");
    for(var i=0; i<size(view); i+=1){
        append(view_list,"sim/view["~i~"]/config/default-field-of-view-deg");
        }
aircraft.data.add(view_list);

setlistener("/sim/current-view/view-number", func(vw){
    ViewNum = vw.getValue();
    setprop("sim/current-view/field-of-view",getprop("sim/view["~ViewNum~"]/config/default-field-of-view-deg"));
    },1,0);
