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

  def test_recommended_schedules # rubocop:disable Metrics/MethodLength
    birthday = '2021-04-01'
    expect_schedules = [{ name: 'ヒブ １回目', date_type: Date.parse('2021-06-01') },
                        { name: 'ヒブ ２回目', date_type: Date.parse('2021-07-01') },
                        { name: 'ヒブ ３回目', date_type: Date.parse('2021-08-01') },
                        { name: 'ヒブ ４回目', date_type: Date.parse('2022-04-01') },
                        { name: 'Ｂ型肝炎 １回目', date_type: Date.parse('2021-06-01') },
                        { name: 'Ｂ型肝炎 ２回目', date_type: Date.parse('2021-07-01') },
                        { name: 'Ｂ型肝炎 ３回目', date_type: Date.parse('2021-11-01') },
                        { name: 'ロタウイルス １回目', date_type: Date.parse('2021-06-01') },
                        { name: 'ロタウイルス ２回目', date_type: Date.parse('2021-07-01') },
                        { name: 'ロタウイルス ３回目', date_type: Date.parse('2021-08-01') },
                        { name: '小児用肺炎球菌 １回目', date_type: Date.parse('2021-06-01') },
                        { name: '小児用肺炎球菌 ２回目', date_type: Date.parse('2021-07-01') },
                        { name: '小児用肺炎球菌 ３回目', date_type: Date.parse('2021-08-01') },
                        { name: '小児用肺炎球菌 ４回目', date_type: Date.parse('2022-04-01') },
                        { name: '４種混合 第１期 １回目', date_type: Date.parse('2021-07-01') },
                        { name: '４種混合 第１期 ２回目', date_type: Date.parse('2021-08-01') },
                        { name: '４種混合 第１期 ３回目', date_type: Date.parse('2021-09-01') },
                        { name: '４種混合 第１期 ４回目', date_type: Date.parse('2022-04-01') },
                        { name: '２種混合 第２期', date_type: Date.parse('2032-04-01') },
                        { name: 'ＢＣＧ ', date_type: Date.parse('2021-09-01') },
                        { name: '麻しん・風しん混合 第１期', date_type: Date.parse('2022-04-01') },
                        { name: '麻しん・風しん混合 第２期', date_type: Date.parse('2026-04-01')..Date.parse('2027-03-31') },
                        { name: '水痘 １回目', date_type: Date.parse('2022-04-01') },
                        { name: '水痘 ２回目', date_type: Date.parse('2022-10-01') },
                        { name: 'おたふくかぜ １回目', date_type: Date.parse('2022-04-01') },
                        { name: 'おたふくかぜ ２回目', date_type: Date.parse('2026-04-01')..Date.parse('2027-03-31') },
                        { name: '日本脳炎 第１期 １回目', date_type: Date.parse('2024-04-01') },
                        { name: '日本脳炎 第１期 ２回目', date_type: Date.parse('2024-05-01') },
                        { name: '日本脳炎 第１期 ３回目', date_type: Date.parse('2025-04-01') },
                        { name: '日本脳炎 第２期', date_type: Date.parse('2030-04-01') }]

    assert_equal JpVaccination.recommended_schedules(birthday: birthday), expect_schedules
  end

  def test_pre_school_year_born_april_1st
    birthday = '2020-04-01'
    assert_equal JpVaccination.pre_school_year(birthday: birthday), Date.parse('2025-04-01')..Date.parse('2026-03-31')
  end

  def test_pre_school_year_born_april_2nd
    birthday = '2020-04-02'
    assert_equal JpVaccination.pre_school_year(birthday: birthday), Date.parse('2026-04-01')..Date.parse('2027-03-31')
  end
end
