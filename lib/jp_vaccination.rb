# frozen_string_literal: true

require 'json'
require_relative './jp_vaccination/vaccination'
require_relative './jp_vaccination/version'

module JpVaccination
  def self.json_data
    vaccinations = File.open('./data/vaccinations.json', 'r', &:read)
    JSON.parse(vaccinations, symbolize_names: true)[:vaccinations]
  end

  def self.find(vaccination)
    data = self.json_data
    vaccination_data = data[vaccination.to_sym]
    JpVaccination::Vaccination.new(vaccination_data)
  end
end
