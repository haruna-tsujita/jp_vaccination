# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/jp_vaccination'

class JpVaccinationTest < Minitest::Test # rubocop:disable Metrics/classLength
  def test_vaccination_keys # rubocop:disable Metrics/MethodLength
    expected_keys = [{ 'ヒブ １回目' => 'hib_1' },
                     { 'ヒブ ２回目' => 'hib_2' },
                     { 'ヒブ ３回目' => 'hib_3' },
                     { 'ヒブ ４回目' => 'hib_4' },
                     { 'Ｂ型肝炎 １回目' => 'hepatitis_B_1' },
                     { 'Ｂ型肝炎 ２回目' => 'hepatitis_B_2' },
                     { 'Ｂ型肝炎 ３回目' => 'hepatitis_B_3' },
                     { 'ロタウイルス １回目' => 'rotavirus_1' },
                     { 'ロタウイルス ２回目' => 'rotavirus_2' },
                     { 'ロタウイルス ３回目' => 'rotavirus_3' },
                     { '小児用肺炎球菌 １回目' => 'pneumococcus_1' },
                     { '小児用肺炎球菌 ２回目' => 'pneumococcus_2' },
                     { '小児用肺炎球菌 ３回目' => 'pneumococcus_3' },
                     { '小児用肺炎球菌 ４回目' => 'pneumococcus_4' },
                     { '４種混合 第１期 １回目' => 'DPT_IPV_1' },
                     { '４種混合 第１期 ２回目' => 'DPT_IPV_2' },
                     { '４種混合 第１期 ３回目' => 'DPT_IPV_3' },
                     { '４種混合 第１期 ４回目' => 'DPT_IPV_4' },
                     { '２種混合 第２期' => 'DT_1' },
                     { 'ＢＣＧ ' => 'BCG_1' },
                     { '麻しん・風しん混合 第１期' => 'MR_1' },
                     { '麻しん・風しん混合 第２期' => 'MR_2' },
                     { '水痘 １回目' => 'chickenpox_1' },
                     { '水痘 ２回目' => 'chickenpox_2' },
                     { 'おたふくかぜ １回目' => 'mumps_1' },
                     { 'おたふくかぜ ２回目' => 'mumps_2' },
                     { '日本脳炎 第１期 １回目' => 'Japanese_encephalitis_1' },
                     { '日本脳炎 第１期 ２回目' => 'Japanese_encephalitis_2' },
                     { '日本脳炎 第１期 ３回目' => 'Japanese_encephalitis_3' },
                     { '日本脳炎 第２期' => 'Japanese_encephalitis_4' }]
    assert_equal expected_keys, JpVaccination.vaccination_keys
  end

  def test_find_when_argument_is_not_exist_key
    not_exist_key = 'hib_5'
    e = assert_raises ArgumentError do
      JpVaccination.find(not_exist_key)
    end
    assert_equal "The vaccination_key '#{not_exist_key}' doesn\'t exist.", e.message
  end

  def test_next_day_when_interval_nil
    vaccination_key = 'hib_1'
    birthday = '2020-01-01'
    next_day = JpVaccination.next_day(vaccination_key, birthday)
    assert_equal 'ヒブ １回目', next_day[:name]
    assert_equal Date.parse('2020-03-01'), next_day[:date]
  end

  def test_next_day_when_interval_nil_and_deadline_nil
    vaccination_key = 'mumps_2'
    birthday = '2020-01-01'
    next_day = JpVaccination.next_day(vaccination_key, birthday)
    assert_equal 'おたふくかぜ ２回目', next_day[:name]
    assert_equal '小学校入学前１年間', next_day[:date]
  end

  def test_next_day_when_interval
    vaccination_key = 'hepatitis_B_2'
    last_time = '2020-01-01'
    next_day = JpVaccination.next_day(vaccination_key, last_time)
    assert_equal 'Ｂ型肝炎 ２回目', next_day[:name]
    assert_equal Date.parse('2020-01-28'), next_day[:date]
  end

  def test_next_day_method_when_argument_is_not_exist_key
    not_exist_key = 'hib_5'
    e = assert_raises ArgumentError do
      JpVaccination.next_day(not_exist_key, '2020-01-02')
    end
    assert_equal "The vaccination_key '#{not_exist_key}' doesn\'t exist.", e.message
  end

  def test_recommended_days # rubocop:disable Metrics/MethodLength
    birthday = '2021-04-01'
    expect_schedules = [{ name: 'ヒブ １回目', date: Date.parse('2021-06-01') },
                        { name: 'ヒブ ２回目', date: Date.parse('2021-07-01') },
                        { name: 'ヒブ ３回目', date: Date.parse('2021-08-01') },
                        { name: 'ヒブ ４回目', date: Date.parse('2022-04-01') },
                        { name: 'Ｂ型肝炎 １回目', date: Date.parse('2021-06-01') },
                        { name: 'Ｂ型肝炎 ２回目', date: Date.parse('2021-07-01') },
                        { name: 'Ｂ型肝炎 ３回目', date: Date.parse('2021-11-01') },
                        { name: 'ロタウイルス １回目', date: Date.parse('2021-06-01') },
                        { name: 'ロタウイルス ２回目', date: Date.parse('2021-07-01') },
                        { name: 'ロタウイルス ３回目', date: Date.parse('2021-08-01') },
                        { name: '小児用肺炎球菌 １回目', date: Date.parse('2021-06-01') },
                        { name: '小児用肺炎球菌 ２回目', date: Date.parse('2021-07-01') },
                        { name: '小児用肺炎球菌 ３回目', date: Date.parse('2021-08-01') },
                        { name: '小児用肺炎球菌 ４回目', date: Date.parse('2022-04-01') },
                        { name: '４種混合 第１期 １回目', date: Date.parse('2021-07-01') },
                        { name: '４種混合 第１期 ２回目', date: Date.parse('2021-08-01') },
                        { name: '４種混合 第１期 ３回目', date: Date.parse('2021-09-01') },
                        { name: '４種混合 第１期 ４回目', date: Date.parse('2022-04-01') },
                        { name: '２種混合 第２期', date: Date.parse('2032-04-01') },
                        { name: 'ＢＣＧ ', date: Date.parse('2021-09-01') },
                        { name: '麻しん・風しん混合 第１期', date: Date.parse('2022-04-01') },
                        { name: '麻しん・風しん混合 第２期', date: Date.parse('2026-04-01')..Date.parse('2027-03-31') },
                        { name: '水痘 １回目', date: Date.parse('2022-04-01') },
                        { name: '水痘 ２回目', date: Date.parse('2022-10-01') },
                        { name: 'おたふくかぜ １回目', date: Date.parse('2022-04-01') },
                        { name: 'おたふくかぜ ２回目', date: Date.parse('2026-04-01')..Date.parse('2027-03-31') },
                        { name: '日本脳炎 第１期 １回目', date: Date.parse('2024-04-01') },
                        { name: '日本脳炎 第１期 ２回目', date: Date.parse('2024-05-01') },
                        { name: '日本脳炎 第１期 ３回目', date: Date.parse('2025-04-01') },
                        { name: '日本脳炎 第２期', date: Date.parse('2030-04-01') }]
    assert_equal expect_schedules, JpVaccination.recommended_days(birthday)
  end

  def test_recommended_schedules
    birthday = '2022-04-14'
    sort_schedules = { '2022-06-14' => ['ヒブ １回目', 'ロタウイルス １回目', '小児用肺炎球菌 １回目', 'Ｂ型肝炎 １回目'],
                       '2022-07-14' => ['ヒブ ２回目', 'ロタウイルス ２回目', '小児用肺炎球菌 ２回目', '４種混合 第１期 １回目', 'Ｂ型肝炎 ２回目'],
                       '2022-08-14' => ['ヒブ ３回目', 'ロタウイルス ３回目', '小児用肺炎球菌 ３回目', '４種混合 第１期 ２回目'],
                       '2022-09-14' => ['４種混合 第１期 ３回目', 'ＢＣＧ '],
                       '2022-11-14' => ['Ｂ型肝炎 ３回目'],
                       '2023-04-14' => ['おたふくかぜ １回目', 'ヒブ ４回目', '小児用肺炎球菌 ４回目', '水痘 １回目', '麻しん・風しん混合 第１期',
                                        '４種混合 第１期 ４回目'],
                       '2023-10-14' => ['水痘 ２回目'],
                       '2025-04-14' => ['日本脳炎 第１期 １回目'],
                       '2025-05-14' => ['日本脳炎 第１期 ２回目'],
                       '2026-04-14' => ['日本脳炎 第１期 ３回目'],
                       '2028-04-01〜2029-03-31' => ['おたふくかぜ ２回目', '麻しん・風しん混合 第２期'],
                       '2031-04-14' => ['日本脳炎 第２期'],
                       '2033-04-14' => ['２種混合 第２期'] }
    assert_equal sort_schedules, JpVaccination.recommended_schedules(birthday, true)
  end

  def test_convert_to_strings
    birthday = '2020-02-29'

    sort_schedules = { Date.parse('2020-04-29') => ['ヒブ １回目', 'ロタウイルス １回目', '小児用肺炎球菌 １回目', 'Ｂ型肝炎 １回目'],
                       Date.parse('2020-05-29') => ['ヒブ ２回目', 'ロタウイルス ２回目', '小児用肺炎球菌 ２回目', '４種混合 第１期 １回目',
                                                    'Ｂ型肝炎 ２回目'],
                       Date.parse('2020-06-29') => ['ヒブ ３回目', 'ロタウイルス ３回目', '小児用肺炎球菌 ３回目', '４種混合 第１期 ２回目'],
                       Date.parse('2020-07-29') => ['４種混合 第１期 ３回目', 'ＢＣＧ '],
                       Date.parse('2020-09-29') => ['Ｂ型肝炎 ３回目'],
                       Date.parse('2021-02-28') => ['おたふくかぜ １回目', 'ヒブ ４回目', '小児用肺炎球菌 ４回目', '水痘 １回目', '麻しん・風しん混合 第１期',
                                                    '４種混合 第１期 ４回目'],
                       Date.parse('2021-08-29') => ['水痘 ２回目'],
                       Date.parse('2023-02-28') => ['日本脳炎 第１期 １回目'],
                       Date.parse('2023-03-29') => ['日本脳炎 第１期 ２回目'],
                       Date.parse('2024-02-29') => ['日本脳炎 第１期 ３回目'],
                       Date.parse('2025-04-01')..Date.parse('2026-03-31') => ['おたふくかぜ ２回目', '麻しん・風しん混合 第２期'],
                       Date.parse('2029-02-28') => ['日本脳炎 第２期'],
                       Date.parse('2031-02-28') => ['２種混合 第２期'] }
    assert_equal sort_schedules, JpVaccination.recommended_schedules(birthday)
  end
end
