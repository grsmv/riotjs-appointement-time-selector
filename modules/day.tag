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
                _endTime =this.opts.day.date.setHours(this.opts.settings.hours[_lastHour]),

                startTime = new Date(_startTime),
                endTime = new Date(_endTime);

            // generate array with size of minutes between start and end dates
            var minutesList = (new Array(this.parent.minutesBetweenDates(endTime, startTime))).fill(0);

            // intersect unavailable minutes
            unavailableTimeSlots.forEach(function(slot){
                // get start position of slot relatively to day start
                var slotStartPosition = this.parent.minutesBetweenDates(slot.start, startTime);

                // get slot durations in minutes
                var slotDuration = this.parent.minutesBetweenDates(slot.end, slot.start);

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
                            start: startTime.setMinutes(index),
                            end: startTime.setMinutes(index)
                        };
                    } else {
                        timePointer.end = startTime.setMinutes(index);
                    }
                }
                if (minuteMarker === 1) {
                    if (timePointer !== null) {
                        availableTimeSlots.push(timePointer);
                        timePointer = null;
                    }
                }
            });

            return availableTimeSlots;
        };

        console.log(this.getAvailableTimeSlots(this.unavailableTimeSlots));

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