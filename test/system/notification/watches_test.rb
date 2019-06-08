# frozen_string_literal: true

require "application_system_test_case"

class Notification::WatchesTest < ApplicationSystemTestCase
  setup do
    watches(:report1_watch_kimura)
    # コメントを投稿しても自動的にウォッチがONになる
    login_user "machida", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "いい日報ですね。")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"
    logout
  end

  test "report watcher receive a notification" do
    login_user "kimura", "testtest"

    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"
  end

  test "自動的にウォッチがONになった際、新しくコメントがついてもウォッチ通知が来ないバグの再現" do
    login_user "komagata", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "ありがとうございます。")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"
    logout

    login_user "machida", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"
  end
end
