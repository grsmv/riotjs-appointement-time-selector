riot.tag2('day', '<heading>{opts.day.title}</heading> <draft-appointment each="{appointment in draftAppointments}" offset="{appointment.offset}" height="{appointment.height}" start="{appointment.start.toString()}" end="{appointment.end.toString()}"> </draft-appointment> <hour each="{hour in opts.settings.hours}"> <time-slot each="{slot in filterTimeSlots(hour)}" minutes-duration="{parent.minutesBetweenDates(slot.end, slot.start)}" hours-duration="{parent.hoursBetweenDates(slot.end, slot.start)}"></time-slot> </hour>', 'heading, hour, time-slot, draft-appointment { display: block; } heading { width: 100%; text-align: center; font-size: .7em; color: #999; } hour { border-bottom: 1px solid #eee; } time-slot { width: 100%; height: 50%; background: #eee; } draft-appointment { position: absolute; background: yellowgreen; opacity: 0; width: 100%; cursor: pointer; } draft-appointment:hover, draft-appointment.permanent { opacity: 1; }', 'style="position: relative;"', function(opts) {
        this.unavailableTimeSlots = this.opts.settings.unavailableTime.filter(function(timeSlot){
            return this.parent.compareDates(timeSlot.start, this.opts.day.date);
        }.bind(this));

        this.filterTimeSlots = function(hour){
            return this.unavailableTimeSlots.filter(function(slot){
                return slot.start.getHours() === hour;
            }.bind(this));
        };

        this.dayStartTime = null;
        this.dayEndTime = null;

        this.getAvailableTimeSlots = function (unavailableTimeSlots) {
            var _startTime = this.opts.day.date.setHours(this.opts.settings.hours[0]),
                _lastHour = this.opts.settings.hours.length-1,
                _endTime = this.opts.day.date.setHours(this.opts.settings.hours[_lastHour]+1);

            this.dayStartTime = new Date(_startTime);
            this.dayEndTime = new Date(_endTime);

            var minutesList = (new Array(this.parent.minutesBetweenDates(this.dayEndTime, this.dayStartTime))).fill(0);

            unavailableTimeSlots.forEach(function(slot){

                var slotStartPosition = this.parent.minutesBetweenDates(slot.start, this.dayStartTime);

                var slotDuration = this.parent.minutesBetweenDates(slot.end, slot.start)+1;

                for (var i = slotStartPosition; i < (slotStartPosition+slotDuration); i++) {
                    minutesList[i]=1;
                }
            }.bind(this));

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

        this.getListOfPotentialAppointment = function(availableTimeSlots) {
            var potentialAppointments = [];

            var pixelsInMinute = this.parent.settings.lineHeight / 60;
            var appointmentHeight = this.parent.settings.minimumAppointmentDuration * pixelsInMinute;

            availableTimeSlots.forEach(function(timeSlot){
                var minutes = this.parent.minutesBetweenDates(timeSlot.end, timeSlot.start),
                    duration = this.parent.settings.minimumAppointmentDuration,
                    step = this.parent.settings.stepBetweenAppointments;

                var max = Math.floor((minutes - duration) / step + 1);
                for (var i = 0; i < max; i++) {
                    var start = (new Date(timeSlot.start)).setMinutes(timeSlot.start.getMinutes() + step * i);
                    var end = (new Date(start)).setMinutes(new Date(start).getMinutes() + duration);
                    var offsetInHours = this.parent.hoursBetweenDates(start, this.dayStartTime);
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

        this.on("mount", this.parent.applySettingsToElementHeight("hour"));

        this.on("mount", function(){

            [].slice.call(this.root.querySelectorAll("time-slot")).forEach(function(slot){
                var minutesInPercents = +slot.getAttribute("minutes-duration") / 60 * 100,
                    hoursInPercents = +slot.getAttribute("hours-duration") * 2;
                slot.style.height =  minutesInPercents + hoursInPercents + "%";
            });

            [].slice.call(this.root.querySelectorAll("draft-appointment")).forEach(function(appointment){
                var height = appointment.getAttribute("height");
                appointment.style.height = height + "px";

                var offset = appointment.getAttribute("offset");
                appointment.style.marginTop = offset + "px";
            });

            this.root.addEventListener("click", function(event){
                if (event.target.tagName === "DRAFT-APPOINTMENT") {
                    var appointment = event.target;
                    appointment.className = "permanent";
                }
            })
        }.bind(this));
}, '{ }');
riot.tag2('manager', '<week settings="{settings}"></week>', 'manager week,[riot-tag="manager"] week { width: 100%; display: block; }', '', function(opts) {
        this.settings = {

            lineHeight: 45,

            hours: [9, 10, 11, 12, 13, 14, 15, 16, 17],
            minimumAppointmentDuration: 30,
            stepBetweenAppointments: 5,

            days: [
                {
                    title: "пн",
                    date: new Date("Mon Aug 22 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "вт",
                    date: new Date("Tue Aug 23 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "ср",
                    date: new Date("Wed Aug 24 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "чт",
                    date: new Date("Thu Aug 25 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "пт",
                    date: new Date("Fri Aug 26 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "сб",
                    date: new Date("Sat Aug 27 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "нд",
                    date: new Date("Sun Aug 28 2016 00:00:00 GMT+0300 (EEST)")
                }
            ],
            unavailableTime: [
                {
                    start: new Date("Mon Aug 22 2016 10:00:00 GMT+0300 (EEST)"),
                    end: new Date("Mon Aug 22 2016 18:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Tue Aug 23 2016 09:00:00 GMT+0300 (EEST)"),
                    end: new Date("Tue Aug 23 2016 12:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Wed Aug 24 2016 10:00:00 GMT+0300 (EEST)"),
                    end: new Date("Wed Aug 24 2016 10:30:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Wed Aug 24 2016 12:00:00 GMT+0300 (EEST)"),
                    end: new Date("Wed Aug 24 2016 13:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Fri Aug 26 2016 15:00:00 GMT+0300 (EEST)"),
                    end: new Date("Fri Aug 26 2016 18:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Sat Aug 27 2016 11:00:00 GMT+0300 (EEST)"),
                    end: new Date("Sat Aug 27 2016 14:00:00 GMT+0300 (EEST)")
                }
            ]
        };

        this.mixin({

            applySettingsToElementHeight: function(selector) {
                return function() {
                    var nodeList = document.querySelectorAll(selector);
                    [].slice.call(nodeList).forEach(function (div) {
                        div.style.height = this.settings.lineHeight + "px"
                    }.bind(this));
                }
            },

            compareDates: function(a, b) {
                return a.getYear() === b.getYear() &&
                        a.getMonth() === b.getMonth() &&
                        a.getDay() === b.getDay();
            },

            minutesBetweenDates: function(a, b) {
                return (a - b) / 60 / 1000;
            },

            hoursBetweenDates: function(a, b) {
                return this.minutesBetweenDates(a, b) / 60;
            }
        });
}, '{ }');
riot.tag2('week', '<hour-titles> <div each="{hour in opts.settings.hours}">{hour}</div> </hour-titles> <day each="{day in opts.settings.days}" day="{day}" unavailable-time-slots="{filterTimeSlotsWithAppropriateDate(day.date)}" settings="{parent.opts.settings}"></day>', 'week day,[riot-tag="week"] day,week hour-titles,[riot-tag="week"] hour-titles { display: block; float: left; } week day,[riot-tag="week"] day { width: calc(90% / 7); } week hour-titles,[riot-tag="week"] hour-titles { width: 10%; margin: 32px 0 0 0; text-align: center; } week hour-titles div,[riot-tag="week"] hour-titles div { font-size: .6em; color: #999; }', '', function(opts) {
        this.on("mount", this.applySettingsToElementHeight("hour-titles div"));
}, '{ }');