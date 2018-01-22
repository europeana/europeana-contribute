# frozen_string_literal: true

RSpec.describe User do
  subject { build(:user) }

  describe '#role' do
    it { is_expected.to respond_to(:role) }

    context 'when :admin' do
      subject { build(:user, role: :admin) }
      it { is_expected.to be_valid }
    end

    context 'when :events' do
      subject { build(:user, role: :events) }
      it { is_expected.to be_valid }
    end

    context 'when unknown' do
      subject { build(:user, role: :unknown) }
      it { is_expected.not_to be_valid }
    end
  end

  describe 'password confirmation' do
    let(:password) { Forgery::Basic.password }

    context 'when provided' do
      subject { build(:user, password: password, password_confirmation: password) }
      it { is_expected.to be_valid }
    end

    context 'when not provided' do
      subject { build(:user, password: password, password_confirmation: nil) }
      it { is_expected.not_to be_valid }
    end
  end
end
