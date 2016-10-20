<week-header>

    <header>

        <div class="previous-week">
            <a href="#" class="button small outline" role="button">
                { parent.settings.i18n.previousWeek }
            </a>
        </div>

        <div class="title">
            { parent.settings.i18n.weekTitle }

            <span if={selectedDateValue}>
                { parent.settings.i18n.selectedTime }:
                    { selectedDateValue.getDate() }
                    { parent.settings.i18n.month[selectedDateValue.getMonth()] },
                    { formatNumber(selectedDateValue.getHours()) }:{ formatNumber(selectedDateValue.getMinutes()) }
            </span>
            <span if={!selectedDateValue} style="opacity: 0;">.</span>
        </div>

        <div class="next-week">
            <a href="#" class="button small outline" role="button">
                { parent.settings.i18n.nextWeek }
            </a>
        </div>

        <script>
            this.selectedDateValue = null;
            this.selectedDate.on("change", function(value){
                this.selectedDateValue = value;
                this.update()
            }.bind(this));
        </script>
    </header>

    <style>
        header {
            display: block;
            width: 100%;
            border-bottom: 1px solid #ccc;
            text-align: center;
            margin: 15px 0;
            padding-bottom: 15px;
        }

            header > div {
                width: 32%;
                display: inline-block;
                vertical-align: bottom;
            }

            header .previous-week a {
                border-color: #ddd !important;
                border-top-left-radius: 20px;
                border-bottom-left-radius: 20px;
            }

            header .next-week a {
                border-color: #ddd !important;
                border-top-right-radius: 20px;
                border-bottom-right-radius: 20px;
            }

            header .title {
                font-size: .9em;
            }

                header .title span {
                    display: block;
                    color: #999;
                    font-size: .75em;
                    line-height: .75em;
                    margin: 5px 0 0 0;
                    padding: 0;
                }
    </style>

</week-header>