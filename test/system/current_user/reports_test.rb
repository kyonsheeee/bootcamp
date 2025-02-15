# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::ReportsTest < ApplicationSystemTestCase
  test 'show current_user reports when current_user is student' do
    visit_with_auth '/current_user/reports', 'hatsuno'
    assert_equal '自分の日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show reports download button when reports exist' do
    # 日報があるユーザーでログイン
    visit_with_auth '/current_user/reports', 'hatsuno'
    assert_text '日報一括ダウンロード'
  end

  test 'not show reports download button when no reports' do
    # 日報がないユーザーでログイン
    visit_with_auth '/current_user/reports', 'nippounashi'
    assert_no_text '日報一括ダウンロード'
  end
end
