class LocaleTimeFormats
  EUROPE_FORMAT = {
    :default           => "%d/%m/%y  %k:%M",
    :default_with_tz   => "%d/%m/%y  %k:%M  %Z",
    :rr_date_only      => "%d/%m/%Y",
    :rr_date_only_no_zeros => "%-d/%-m/%y",
    :rr_mdy            => "%d/%m/%Y",
    :rr_md             => "%d/%m",
    :rr_mon_and_day    => lambda{ |time| time.strftime("%B #{time.day.ordinalize}") },
    :rr_mon_and_year   => "%b %Y",
    :rr_month_and_year => "%B %Y",
    :rr_mon_day_year   => "%b %-d, %Y",
    :rr_time_only      => "%k:%M",
    :rr_time_compact   => "%k:%M"
  }
  LOCALE_DATE_FORMATS = {
    :US => {
      :default                => "%m/%d/%y  %l:%M %p",
      :default_with_tz        => "%m/%d/%y  %l:%M %p  %Z",
      :rr_date_only           => "%m/%d/%Y",
      :rr_date_only_no_zeros  => "%-m/%-d/%y",
      :rr_date_year_month_day => "%Y-%m-%d",
      :rr_mdy                 => "%m/%d/%Y",
      :rr_md                  => "%m/%d",
      :rr_mon_and_day         => lambda{ |time| time.strftime("%B #{time.day.ordinalize}") },
      :rr_mon_and_year        => "%b %Y",
      :rr_month_and_year      => "%B %Y",
      :rr_mon_day_year        => "%b %-d, %Y",
      :rr_time_only           => "%l:%M %p",
      :rr_time_compact        => "%l:%M%P"
    },
    :UK => EUROPE_FORMAT,
    :Spain => EUROPE_FORMAT,
  }.freeze

  def self.set_time_format( locale )
    Time::DATE_FORMATS[:default]                = LOCALE_DATE_FORMATS[locale][:default]
    Time::DATE_FORMATS[:default_with_tz]        = LOCALE_DATE_FORMATS[locale][:default_with_tz]
    Time::DATE_FORMATS[:rr_date_only]           = LOCALE_DATE_FORMATS[locale][:rr_date_only]
    Time::DATE_FORMATS[:rr_date_only_no_zeros]  = LOCALE_DATE_FORMATS[locale][:rr_date_only_no_zeros]
    Time::DATE_FORMATS[:rr_date_year_month_day] = LOCALE_DATE_FORMATS[locale][:rr_date_year_month_day]
    Time::DATE_FORMATS[:rr_mon_and_day]         = LOCALE_DATE_FORMATS[locale][:rr_mon_and_day]
    Time::DATE_FORMATS[:rr_time_only]           = LOCALE_DATE_FORMATS[locale][:rr_time_only]
    Time::DATE_FORMATS[:rr_time_compact]        = LOCALE_DATE_FORMATS[locale][:rr_time_compact]
    Date::DATE_FORMATS[:rr_mdy]                 = LOCALE_DATE_FORMATS[locale][:rr_mdy]
    Date::DATE_FORMATS[:rr_md]                  = LOCALE_DATE_FORMATS[locale][:rr_md]
    Date::DATE_FORMATS[:rr_mon_and_year]        = LOCALE_DATE_FORMATS[locale][:rr_mon_and_year]
    Date::DATE_FORMATS[:rr_month_and_year]      = LOCALE_DATE_FORMATS[locale][:rr_month_and_year]
    Date::DATE_FORMATS[:rr_mon_day_year]        = LOCALE_DATE_FORMATS[locale][:rr_mon_day_year]
  end
end
Time::DATE_FORMATS[:rr_cookie_date] = "%m/%d/%Y"

LocaleTimeFormats.set_time_format( :US )
