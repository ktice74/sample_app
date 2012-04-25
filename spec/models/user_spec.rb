# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null

require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "remember_token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }


    it { should be_valid }

    describe "when name is not present" do
      before { @user.name = " " }
      it { should_not be_valid }
    end

    describe "when email is not present" do
      before { @user.email = " " }
      it { should_not be_valid }
    end

    describe "when name is too long" do
      before { @user.name = "a" * 51 }
      it { should_not be_valid }

      describe "when email format is invalid" do
        it "should be invalid" do
          addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
          addresses.each do |invalid_address|
            @user.email = invalid_address
            @user.should_not be_valid
          end
        end

        describe "when email format is valid" do
          it "should be valid" do
            addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
            addresses.each do |valid_address|
              @user.email = valid_address
              @user.should be_valid
            end
          end

          describe "when email address is already taken" do
            before do
              user_with_same_email = @user.dup
              user_with_same_email.email = @user.email.upcase
              user_with_same_email.save
            end
            describe "when password is not present" do
              before { @user.password = @user.password_confirmation = " " }
              it { should_not be_valid }
            end

            describe "when password doesn't match confirmation" do
              before { @user.password_confirmation = "mismatch" }
              it { should_not be_valid }
            end

            describe "when password confirmation is nil" do
              before { @user.password_confirmation = nil }
              it { should_not be_valid }
            end
          end

          it { should respond_to(:authenticate) }

          describe "with a password that's too short" do
            before { @user.password = @user.password_confirmation = "a" * 5 }
            it { should be_invalid }
          end

          describe "return value of authenticate method" do
            before { @user.save }
            let(:found_user) { User.find_by_email(@user.email) }

            describe("with valid password") do
              it { should == found_user.authenticate(@user.password) }
            end

            describe("with invalid password") do
              let(:user_for_invalid_password) { found_user.authenticate("invalid") }

              it { should_not == user_for_invalid_password }
              specify { user_for_invalid_password.should be_false }
            end
          end

          describe "when email format is invalid" do
            it "should be invalid" do
              addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
              addresses.each do |invalid_address|
                @user.email = invalid_address
                @user.should_not be_valid
              end
            end

            describe "when email format is valid" do
              it "should be valid" do
                addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
                addresses.each do |valid_address|
                  @user.email = valid_address
                  @user.should be_valid
                end
              end

              describe "when email address is already taken" do
                before do
                  user_with_same_email = @user.dup
                  user_with_same_email.email = @user.email.upcase
                  user_with_same_email.save
                end

                it { should_not be_valid }
              end

              describe "when password is not present" do
                before { @user.password = @user.password_confirmation = " " }
                it { should_not be_valid }
              end

              describe "when password doesn't match confirmation" do
                before { @user.password_confirmation = "mismatch" }
                it { should_not be_valid }
              end

              describe "when password confirmation is nil" do
                before { @user.password_confirmation = nil }
                it { should_not be_valid }
              end


              describe "with a password that's too short" do
                before { @user.password = @user.password_confirmation = "a" * 5 }
                it { should be_invalid }
              end

              describe "return value of authenticate method" do
                before { @user.save }
                let(:found_user) { User.find_by_email(@user.email) }

                describe "with valid password" do
                  it { should == found_user.authenticate(@user.password) }
                end

                describe "with invalid password" do
                  let(:user_for_invalid_password) { found_user.authenticate("invalid") }

                  it { should_not == user_for_invalid_password }
                  specify { user_for_invalid_password.should be_false }

                end
                describe "signin" do
                  before { visit signin_path }

                  describe "with invalid information" do
                    before { click_button "Sign in" }

                    it { should have_selector('title', text: 'Sign in') }
                    it { should have_selector('div.alert.alert-error', text: 'Invalid') }
                  end
                end
                describe "with valid information" do
                  let(:user) { FactoryGirl.create(:user) }
                  before do
                    fill_in "Email", with: user.email
                    fill_in "Password", with: user.password
                    click_button "Sign in"
                  end

                  it { should have_selector('title', text: user.name) }
                  it { should have_link('Profile', href: user_path(user)) }
                  it { should have_link('Sign out', href: signout_path) }
                  it { should_not have_link('Sign in', href: signin_path) }
                end
              end
            end
          end
        end
      end
    end
  end
end
