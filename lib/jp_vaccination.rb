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
      data = json_data[vaccination.to_sym]
      output_argument_error(data)
      JpVaccination::Vaccination.new(data)
    end

    def recommended_schedules(birthday, convert_to_strings = nil)
      json_data.map do |_key, vaccination|
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

    def sort_recommended_schedules(birthday, convert_to_strings = nil)
      ary =
        recommended_schedules(birthday, convert_to_strings).map do |key, _value|
          { key[:name] => key[:date] }
        end

      flatten_hash = {}.merge(*ary)
      sort_date_ary = flatten_hash.sort_by do |_name, date|
        date.instance_of?(Date) || date.instance_of?(String) ? date : date.first
      end
      sort_date_ary.to_h.each_key.group_by { |key| flatten_hash[key] }
    end

    def next_day(vaccination_key:, last_time:)
      next_day = {}
      json_data.each do |key, vaccination|
        next unless key == vaccination_key.to_sym

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
      output_argument_error(next_day[:name])
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

    def pre_school_year(birthday, convert_to_strings = nil)
      fifth_birthday = Date.parse(birthday) >> 12 * 5
      case fifth_birthday.month
      when 1..3
        year = fifth_birthday.year
      when 4
        year = fifth_birthday.day == 1 ? fifth_birthday.year : fifth_birthday.year.next
      when 5..12
        year = fifth_birthday.year.next
      end
      convert_to_strings ? "#{year}-04-01〜#{year.next}-03-31" : Date.new(year, 4, 1)..Date.new(year.next, 3, 31)
    end

    def output_argument_error(not_exist_key)
      raise ArgumentError, 'The vaccination_key doesn\'t exist.' if not_exist_key.nil?
    end
  end
end
