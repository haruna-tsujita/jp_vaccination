# frozen_string_literal: true

require 'date'
require 'json'
require_relative './jp_vaccination/vaccination'
require_relative './jp_vaccination/version'

module JpVaccination # rubocop:disable Metrics/ModuleLength
  class << self
    def vaccination_keys
      vaccinations_json.map do |key, _value|
        { find(key).formal_name => key.to_s }
      end
    end

    def find(vaccination_key)
      data = vaccinations_json[vaccination_key.to_sym]
      output_argument_error(vaccination_key) if data.nil?
      JpVaccination::Vaccination.new(data)
    end

    def recommended_days(birthday, convert_to_strings = nil)
      vaccinations_json.map do |_key, vaccination|
        name = "#{vaccination[:name]} #{vaccination[:period]}"

        if vaccination[:recommended].class != Hash
          recommended_day = pre_school_year(birthday, convert_to_strings)
        elsif vaccination[:recommended][:month]
          recommended_day = Date.parse(birthday) >> vaccination[:recommended][:month].to_i
        elsif vaccination[:recommended][:year]
          recommended_day = Date.parse(birthday) >> vaccination[:recommended][:year].to_i * 12
        end
        if convert_to_strings && recommended_day.instance_of?(Date)
          recommended_day = recommended_day.strftime('%Y-%m-%d')
        end
        { name: name, date: recommended_day }
      end
    end

    def recommended_schedules(birthday, convert_to_strings = nil)
      sort_by_date_vaccination_days =
        recommended_days(birthday, convert_to_strings).sort_by do |day|
          [Date, String].include?(day[:date].class) ? day[:date] : day[:date].first
        end
      combined_name_and_date = sort_by_date_vaccination_days.each_with_object({}) do |day, ret|
        ret[day[:name]] = day[:date]
      end
      combined_name_and_date.each_key.group_by { |date| combined_name_and_date[date] }.each_value(&:sort!)
    end

    def next_day(vaccination_key, last_time, birthday = nil)
      next_day = {}
      vaccinations_json.each do |key, vaccination|
        next unless key == vaccination_key.to_sym

        name = "#{vaccination[:name]} #{vaccination[:period]}"

        date = case vaccination[:interval]
               when nil
                 nil_interval(vaccination, last_time)
               else
                 if vaccination[:birthday]
                   pneumococcus_fourth(vaccination, last_time, birthday)
                 else
                   calc_date(period: vaccination[:interval], start_or_end: :start, date: last_time)
                 end
               end
        next_day[:name] = name
        next_day[:date] = date
      end
      output_argument_error(vaccination_key) if next_day[:name].nil?
      next_day
    end

    private

    def vaccinations_json
      json_file = File.expand_path('../data/vaccinations.json', __dir__)
      JSON.parse(File.read(json_file), symbolize_names: true)[:vaccinations]
    end

    def calc_date(period:, start_or_end:, date:)
      date = case period[:date_type]
             when 'day'
               Date.parse(date) + period[start_or_end].to_i
             when 'week'
               Date.parse(date) + (period[start_or_end].to_i * 7)
             when 'month'
               Date.parse(date) >> period[start_or_end].to_i
             when 'year'
               Date.parse(date) >> (period[start_or_end].to_i * 12)
             end
      return date if start_or_end != :end

      period[:less_than] ? date - 1 : date
    end

    def nil_interval(vaccination, last_time)
      if vaccination[:deadline]
        calc_date(period: vaccination[:deadline], start_or_end: :start, date: last_time)
      else
        vaccination[:recommended]
      end
    end

    def pneumococcus_fourth(vaccination, last_time, birthday)
      interval_date = calc_date(period: vaccination[:interval], start_or_end: :start, date: last_time)
      birthday_date = Date.parse(birthday) >> vaccination[:birthday][:start]
      interval_date < birthday_date ? birthday_date : interval_date
    end

    def pre_school_year(birthday, convert_to_strings = nil)
      fifth_birthday = Date.parse(birthday) >> 12 * 5
      year = case fifth_birthday.month
             when 1..3
               fifth_birthday.year
             when 4
               fifth_birthday.day == 1 ? fifth_birthday.year : fifth_birthday.year.next
             when 5..12
               fifth_birthday.year.next
             end
      convert_to_strings ? "#{year}-04-01〜#{year.next}-03-31" : Date.new(year, 4, 1)..Date.new(year.next, 3, 31)
    end

    def output_argument_error(vaccination_key)
      raise ArgumentError, "The vaccination_key '#{vaccination_key}' doesn\'t exist."
    end
  end
end
