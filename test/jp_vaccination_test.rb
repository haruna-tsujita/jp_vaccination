# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/jp_vaccination'

class JpVaccinationTest < Minitest::Test
  def test_next_day_when_interval_nil
    vaccination = 'hib_1'
    birthday = '2020-01-01'
    next_day = JpVaccination.next_day(vaccination_name: vaccination, previous_day: birthday)
    assert_equal next_day[:name], 'ヒブ １回目'
    assert_equal next_day[:date_type].year, 2020
    assert_equal next_day[:date_type].month, 3
    assert_equal next_day[:date_type].day, 1
  end

  def test_next_day_when_interval
    vaccination = 'hepatitis_B_2'
    previous_day = '2020-01-01'
    next_day = JpVaccination.next_day(vaccination_name: vaccination, previous_day: previous_day)
    assert_equal next_day[:name], 'Ｂ型肝炎 ２回目'
    assert_equal next_day[:date_type].year, 2020
    assert_equal next_day[:date_type].month, 1
    assert_equal next_day[:date_type].day, 28
  end

  def test_calc_date_when_day
    vaccination_period = JpVaccination.json_data['pneumococcus_2'.to_sym][:interval]
    previous_day = '2020-01-01'
    calc_date = JpVaccination.calc_date(period: vaccination_period, start_or_end: :start, date_type: previous_day)
    assert_equal calc_date.year, 2020
    assert_equal calc_date.month, 1
    assert_equal calc_date.day, 28
  end

  def test_calc_date_when_week
    vaccination_period = JpVaccination.json_data['rotavirus_2'.to_sym][:interval]
    previous_day = '2020-01-01'
    calc_date = JpVaccination.calc_date(period: vaccination_period, start_or_end: :start, date_type: previous_day)
    assert_equal calc_date.year, 2020
    assert_equal calc_date.month, 1
    assert_equal calc_date.day, 29
  end

  def test_calc_date_when_month
    vaccination_period = JpVaccination.json_data['Japanese_encephalitis_3'.to_sym][:interval]
    previous_day = '2020-01-01'
    calc_date = JpVaccination.calc_date(period: vaccination_period, start_or_end: :start, date_type: previous_day)
    assert_equal calc_date.year, 2020
    assert_equal calc_date.month, 7
    assert_equal calc_date.day, 1
  end

  def test_calc_date_when_year
    vaccination_period = JpVaccination.json_data['MR_1'.to_sym][:deadline]
    birthday = '2020-01-01'
    calc_date = JpVaccination.calc_date(period: vaccination_period, start_or_end: :start, date_type: birthday)
    assert_equal calc_date.year, 2021
    assert_equal calc_date.month, 1
    assert_equal calc_date.day, 1
  end
end
