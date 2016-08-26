<day style="position: relative;">
    <heading>{opts.day.title}</heading>

    <draft-appointment each={appointment in draftAppointments}
                       offset={appointment.offset}
                       height={appointment.height}
                       start={appointment.start.toString()}
                       end={appointment.end.toString()}>
    </draft-appointment>

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

        this.dayStartTime = null;
        this.dayEndTime = null;

        /**
         * Calculating available time slots for the day
         * @param {Array.<Object>}
         * @returns {Array.<Object>}
         */
        this.getAvailableTimeSlots = function (unavailableTimeSlots) {
            var _startTime = this.opts.day.date.setHours(this.opts.settings.hours[0]),
                _lastHour = this.opts.settings.hours.length-1,
                _endTime = this.opts.day.date.setHours(this.opts.settings.hours[_lastHour]+1);

            this.dayStartTime = new Date(_startTime);
            this.dayEndTime = new Date(_endTime);

            // generate array with size of minutes between start and end dates
            var minutesList = (new Array(this.parent.minutesBetweenDates(this.dayEndTime, this.dayStartTime))).fill(0);

            // intersect unavailable minutes
            unavailableTimeSlots.forEach(function(slot){
                // get start position of slot relatively to day start
                var slotStartPosition = this.parent.minutesBetweenDates(slot.start, this.dayStartTime);

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
                            start: (new Date(this.dayStartTime)).setMinutes(index),
                            end: (new Date(this.dayStartTime)).setMinutes(index)
                        };
                    } else {
                        timePointer.end = (new Date(this.dayStartTime)).setMinutes(index);
                    }
                }
                if (minuteMarker === 1) {
                    if (timePointer !== null) {
                        availableTimeSlots.push(timePointer);
                        timePointer = null;
                    }
                }
            }.bind(this));

            return availableTimeSlots.map(function(f){
                return {
                    start: new Date(f.start),
                    end: new Date(f.end)
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

            var pixelsInMinute = this.parent.settings.lineHeight / 60;
            var appointmentHeight = this.parent.settings.minimumAppointmentDuration * pixelsInMinute;

            availableTimeSlots.forEach(function(timeSlot){
                var minutes = this.parent.minutesBetweenDates(timeSlot.end, timeSlot.start), // h
                    duration = this.parent.settings.minimumAppointmentDuration,              // l
                    step = this.parent.settings.stepBetweenAppointments;                     // s

                // (h - l) / s + 1
                var max = Math.floor((minutes - duration) / step + 1);
                for (var i = 0; i < max; i++) {
                    var start = (new Date(timeSlot.start)).setMinutes(timeSlot.start.getMinutes() + step * i);
                    var end = (new Date(start)).setMinutes(new Date(start).getMinutes() + duration);
                    var offsetInMinutes = this.parent.minutesBetweenDates(start, this.dayStartTime);

                    potentialAppointments.push({
                        start: start,
                        end: end,
                        offset: offsetInMinutes * pixelsInMinute
                    });
                }
            }.bind(this));

            potentialAppointments = potentialAppointments.map(function(pa){
                return {
                    start:  new Date(pa.start),
                    end:    new Date(pa.end),
                    offset: pa.offset,
                    height: appointmentHeight
                }
            });

            return potentialAppointments;
        };

        this.draftAppointments = this.getListOfPotentialAppointment(
                this.getAvailableTimeSlots(this.unavailableTimeSlots)
        );

        this.on("mount", function(){

            // updating hour height according to settings
            this.parent.applySettingsToElementHeight("hour").bind(this)();

            // updating unavailable-time-slots height proportionally to a `hour` element height
            [].slice.call(this.root.querySelectorAll("time-slot")).forEach(function(slot){
                var minutesInPercents = +slot.getAttribute("minutes-duration") / 60 * 100,
                    hoursInPercents = +slot.getAttribute("hours-duration") * 2;
                slot.style.height =  minutesInPercents + hoursInPercents + "%";
            });

            var dayDraftAppointments  = [].slice.call(this.root.querySelectorAll("draft-appointment"));
            var weekDraftAppointments = [].slice.call(this.parent.root.querySelectorAll("draft-appointment"));

            // updating draft-appointment height and  position
            dayDraftAppointments.forEach(function(appointment){
                var height = appointment.getAttribute("height");
                appointment.style.height = height + "px";

                var offset = appointment.getAttribute("offset");
                appointment.style.marginTop = offset + "px";
            });

            // working with clicks on draft-appointments
            this.root.addEventListener("click", function(event){
                if (event.target.tagName === "DRAFT-APPOINTMENT") {

                    weekDraftAppointments.forEach(function (app) {
                        app.className = "";
                    });

                    var appointment = event.target;
                    appointment.className = "permanent";

                    this.selectedDate.trigger("change", new Date(event.target.getAttribute("start")))
                }
            }.bind(this));
        }.bind(this));
    </script>

    <style>
        heading, hour, time-slot, draft-appointment {
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

        draft-appointment {
            position: absolute;
            background: yellowgreen;
            opacity: 0;
            width: 100%;
            cursor: pointer;
        }

            draft-appointment:hover{
                opacity: 0.7;
            }

            draft-appointment.permanent {
                opacity: 1;
                transition: opacity 0.5s;
            }
    </style>
</day>