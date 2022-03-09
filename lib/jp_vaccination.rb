# frozen_string_literal: true

require 'date'
require 'json'
require_relative './jp_vaccination/vaccination'
require_relative './jp_vaccination/version'

module JpVaccination
  def self.json_data
    vaccinations = File.open('./data/vaccinations.json', 'r', &:read)
    JSON.parse(vaccinations, symbolize_names: true)[:vaccinations]
  end

  def self.find(vaccination)
    data = json_data
    vaccination_data = data[vaccination.to_sym]
    JpVaccination::Vaccination.new(vaccination_data)
  end

  def self.recommended_schedules(birthday:)
    recommended_schedules = []

    json_data.each do |_key, vaccination|
      name = "#{vaccination[:name]} #{vaccination[:period]}"

      if vaccination[:recommended].class != Hash
        recommended_day = pre_school_year(birthday: birthday)
      elsif vaccination[:recommended][:month]
        recommended_day = Date.parse(birthday) >> vaccination[:recommended][:month].to_i
      elsif vaccination[:recommended][:year]
        recommended_day = Date.parse(birthday) >> vaccination[:recommended][:year].to_i * 12
      end
      recommended_schedules << { name: name, date: recommended_day }
    end

    recommended_schedules
  end

  def self.next_day(vaccination_name:, last_time:)
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

  def self.calc_date(period:, start_or_end:, date:)
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

  def self.pre_school_year(birthday:)
    five_years_old = Date.parse(birthday) >> 12 * 5
    case five_years_old.month
    when 1..3
      year = five_years_old.year
    when 4
      year = five_years_old.day == 1 ? five_years_old.year : five_years_old.year + 1
    when 5..12
      year = five_years_old.year + 1
    end
    Date.new(year, 4, 1)..Date.new(year + 1, 3, 31)
  end
end
