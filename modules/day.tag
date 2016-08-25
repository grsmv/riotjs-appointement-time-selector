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