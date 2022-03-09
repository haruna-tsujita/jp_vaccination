# frozen_string_literal: true

require 'date'
require 'json'
require_relative './jp_vaccination/vaccination'
require_relative './jp_vaccination/version'

module JpVaccination
  class << self
    def json_data
      vaccinations = File.open('./data/vaccinations.json', 'r', &:read)
      JSON.parse(vaccinations, symbolize_names: true)[:vaccinations]
    end

    def find(vaccination)
      JpVaccination::Vaccination.new(json_data[vaccination.to_sym])
    end

    def recommended_schedules(birthday)
      json_data.map do |_key, vaccination|
        name = "#{vaccination[:name]} #{vaccination[:period]}"

        if vaccination[:recommended].class != Hash
          recommended_day = pre_school_year(birthday)
        elsif vaccination[:recommended][:month]
          recommended_day = Date.parse(birthday) >> vaccination[:recommended][:month].to_i
        elsif vaccination[:recommended][:year]
          recommended_day = Date.parse(birthday) >> vaccination[:recommended][:year].to_i * 12
        end
        { name: name, date: recommended_day }
      end
    end

    def next_day(vaccination_name:, last_time:)
      next_day = {}
      json_data.each do |key, vaccination|
        next unless key == vaccination_name.to_sym

        name = "#{vaccination[:name]} #{vaccination[:period]}"

        date = case vaccination[:interval]
               when nil
                 calc_date(period: vaccination[:deadline], start_or_end: :start, date: last_time)
               else
                 calc_date(period: vaccination[:interval], start_or_end: :start, date: last_time)
               end
        next_day[:name] = name
        next_day[:date] = date
      end
      next_day
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

    def pre_school_year(birthday)
      fifth_birthday = Date.parse(birthday) >> 12 * 5
      case fifth_birthday.month
      when 1..3
        year = fifth_birthday.year
      when 4
        year = fifth_birthday.day == 1 ? fifth_birthday.year : fifth_birthday.year + 1
      when 5..12
        year = fifth_birthday.year + 1
      end
      Date.new(year, 4, 1)..Date.new(year + 1, 3, 31)
    end
  end
end
