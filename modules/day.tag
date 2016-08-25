<day>
    <heading>{opts.day.title}</heading>

    <hour each={hour in opts.settings.hours}>
        <time-slot each={slot in filterTimeSlots(hour)}
                   minutes-duration={ parent.minutesBetweenDates(slot.end, slot.start) }
                   hours-duration={ parent.hoursBetweenDates(slot.end, slot.start) }></time-slot>
    </hour>

    <script>
        this.unavailableTimeSlots = this.opts.settings.unavailableTime.filter(function(timeSlot){
            return this.parent.compareDates(timeSlot.start, this.opts.day.date);
        }.bind(this));

        /**
         * Filtering by hour list of time slots available for certain date
         * @param Number
         * @returns {Array.<Object>}
         */
        this.filterTimeSlots = function(hour){
            return this.unavailableTimeSlots.filter(function(slot){
                return slot.start.getHours() === hour;
            }.bind(this));
        };

        /**
         * Calculating available time slots for the day
         * @param {Array.<Object>}
         * @returns {Array.<Object>}
         */
        this.getAvailableTimeSlots = function (unavailableTimeSlots) {
            var _startTime = this.opts.day.date.setHours(this.opts.settings.hours[0]),
                _lastHour = this.opts.settings.hours.length-1,
                _endTime = this.opts.day.date.setHours(this.opts.settings.hours[_lastHour]),

                startTime = new Date(_startTime),
                endTime = new Date(_endTime);

            // generate array with size of minutes between start and end dates
            var minutesList = (new Array(this.parent.minutesBetweenDates(endTime, startTime))).fill(0);

            // intersect unavailable minutes
            unavailableTimeSlots.forEach(function(slot){
                // get start position of slot relatively to day start
                var slotStartPosition = this.parent.minutesBetweenDates(slot.start, startTime);

                // get slot durations in minutes
                var slotDuration = this.parent.minutesBetweenDates(slot.end, slot.start)+1;

                // mark slots positions in `placeholder`
                for (var i = slotStartPosition; i < (slotStartPosition+slotDuration); i++) {
                    minutesList[i]=1;
                }
            }.bind(this));

            // build list of available time ranges from intersection
            var availableTimeSlots = [],
                    timePointer = null;

            minutesList.push(1);
            minutesList.forEach(function(minuteMarker, index){
                if (minuteMarker === 0) {
                    if (timePointer === null) {
                        timePointer = {
                            start: (new Date(startTime)).setMinutes(index),
                            end: (new Date(startTime)).setMinutes(index)
                        };
                    } else {
                        timePointer.end = (new Date(startTime)).setMinutes(index);
                    }
                }
                if (minuteMarker === 1) {
                    if (timePointer !== null) {
                        availableTimeSlots.push(timePointer);
                        timePointer = null;
                    }
                }
            });

            return availableTimeSlots.map(function(f){
                return {
                    start: new Date(f.start),
                    end: new Date(f.end),
                }
            });
        };

        /**
         *
         * @param availableTimeSlots
         * @returns {Array}
         */
        this.getListOfPotentialAppointment = function(availableTimeSlots) {
            var potentialAppointments = [];

            availableTimeSlots.forEach(function(timeSlot){
                var minutes = this.parent.minutesBetweenDates(timeSlot.end, timeSlot.start), // h
                    duration = this.parent.settings.minimumAppointmentDuration,              // l
                    step = this.parent.settings.stepBetweenAppointments;                     // s

                var max = Math.floor((minutes - duration) / step + 1);
                for (var i = 0; i < max; i++) {
                    var start = (new Date(timeSlot.start)).setMinutes(timeSlot.start.getMinutes() + step * i);
                    var end = (new Date(start)).setMinutes(new Date(start).getMinutes() + duration);
                    appointment = {
                        start: start,
                        end: end
                    };
                    potentialAppointments.push(appointment);
                }

            }.bind(this));

            potentialAppointments = potentialAppointments.map(function(f){
                return {
                    start: new Date(f.start),
                    end: new Date(f.end)
                }
            });

            console.log(potentialAppointments);
            debugger;

            return potentialAppointments;
        };

        var availableTimeSlots = this.getAvailableTimeSlots(this.unavailableTimeSlots);
        this.getListOfPotentialAppointment(availableTimeSlots);

        // updating hour height according to settings
        this.on("mount", this.parent.applySettingsToElementHeight("hour"));

        // updating unavailable-time-slots height proportionally to a `hour` element height
        this.on("mount", function(){
            [].slice.call(this.root.querySelectorAll("time-slot")).forEach(function(slot){
                var minutesInPercents = +slot.getAttribute("minutes-duration") / 60 * 100,
                    hoursInPercents = +slot.getAttribute("hours-duration") * 2;
                slot.style.height =  minutesInPercents + hoursInPercents + "%";
            });
        }.bind(this));
    </script>

    <style>
        heading, hour, time-slot {
            display: block;
        }

        heading {
            width: 100%;
            text-align: center;
            font-size: .7em;
            color: #999;
        }

        hour {
            border-bottom: 1px solid #eee;
        }

        time-slot {
            width: 100%;
            height: 50%;
            background: #eee;
        }
    </style>
</day>