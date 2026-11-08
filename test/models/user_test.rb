require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "accepts a password with at least twelve characters" do
    user = User.new(email: "student@example.com", password: "correct-horse")

    assert user.valid?
  end

  test "rejects a password shorter than twelve characters" do
    user = User.new(email: "student@example.com", password: "short-pass1")

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "normalizes email before validation" do
    user = User.new(email: "  Student@Example.COM ", password: "correct-horse")

    user.valid?

    assert_equal "student@example.com", user.email
  end

  test "requires email confirmation before authentication" do
    user = User.new(email: "student@example.com", password: "correct-horse")

    assert_not user.active_for_authentication?
  end
end
