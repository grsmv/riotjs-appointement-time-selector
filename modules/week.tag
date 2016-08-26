<week>
    <week-header></week-header>

    <hour-titles>
        <div each={hour in opts.settings.hours}>{hour}</div>
    </hour-titles>

    <day each={day in opts.settings.days}
         day="{day}"
         unavailable-time-slots="{filterTimeSlotsWithAppropriateDate(day.date)}"
         settings="{parent.opts.settings}"></day>

    <script>
        this.on("mount", this.applySettingsToElementHeight("hour-titles div"));
    </script>

    <style scoped>
        day, hour-titles {
            display: block;
            float: left;
        }

        day {
            width: calc(90% / 7);
        }

        hour-titles {
            width: 10%;
            margin: 32px 0 0 0;
            text-align: center;
        }

            hour-titles div {
                font-size: .6em;
                color: #999;
            }
    </style>
</week>