<manager>

    <week settings="{settings}"></week>

    <script>
        this.settings = {
            // visual settings
            lineHeight: 45,

            // time settings
            hours: [9, 10, 11, 12, 13, 14, 15, 16, 17],
            minimumAppointmentDuration: 30,
            stepBetweenAppointments: 5,

            currentWeekNumber: 34,
            links: {
                nextWeek: "2016/35",
                previousWeek: "2016/33"
            },

            // i18n
            i18n: {
                previousWeek: "Попередній тиждень",
                nextWeek: "Наступний тиждень",
                selectedTime: "обраний час",
                weekTitle: "22 - 28 серпня 2016",
                month: ["січня", "лютого","березня","квітня", "травня", "червня", "липня", "серпня", "вересня", "жовтня", "листопада", "грудня"]
            },

            // sample data
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

            /**
             * Applying element's height from value, stored in settings
             * @param String
             * @returns {Function}
             */
            applySettingsToElementHeight: function(selector) {
                return function() {
                    var nodeList = document.querySelectorAll(selector);
                    [].slice.call(nodeList).forEach(function (div) {
                        div.style.height = this.settings.lineHeight + "px"
                    }.bind(this));
                }
            },

            /**
             * Checking if two Dates belonging to one calendar day
             * @param Date
             * @param Date
             * @returns {boolean}
             */
            compareDates: function(a, b) {
                return a.getYear() === b.getYear() &&
                        a.getMonth() === b.getMonth() &&
                        a.getDay() === b.getDay();
            },

            /**
             * Getting difference between two dates in minutes
             * @param a
             * @param b
             * @returns {Number}
             */
            minutesBetweenDates: function(a, b) {
                return (a - b) / 60 / 1000;
            },

            /**
             * Getting difference between two dates in hours
             * @param a
             * @param b
             * @returns {Number}
             */
            hoursBetweenDates: function(a, b) {
                return this.minutesBetweenDates(a, b) / 60;
            },

            /**
             * Formatting numbers for kitchen clock
             * @param string
             * @returns {string}
             */
            formatNumber: function(_number) {
                var number = String(_number);
                return number.length < 2 ? "0" + number : number
            },

            /**
             * Performing async http GET request
             * @param string
             * @param function
             */
            get: function(url, callback) {
                var http = new XMLHttpRequest();
                http.onreadystatechange = function() {
                    if (http.readyState === 4 && http.status === 200) {
                        callback(http.responseText);
                    }
                    http.open("GET", url, true);
                    http.send(null);
                }
            },

            //
            selectedDate: riot.observable(),
        });
    </script>

    <style scoped>
        week {
            width: 100%;
            display: block;
        }
    </style>
</manager>