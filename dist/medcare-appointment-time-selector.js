riot.tag2('day', '<heading>{opts.day.title}</heading> <hour each="{hour in opts.settings.hours}"> <time-slot each="{slot in filterTimeSlots(hour)}" minutes-duration="{parent.minutesBetweenDates(slot.end, slot.start)}" hours-duration="{parent.hoursBetweenDates(slot.end, slot.start)}"></time-slot> </hour>', 'heading, hour, time-slot { display: block; } heading { width: 100%; text-align: center; font-size: .7em; color: #999; } hour { border-bottom: 1px solid #eee; } time-slot { width: 100%; height: 50%; background: #eee; }', '', function(opts) {
        this.unavailableTimeSlots = this.opts.settings.unavailableTime.filter(function(timeSlot){
            return this.parent.compareDates(timeSlot.start, this.opts.day.date);
        }.bind(this));

        this.filterTimeSlots = function(hour){
            return this.unavailableTimeSlots.filter(function(slot){
                return slot.start.getHours() === hour;
            }.bind(this));
        };

        this.getAvailableTimeSlots = function (unavailableTimeSlots) {
            var _startTime = this.opts.day.date.setHours(this.opts.settings.hours[0]),
                _lastHour = this.opts.settings.hours.length-1,
                _endTime =this.opts.day.date.setHours(this.opts.settings.hours[_lastHour]),

                startTime = new Date(_startTime),
                endTime = new Date(_endTime);

            var minutesList = (new Array(this.parent.minutesBetweenDates(endTime, startTime))).fill(0);

            unavailableTimeSlots.forEach(function(slot){

                var slotStartPosition = this.parent.minutesBetweenDates(slot.start, startTime);

                var slotDuration = this.parent.minutesBetweenDates(slot.end, slot.start);

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

        this.on("mount", this.parent.applySettingsToElementHeight("hour"));

        this.on("mount", function(){
            [].slice.call(this.root.querySelectorAll("time-slot")).forEach(function(slot){
                var minutesInPercents = +slot.getAttribute("minutes-duration") / 60 * 100,
                    hoursInPercents = +slot.getAttribute("hours-duration") * 2;
                slot.style.height =  minutesInPercents + hoursInPercents + "%";
            });
        }.bind(this));
}, '{ }');
riot.tag2('manager', '<week settings="{settings}"></week>', 'manager week,[riot-tag="manager"] week { width: 100%; display: block; }', '', function(opts) {
        this.settings = {

            lineHeight: 45,

            hours: [9, 10, 11, 12, 13, 14, 15, 16, 17],
            minimumAppointmentDuration: 15,
            stepBetweenAppointments: 5,

            days: [
                {
                    title: "пн",
                    date: new Date("Mon Aug 20 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "вт",
                    date: new Date("Tue Aug 21 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "ср",
                    date: new Date("Wed Aug 22 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "чт",
                    date: new Date("Thu Aug 23 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "пт",
                    date: new Date("Fri Aug 24 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "сб",
                    date: new Date("Sat Aug 25 2016 00:00:00 GMT+0300 (EEST)")
                }, {
                    title: "нд",
                    date: new Date("Sun Aug 26 2016 00:00:00 GMT+0300 (EEST)")
                }
            ],
            unavailableTime: [
                {
                    start: new Date("Mon Aug 20 2016 10:00:00 GMT+0300 (EEST)"),
                    end: new Date("Mon Aug 20 2016 18:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Tue Aug 21 2016 09:00:00 GMT+0300 (EEST)"),
                    end: new Date("Tue Aug 21 2016 12:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Tue Aug 23 2016 10:00:00 GMT+0300 (EEST)"),
                    end: new Date("Tue Aug 23 2016 10:30:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Tue Aug 23 2016 12:00:00 GMT+0300 (EEST)"),
                    end: new Date("Tue Aug 23 2016 13:00:00 GMT+0300 (EEST)")
                },
                {
                    start: new Date("Fri Aug 24 2016 15:00:00 GMT+0300 (EEST)"),
                    end: new Date("Fri Aug 24 2016 18:00:00 GMT+0300 (EEST)")
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