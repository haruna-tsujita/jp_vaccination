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

  def self.next_day(vaccination_name:, previous_day:)
    next_day = {}
    json_data.each do |key, vaccination|
      next unless key == vaccination_name

      name = "#{vaccination[:name]} #{vaccination[:period]}"

      date_type = case vaccination[:interval]
                  when nil
                    calc_date(period: vaccination[:deadline], start_or_end: :start, date_type: previous_day)
                  else
                    calc_date(period: vaccination[:interval], start_or_end: :start, date_type: previous_day)
                  end
      next_day[:name] = name
      next_day[:date_type] = date_type
    end
    next_day
  end

  def self.calc_date(period:, start_or_end:, date_type:)
    case period[:date_type]
    when 'day'
      Date.parse(date_type) + period[start_or_end].to_i
    when 'week'
      Date.parse(date_type) + (period[start_or_end].to_i * 7)
    when 'month'
      Date.parse(date_type) >> period[start_or_end].to_i
    when 'year'
      Date.parse(date_type) >> (period[start_or_end].to_i * 12)
    end
  end
end
